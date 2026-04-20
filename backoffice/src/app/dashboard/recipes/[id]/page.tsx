'use client'

import { useEffect, useState } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { supabase, Recipe, Ingredient, Step } from '@/lib/supabase'
import RecipeForm from '@/components/RecipeForm'

export default function EditRecipePage() {
  const router = useRouter()
  const { id } = useParams<{ id: string }>()
  const [recipe, setRecipe] = useState<(Recipe & { ingredients: Ingredient[], steps: Step[] }) | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function load() {
      const [{ data: recipe }, { data: ingredients }, { data: steps }] = await Promise.all([
        supabase.from('recipes').select('*').eq('id', id).single(),
        supabase.from('ingredients').select('*').eq('recipe_id', id).order('name'),
        supabase.from('steps').select('*').eq('recipe_id', id).order('position'),
      ])
      if (recipe) setRecipe({ ...recipe, ingredients: ingredients ?? [], steps: steps ?? [] })
      setLoading(false)
    }
    load()
  }, [id])

  if (loading) return <div className="p-6 text-gray-400">Chargement…</div>
  if (!recipe) return <div className="p-6 text-red-500">Recette introuvable</div>

  return (
    <div className="p-6 max-w-3xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Modifier la recette</h1>
      <RecipeForm
        recipe={recipe}
        onSuccess={() => router.push('/dashboard/recipes')}
      />
    </div>
  )
}
