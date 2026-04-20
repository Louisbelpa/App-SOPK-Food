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

function phaseForConditions(conditions: string[], mealType: string, tags: string[]): string {
  const tagsLower = tags.map(t => t.toLowerCase())
  if (tagsLower.some(t => t.includes("fer") || t.includes("vitamine c"))) return "Menstruelle"
  if (tagsLower.some(t => t.includes("antioxydant") || t.includes("folate") || t.includes("protéine"))) return "Folliculaire"
  if (tagsLower.some(t => t.includes("zinc") || t.includes("oméga"))) return "Ovulatoire"
  if (tagsLower.some(t => t.includes("magnésium") || t.includes("anti-stress"))) return "Lutéale"
  if (mealType === "breakfast") return "Folliculaire"
  if (mealType === "snack") return "Lutéale"
  return "Folliculaire"
}

function estimateAntiInflam(tags: string[]): number {
  let score = 6
  const boosts = [
    "Anti-inflammatoire",
    "Riche en oméga-3",
    "Antioxydant",
    "Soutien hépatique",
    "Riche en magnésium",
  ]
  for (const t of tags) {
    if (boosts.includes(t)) score++
  }
  return Math.min(score, 10)
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
  "Riche en oméga-3": ["Oméga-3 EPA/DHA", "Anti-inflammatoires majeurs"],
  "Anti-inflammatoire": ["Anti-inflammatoire", "Réduit les cytokines pro-inflammatoires"],
  "Riche en fer": ["Riche en fer", "Combat la fatigue menstruelle"],
  "Riche en magnésium": ["Magnésium", "Détente musculaire et nerveuse"],
  "IG bas": ["Index glycémique bas", "Stabilise l'insuline"],
  "Antioxydant": ["Antioxydants", "Protège les cellules du stress oxydatif"],
  "Riche en fibres": ["Fibres prébiotiques", "Soutient le microbiote intestinal"],
  "Soutien hépatique": ["Soutien hépatique", "Soutient la fonction hépatique"],
  "Zinc": ["Zinc", "Régulation hormonale et immunité"],
  "Folates": ["Folates", "Essentiels en phase folliculaire"],
  "Protéines": ["Protéines complètes", "Satiété et réparation cellulaire"],
  "Sensibilité à l'insuline": ["Sensibilité à l'insuline", "Certaines études suggèrent un potentiel bénéfice de la cannelle"],
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
