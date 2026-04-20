import { createClient } from "npm:@supabase/supabase-js@2"
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts"

Deno.serve(async (req) => {
  const corsResult = handleCors(req)
  if (corsResult) return corsResult

  const authHeader = req.headers.get("Authorization") ?? ""
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  )

  // ── GET — fetch shopping list ─────────────────────────────────────────────
  if (req.method === "GET") {
    const url = new URL(req.url)
    const familyId = url.searchParams.get("family_id")
    if (!familyId) return errorResponse("family_id required", 400)

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
    const body = await req.json()
    const { family_id, name, quantity, unit, category } = body
    if (!family_id || !name) return errorResponse("family_id, name required", 400)

    const parsedQty = quantity != null ? parseFloat(quantity) : null
    if (parsedQty !== null && isNaN(parsedQty))
      return errorResponse("quantity must be a number", 400)

    const { error } = await supabase.from("shopping_items").insert({
      family_id,
      name,
      quantity: parsedQty,
      unit: unit ?? null,
      category: category ?? "autre",
    })

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true }, 201)
  }

  // ── PATCH — toggle is_checked ─────────────────────────────────────────────
  if (req.method === "PATCH") {
    const body = await req.json()
    const { item_id, is_checked } = body
    if (!item_id || is_checked === undefined)
      return errorResponse("item_id, is_checked required", 400)

    const { error } = await supabase
      .from("shopping_items")
      .update({ is_checked })
      .eq("id", item_id)

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true })
  }

  // ── DELETE — clear checked items ──────────────────────────────────────────
  if (req.method === "DELETE") {
    const body = await req.json()
    const { family_id } = body
    if (!family_id) return errorResponse("family_id required", 400)

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
