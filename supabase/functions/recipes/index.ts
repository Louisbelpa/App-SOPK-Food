import { createClient } from "npm:@supabase/supabase-js@2"
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts"

// ─── Business logic (mirrors AppRecipe.swift helpers) ────────────────────────

function mealTypeLabel(type: string): string {
  const map: Record<string, string> = {
    breakfast: "Petit-déjeuner",
    lunch: "Déjeuner",
    dinner: "Dîner",
    snack: "Snack",
  }
  return map[type] ?? type.charAt(0).toUpperCase() + type.slice(1)
}

// Matrice nutritionnelle par phase du cycle (basée sur la littérature endocrinologique)
// Menstruelle  (j1-5)  : perte de fer → fer, B12, vit C, oméga-3 anti-prostaglandines
// Folliculaire (j6-13) : oestrogènes montants → folates, antioxydants, protéines, vit D
// Ovulatoire   (j14-16): pic LH/FSH → zinc, oméga-3, fibres, détox hormonale (I3C)
// Lutéale      (j17-28): progestérone → magnésium, B6, calcium, réconfort
function phaseForConditions(_conditions: string[], mealType: string, tags: string[]): string {
  const tl = tags.map(t => t.toLowerCase())
  const has = (kw: string) => tl.some(t => t.includes(kw))

  const scores: Record<string, number> = {
    Menstruelle: 0,
    Folliculaire: 0,
    Ovulatoire: 0,
    Lutéale: 0,
  }

  // Menstruelle
  if (has("riche en fer") || has("en fer")) scores.Menstruelle += 3
  if (has("b12") || has("riche en b12"))    scores.Menstruelle += 3
  if (has("anti-douleur"))                   scores.Menstruelle += 2
  if (has("vitamine c"))                     scores.Menstruelle += 1

  // Folliculaire
  if (has("folate"))                         scores.Folliculaire += 3
  if (has("antioxydant"))                    scores.Folliculaire += 2
  if (has("protéine") || has("protéin"))     scores.Folliculaire += 2
  if (has("vitamine d"))                     scores.Folliculaire += 2

  // Ovulatoire
  if (has("zinc"))                           scores.Ovulatoire += 3
  if (has("oméga") || has("omega"))          scores.Ovulatoire += 2
  if (has("riche en fibres") || has("fibre")) scores.Ovulatoire += 2
  if (has("détox hormonale") || has("lignane")) scores.Ovulatoire += 2
  if (has("choline"))                        scores.Ovulatoire += 1

  // Lutéale
  if (has("magnésium"))                      scores.Lutéale += 3
  if (has("vitamine b6") || has("b6"))       scores.Lutéale += 3
  if (has("calcium"))                        scores.Lutéale += 2
  if (has("réconfortant"))                   scores.Lutéale += 2
  if (has("collagène"))                      scores.Lutéale += 2
  if (has("boost énergie") || has("boost"))  scores.Lutéale += 1

  const best = Object.entries(scores).reduce((a, b) => a[1] >= b[1] ? a : b)
  if (best[1] > 0) return best[0]

  // Fallback par type de repas
  if (mealType === "breakfast") return "Folliculaire"
  if (mealType === "dinner")    return "Lutéale"
  if (mealType === "snack")     return "Lutéale"
  return "Folliculaire"
}

// Score anti-inflammatoire pondéré par niveau de preuve clinique (base 4, max 10)
// EPA/DHA : -40% TNF-α | Curcumine : -50% IL-6 | Vit D : -30% CRP
function estimateAntiInflam(tags: string[]): number {
  const weights: Record<string, number> = {
    "Riche en oméga-3":    3.0,
    "Anti-inflammatoire":  3.0,
    "Vitamine D":          2.5,
    "Antioxydant":         2.0,
    "Riche en magnésium":  2.0,
    "Détox hormonale":     1.5,
    "Lignanes":            1.5,
    "Soutien hépatique":   1.5,
    "Collagène":           1.0,
    "Riche en fibres":     1.0,
    "IG bas":              1.0,
    "Zinc":                1.0,
    "Choline":             1.0,
    "Vitamine B6":         0.5,
    "Folates":             0.5,
    "Riche en fer":        0.5,
  }

  let raw = 4
  for (const tag of tags) raw += weights[tag] ?? 0

  // Bonus synergie : oméga-3 + anti-inflammatoire (ex. saumon + curcuma)
  const hasOmega  = tags.some(t => t.includes("oméga-3"))
  const hasAntiI  = tags.some(t => t === "Anti-inflammatoire")
  if (hasOmega && hasAntiI) raw += 0.5

  return Math.min(10, Math.max(4, Math.round(raw)))
}

function estimateCalories(id: string, title: string, mealType: string): number {
  const ranges: Record<string, [number, number]> = {
    breakfast: [300, 450],
    lunch:     [450, 620],
    dinner:    [400, 580],
    snack:     [150, 280],
  }
  const [min, max] = ranges[mealType] ?? [380, 520]
  // Hash basé sur le titre (plus représentatif que l'UUID)
  const hash = [...(title + id)].reduce((acc, c) => (acc * 31 + c.charCodeAt(0)) & 0xffff, 0)
  return min + (hash % (max - min + 1))
}

const benefitsMap: Record<string, [string, string]> = {
  "Riche en oméga-3":      ["Oméga-3 EPA/DHA",          "Réduit TNF-α de 40% — anti-inflammatoire majeur"],
  "Anti-inflammatoire":    ["Anti-inflammatoire",        "Réduit IL-6 et cytokines pro-inflammatoires"],
  "Riche en fer":          ["Fer biodisponible",         "Combat la fatigue et l'anémie menstruelle"],
  "Riche en magnésium":    ["Magnésium",                 "Réduit les crampes et le syndrome prémenstruel"],
  "IG bas":                ["Index glycémique bas",      "Stabilise l'insuline — clé dans le SOPK"],
  "Antioxydant":           ["Antioxydants",              "Protège les follicules du stress oxydatif"],
  "Riche en fibres":       ["Fibres prébiotiques",       "Soutient le microbiote et élimine les œstrogènes"],
  "Soutien hépatique":     ["Soutien hépatique",         "Favorise la détoxification des œstrogènes"],
  "Détox hormonale":       ["Détox hormonale (I3C)",     "L'indole-3-carbinol élimine l'excès d'œstrogènes"],
  "Zinc":                  ["Zinc",                      "Régule le pic de LH et soutient l'immunité"],
  "Folates":               ["Folates",                   "Essentiels à la maturation folliculaire"],
  "Protéines":             ["Protéines complètes",       "25-30g/repas recommandés dans le SOPK"],
  "Vitamine D":            ["Vitamine D",                "Réduit CRP de 30% — carence fréquente dans le SOPK"],
  "Riche en B12":          ["Vitamine B12",              "Prévient l'anémie et soutient le système nerveux"],
  "Vitamine B6":           ["Vitamine B6",               "Réduit le SPM et régule la synthèse de progestérone"],
  "Lignanes":              ["Lignanes",                  "Phytoestrogènes qui régulent l'excès d'œstrogènes"],
  "Collagène":             ["Collagène",                 "Soutient les tissus et réduit l'inflammation pelvienne"],
  "Sensibilité à l'insuline": ["Sensibilité à l'insuline", "La cannelle de Ceylan améliore la sensibilité à l'insuline"],
  "Choline":               ["Choline",                   "Essentielle à la santé hépatique et détox des œstrogènes"],
  "Anti-douleur":          ["Anti-douleur naturel",      "Gingembre et curcuma inhibent les prostaglandines"],
  "Calcium":               ["Calcium",                   "Réduit les symptômes du SPM et soutient l'humeur"],
  "Riche en protéines végétales": ["Protéines végétales", "Légumineuses : satiété et fibres prébiotiques"],
}

function benefitsFromTags(tags: string[]): { label: string; detail: string }[] {
  return tags
    .filter((t) => benefitsMap[t])
    .slice(0, 3)
    .map((t) => ({ label: benefitsMap[t][0], detail: benefitsMap[t][1] }))
}

function formatQty(quantity: number | null, unit: string | null): string {
  if (!quantity || quantity <= 0) return ""
  const num = quantity % 1 === 0 ? String(Math.floor(quantity)) : quantity.toFixed(1)
  return unit ? `${num} ${unit}` : num
}

// ─── Main handler ─────────────────────────────────────────────────────────────

// ─── Simple in-memory rate limiter (per-IP, resets on cold start) ────────────
const rateLimitMap = new Map<string, { count: number; resetAt: number }>()
const RATE_LIMIT = 60       // requêtes max
const RATE_WINDOW_MS = 60_000  // par minute

function checkRateLimit(ip: string): boolean {
  const now = Date.now()
  const entry = rateLimitMap.get(ip)
  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(ip, { count: 1, resetAt: now + RATE_WINDOW_MS })
    return true
  }
  if (entry.count >= RATE_LIMIT) return false
  entry.count++
  return true
}

const VALID_CONDITIONS = ["sopk", "endometriose", "both"]
const VALID_MEAL_TYPES  = ["breakfast", "lunch", "dinner", "snack"]
const PAGE_SIZE = 20

Deno.serve(async (req) => {
  const corsResult = handleCors(req)
  if (corsResult) return corsResult

  const ip = req.headers.get("x-forwarded-for")?.split(",")[0].trim() ?? "unknown"
  if (!checkRateLimit(ip)) {
    return errorResponse("Too many requests", 429)
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
  )

  const url = new URL(req.url)
  const condition  = url.searchParams.get("condition")
  const meal_type  = url.searchParams.get("meal_type")
  const pageParam  = url.searchParams.get("page")
  const page       = Math.max(1, parseInt(pageParam ?? "1", 10) || 1)
  const from       = (page - 1) * PAGE_SIZE
  const to         = from + PAGE_SIZE - 1

  if (condition && !VALID_CONDITIONS.includes(condition))
    return errorResponse("condition invalide", 400)
  if (meal_type && !VALID_MEAL_TYPES.includes(meal_type))
    return errorResponse("meal_type invalide", 400)

  let query = supabase
    .from("recipes")
    .select("*, ingredients(*), steps(*)", { count: "exact" })
    .order("created_at", { ascending: true })
    .range(from, to)

  if (condition) query = query.contains("conditions", [condition])
  if (meal_type) query = query.eq("meal_type", meal_type)

  const { data, error, count } = await query

  if (error) return errorResponse(error.message)

  const recipes = (data ?? []).map((r) => {
    const totalTime = (r.prep_time ?? 0) + (r.cook_time ?? 0)
    const tags: string[] = r.tags ?? []
    const conditions: string[] = r.conditions ?? []
    const ingredients = (r.ingredients ?? []).map(
      (ing: { name: string; quantity: number | null; unit: string | null }) => ({
        name: ing.name,
        qty: formatQty(ing.quantity, ing.unit),
        why: "",
      }),
    )
    const steps = [...(r.steps ?? [])]
      .sort((a: { position: number }, b: { position: number }) => a.position - b.position)
      .map((s: { instruction: string }) => s.instruction)

    return {
      id: r.id,
      name: r.title,
      category: mealTypeLabel(r.meal_type),
      meal_type: r.meal_type,
      time: Math.max(totalTime, 5),
      anti_inflam: estimateAntiInflam(tags),
      calories: estimateCalories(r.id, r.title, r.meal_type),
      conditions,
      tags,
      phase: phaseForConditions(conditions, r.meal_type, tags),
      description: r.description ?? "",
      benefits: benefitsFromTags(tags),
      ingredients,
      steps,
    }
  })

  return jsonResponse({
    data: recipes,
    meta: {
      page,
      page_size: PAGE_SIZE,
      total: count ?? 0,
      total_pages: Math.ceil((count ?? 0) / PAGE_SIZE),
    },
  })
})
