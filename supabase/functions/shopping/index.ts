import { createClient } from "npm:@supabase/supabase-js@2"
import { handleCors, jsonResponse, errorResponse, checkRateLimit, getClientIp } from "../_shared/cors.ts"

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const VALID_CATEGORIES = ["légumes", "fruits", "protéines", "céréales", "laitiers", "épices", "boissons", "autre"]
const MAX_NAME_LENGTH = 100

function isValidUuid(v: string): boolean { return UUID_RE.test(v) }

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

  // ── GET — fetch shopping list ─────────────────────────────────────────────
  if (req.method === "GET") {
    const url = new URL(req.url)
    const familyId = url.searchParams.get("family_id")
    if (!familyId || !isValidUuid(familyId))
      return errorResponse("family_id UUID valide requis", 400)

    const { data, error } = await supabase
      .from("shopping_items")
      .select("id, name, quantity, unit, category, is_checked")
      .eq("family_id", familyId)
      .order("category", { ascending: true })
      .order("name", { ascending: true })

    if (error) return errorResponse(error.message)
    return jsonResponse(data ?? [])
  }

  // ── POST — add item ───────────────────────────────────────────────────────
  if (req.method === "POST") {
    const body = await req.json().catch(() => null)
    if (!body) return errorResponse("Body JSON invalide", 400)

    const { family_id, name, quantity, unit, category } = body

    if (!family_id || !isValidUuid(family_id))
      return errorResponse("family_id UUID valide requis", 400)
    if (!name || typeof name !== "string" || name.trim().length === 0)
      return errorResponse("name requis", 400)
    if (name.trim().length > MAX_NAME_LENGTH)
      return errorResponse(`name trop long (max ${MAX_NAME_LENGTH} caractères)`, 400)

    const parsedQty = quantity != null ? parseFloat(quantity) : null
    if (parsedQty !== null && (isNaN(parsedQty) || parsedQty <= 0))
      return errorResponse("quantity doit être un nombre positif", 400)

    if (unit !== undefined && unit !== null && typeof unit !== "string")
      return errorResponse("unit doit être une chaîne", 400)

    const safeCategory = category && VALID_CATEGORIES.includes(category) ? category : "autre"

    const { error } = await supabase.from("shopping_items").insert({
      family_id,
      name: name.trim(),
      quantity: parsedQty,
      unit: unit ?? null,
      category: safeCategory,
    })

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true }, 201)
  }

  // ── PATCH — toggle is_checked ─────────────────────────────────────────────
  if (req.method === "PATCH") {
    const body = await req.json().catch(() => null)
    if (!body) return errorResponse("Body JSON invalide", 400)

    const { item_id, is_checked } = body
    if (!item_id || !isValidUuid(item_id))
      return errorResponse("item_id UUID valide requis", 400)
    if (typeof is_checked !== "boolean")
      return errorResponse("is_checked doit être un booléen", 400)

    const { error } = await supabase
      .from("shopping_items")
      .update({ is_checked })
      .eq("id", item_id)

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true })
  }

  // ── DELETE — clear checked items ──────────────────────────────────────────
  if (req.method === "DELETE") {
    const body = await req.json().catch(() => null)
    if (!body) return errorResponse("Body JSON invalide", 400)

    const { family_id } = body
    if (!family_id || !isValidUuid(family_id))
      return errorResponse("family_id UUID valide requis", 400)

    const { error } = await supabase
      .from("shopping_items")
      .delete()
      .eq("family_id", family_id)
      .eq("is_checked", true)

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true })
  }

  return errorResponse("Method not allowed", 405)
})
