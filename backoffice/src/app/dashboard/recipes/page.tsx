'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase, Recipe, MEAL_TYPE_LABELS, CONDITION_LABELS } from '@/lib/supabase'
import { Plus, Pencil, Trash2, Search } from 'lucide-react'

export default function RecipesPage() {
  const router = useRouter()
  const [recipes, setRecipes] = useState<Recipe[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filterCondition, setFilterCondition] = useState('')
  const [filterMeal, setFilterMeal] = useState('')
  const [deleting, setDeleting] = useState<string | null>(null)

  useEffect(() => { fetchRecipes() }, [])

  async function fetchRecipes() {
    setLoading(true)
    let query = supabase.from('recipes').select('*').order('created_at', { ascending: false })
    if (filterCondition) query = query.contains('conditions', [filterCondition])
    if (filterMeal) query = query.eq('meal_type', filterMeal)

    const { data } = await query
    setRecipes(data ?? [])
    setLoading(false)
  }

  async function deleteRecipe(recipe: Recipe) {
    if (!confirm(`Supprimer "${recipe.title}" ?`)) return
    setDeleting(recipe.id)
    if (recipe.image_url) {
      const path = recipe.image_url.split('/storage/v1/object/public/recipe-images/')[1]
      if (path) await supabase.storage.from('recipe-images').remove([path])
    }
    await supabase.from('recipes').delete().eq('id', recipe.id)
    setRecipes(prev => prev.filter(r => r.id !== recipe.id))
    setDeleting(null)
  }

  const filtered = recipes.filter(r =>
    r.title.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Recettes</h1>
          <p className="text-gray-500 text-sm">{recipes.length} recette{recipes.length !== 1 ? 's' : ''} au total</p>
        </div>
        <button
          onClick={() => router.push('/dashboard/recipes/new')}
          className="flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-xl font-medium transition-colors"
        >
          <Plus size={18} />
          Nouvelle recette
        </button>
      </div>

      {/* Filters */}
      <div className="flex gap-3 mb-6 flex-wrap">
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Rechercher…"
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="pl-9 pr-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
          />
        </div>

        <select
          value={filterCondition}
          onChange={e => { setFilterCondition(e.target.value); setTimeout(fetchRecipes, 0) }}
          className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none"
        >
          <option value="">Toutes conditions</option>
          <option value="sopk">SOPK</option>
          <option value="endometriose">Endométriose</option>
        </select>

        <select
          value={filterMeal}
          onChange={e => { setFilterMeal(e.target.value); setTimeout(fetchRecipes, 0) }}
          className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none"
        >
          <option value="">Tous repas</option>
          {Object.entries(MEAL_TYPE_LABELS).map(([k, v]) => (
            <option key={k} value={k}>{v}</option>
          ))}
        </select>
      </div>

      {/* Table */}
      {loading ? (
        <div className="text-center py-20 text-gray-400">Chargement…</div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-20 text-gray-400">Aucune recette trouvée</div>
      ) : (
        <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="text-left px-4 py-3 font-medium text-gray-600">Recette</th>
                <th className="text-left px-4 py-3 font-medium text-gray-600">Type</th>
                <th className="text-left px-4 py-3 font-medium text-gray-600">Conditions</th>
                <th className="text-left px-4 py-3 font-medium text-gray-600">Temps</th>
                <th className="px-4 py-3"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.map(recipe => (
                <tr key={recipe.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      {recipe.image_url ? (
                        <img src={recipe.image_url} alt="" className="w-10 h-10 rounded-lg object-cover" />
                      ) : (
                        <div className="w-10 h-10 rounded-lg bg-green-100 flex items-center justify-center text-lg">🥗</div>
                      )}
                      <div>
                        <p className="font-medium">{recipe.title}</p>
                        <p className="text-gray-400 text-xs line-clamp-1">{recipe.description}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className="px-2 py-1 bg-gray-100 rounded-lg text-xs">
                      {MEAL_TYPE_LABELS[recipe.meal_type] ?? recipe.meal_type}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1 flex-wrap">
                      {recipe.conditions.map(c => (
                        <span key={c} className="px-2 py-0.5 bg-green-100 text-green-700 rounded-full text-xs">
                          {CONDITION_LABELS[c] ?? c}
                        </span>
                      ))}
                    </div>
                  </td>
                  <td className="px-4 py-3 text-gray-500">
                    {((recipe.prep_time ?? 0) + (recipe.cook_time ?? 0)) > 0
                      ? `${(recipe.prep_time ?? 0) + (recipe.cook_time ?? 0)} min`
                      : '—'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2 justify-end">
                      <button
                        onClick={() => router.push(`/dashboard/recipes/${recipe.id}`)}
                        className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                        title="Modifier"
                      >
                        <Pencil size={16} />
                      </button>
                      <button
                        onClick={() => deleteRecipe(recipe)}
                        disabled={deleting === recipe.id}
                        className="p-2 hover:bg-red-50 text-red-500 rounded-lg transition-colors disabled:opacity-40"
                        title="Supprimer"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
