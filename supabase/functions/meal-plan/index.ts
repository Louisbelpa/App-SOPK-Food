import { createClient } from "npm:@supabase/supabase-js@2"
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts"

function mondayOf(dateStr: string): string {
  const d = new Date(dateStr)
  const day = d.getUTCDay() || 7 // Sun=0 → 7
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

  // Forward user JWT so RLS applies
  const authHeader = req.headers.get("Authorization") ?? ""
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

    if (!familyId) return errorResponse("family_id required", 400)

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
    const body = await req.json()
    const { family_id, recipe_id, date, meal_type } = body
    if (!family_id || !recipe_id || !date || !meal_type)
      return errorResponse("family_id, recipe_id, date, meal_type required", 400)

    const { error } = await supabase
      .from("meal_plan_entries")
      .insert({ family_id, recipe_id, date, meal_type })

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true }, 201)
  }

  // ── DELETE — remove entry ─────────────────────────────────────────────────
  if (req.method === "DELETE") {
    const body = await req.json()
    const { entry_id } = body
    if (!entry_id) return errorResponse("entry_id required", 400)

    const { error } = await supabase
      .from("meal_plan_entries")
      .delete()
      .eq("id", entry_id)

    if (error) return errorResponse(error.message)
    return jsonResponse({ ok: true })
  }

  return errorResponse("Method not allowed", 405)
})
