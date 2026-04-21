import { createClient } from "npm:@supabase/supabase-js@2"
import { handleCors, jsonResponse, errorResponse, checkRateLimit, getClientIp } from "../_shared/cors.ts"

const VALID_MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"]
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/

function isValidUuid(v: string): boolean { return UUID_RE.test(v) }
function isValidDate(v: string): boolean { return DATE_RE.test(v) && !isNaN(Date.parse(v)) }

function mondayOf(dateStr: string): string {
  const d = new Date(dateStr)
  const day = d.getUTCDay() || 7
  d.setUTCDate(d.getUTCDate() - (day - 1))
  return d.toISOString().slice(0, 10)
}

function sundayOf(mondayStr: string): string {
  const d = new Date(mondayStr)
  d.setUTCDate(d.getUTCDate() + 6)
  return d.toISOString().slice(0, 10)
}

Deno.serve(async (req) => {
  const corsResult = handleCors(req)
  if (corsResult) return corsResult

  const ip = getClientIp(req)
  if (!checkRateLimit(ip, 30, 60_000))
    return errorResponse("Too many requests", 429)

  const authHeader = req.headers.get("Authorization") ?? ""
  if (!authHeader.startsWith("Bearer "))
    return errorResponse("Authorization requis", 401)

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  )

  // ── GET — fetch week entries ──────────────────────────────────────────────
  if (req.method === "GET") {
    const url = new URL(req.url)
    const familyId = url.searchParams.get("family_id")
    const date = url.searchParams.get("date") ?? new Date().toISOString().slice(0, 10)

    if (!familyId || !isValidUuid(familyId))
      return errorResponse("family_id UUID valide requis", 400)
    if (!isValidDate(date))
      return errorResponse("date doit être au format YYYY-MM-DD", 400)

    const monday = mondayOf(date)
    const sunday = sundayOf(monday)

    const { data, error } = await supabase
      .from("meal_plan_entries")
      .select("id, family_id, recipe_id, date, meal_type")
      .eq("family_id", familyId)
      .gte("date", monday)
      .lte("date", sunday)
      .order("date", { ascending: true })
      .order("meal_type", { ascending: true })

    if (error) return errorResponse(error.message)
    return jsonResponse(data ?? [])
  }

  // ── POST — add entry ──────────────────────────────────────────────────────
  if (req.method === "POST") {
    const body = await req.json().catch(() => null)
    if (!body) return errorResponse("Body JSON invalide", 400)

    const { family_id, recipe_id, date, meal_type } = body

    if (!family_id || !isValidUuid(family_id))
      return errorResponse("family_id UUID valide requis", 400)
    if (!recipe_id || !isValidUuid(recipe_id))
      return errorResponse("recipe_id UUID valide requis", 400)
    if (!date || !isValidDate(date))
      return errorResponse("date doit être au format YYYY-MM-DD", 400)
    if (!meal_type || !VALID_MEAL_TYPES.includes(meal_type))
      return errorResponse(`meal_type doit être parmi : ${VALID_MEAL_TYPES.join(", ")}`, 400)

    const { error } = await supabase
      .from("meal_plan_entries")
      .insert({ family_id, recipe_id, date, meal_type })

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true }, 201)
  }

  // ── DELETE — remove entry ─────────────────────────────────────────────────
  if (req.method === "DELETE") {
    const body = await req.json().catch(() => null)
    if (!body) return errorResponse("Body JSON invalide", 400)

    const { entry_id } = body
    if (!entry_id || !isValidUuid(entry_id))
      return errorResponse("entry_id UUID valide requis", 400)

    const { error } = await supabase
      .from("meal_plan_entries")
      .delete()
      .eq("id", entry_id)

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true })
  }

  return errorResponse("Method not allowed", 405)
})
