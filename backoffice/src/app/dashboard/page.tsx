'use client'

import { useEffect, useState } from 'react'
import { supabase, CONDITION_LABELS } from '@/lib/supabase'
import { UtensilsCrossed, Users, CalendarDays, ShoppingCart, TrendingUp, Clock } from 'lucide-react'

interface Stats {
  recipes: number
  users: number
  mealPlanEntries: number
  shoppingItems: number
  recipesBySopk: number
  recipesByEndo: number
  recentRecipes: Array<{ id: string; title: string; conditions: string[]; created_at: string }>
  recentUsers: Array<{ id: string; display_name: string | null; condition: string | null; created_at: string }>
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchStats() {
      const [
        { count: recipes },
        { count: users },
        { count: mealPlanEntries },
        { count: shoppingItems },
        { count: recipesBySopk },
        { count: recipesByEndo },
        { data: recentRecipes },
        { data: recentUsers },
      ] = await Promise.all([
        supabase.from('recipes').select('*', { count: 'exact', head: true }),
        supabase.from('profiles').select('*', { count: 'exact', head: true }),
        supabase.from('meal_plan_entries').select('*', { count: 'exact', head: true }),
        supabase.from('shopping_items').select('*', { count: 'exact', head: true }),
        supabase.from('recipes').select('*', { count: 'exact', head: true }).contains('conditions', ['sopk']),
        supabase.from('recipes').select('*', { count: 'exact', head: true }).contains('conditions', ['endometriose']),
        supabase.from('recipes').select('id, title, conditions, created_at').order('created_at', { ascending: false }).limit(5),
        supabase.from('profiles').select('id, display_name, condition, created_at').order('created_at', { ascending: false }).limit(5),
      ])

      setStats({
        recipes: recipes ?? 0,
        users: users ?? 0,
        mealPlanEntries: mealPlanEntries ?? 0,
        shoppingItems: shoppingItems ?? 0,
        recipesBySopk: recipesBySopk ?? 0,
        recipesByEndo: recipesByEndo ?? 0,
        recentRecipes: (recentRecipes ?? []) as Stats['recentRecipes'],
        recentUsers: (recentUsers ?? []) as Stats['recentUsers'],
      })
      setLoading(false)
    }
    fetchStats()
  }, [])

  if (loading) return (
    <div className="p-6 text-center text-gray-400 py-20">Chargement des statistiques…</div>
  )

  const statCards = [
    { label: 'Recettes', value: stats?.recipes ?? 0, icon: UtensilsCrossed, color: 'text-green-600', bg: 'bg-green-50' },
    { label: 'Utilisateurs', value: stats?.users ?? 0, icon: Users, color: 'text-blue-600', bg: 'bg-blue-50' },
    { label: 'Entrées planning', value: stats?.mealPlanEntries ?? 0, icon: CalendarDays, color: 'text-purple-600', bg: 'bg-purple-50' },
    { label: 'Articles courses', value: stats?.shoppingItems ?? 0, icon: ShoppingCart, color: 'text-orange-600', bg: 'bg-orange-50' },
  ]

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Tableau de bord</h1>
        <p className="text-gray-500 text-sm mt-1">Vue d&apos;ensemble de l&apos;application Nourrir</p>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map(card => (
          <div key={card.label} className="bg-white rounded-2xl border border-gray-100 p-5">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm text-gray-500">{card.label}</p>
                <p className="text-3xl font-bold mt-1">{card.value}</p>
              </div>
              <div className={`${card.bg} ${card.color} p-2.5 rounded-xl`}>
                <card.icon size={20} />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Condition breakdown */}
      <div className="bg-white rounded-2xl border border-gray-100 p-5">
        <h2 className="font-semibold mb-4 flex items-center gap-2">
          <TrendingUp size={18} className="text-green-600" />
          Répartition par condition
        </h2>
        <div className="grid grid-cols-2 gap-4">
          {[
            { label: 'SOPK', count: stats?.recipesBySopk ?? 0, total: stats?.recipes ?? 1, color: 'bg-green-500' },
            { label: 'Endométriose', count: stats?.recipesByEndo ?? 0, total: stats?.recipes ?? 1, color: 'bg-purple-500' },
          ].map(c => (
            <div key={c.label}>
              <div className="flex justify-between text-sm mb-1">
                <span className="font-medium">{c.label}</span>
                <span className="text-gray-500">{c.count} recettes</span>
              </div>
              <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                <div
                  className={`h-full ${c.color} rounded-full transition-all`}
                  style={{ width: `${Math.round((c.count / c.total) * 100)}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent recipes */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h2 className="font-semibold mb-4 flex items-center gap-2">
            <Clock size={18} className="text-green-600" />
            Dernières recettes
          </h2>
          <div className="space-y-3">
            {stats?.recentRecipes.map(r => (
              <div key={r.id} className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium">{r.title}</p>
                  <div className="flex gap-1 mt-0.5">
                    {r.conditions.map(c => (
                      <span key={c} className="text-xs text-gray-400 bg-gray-50 px-2 py-0.5 rounded-full">
                        {CONDITION_LABELS[c] ?? c}
                      </span>
                    ))}
                  </div>
                </div>
                <span className="text-xs text-gray-400">
                  {new Date(r.created_at).toLocaleDateString('fr-FR')}
                </span>
              </div>
            ))}
            {!stats?.recentRecipes.length && (
              <p className="text-sm text-gray-400">Aucune recette pour l&apos;instant</p>
            )}
          </div>
        </div>

        {/* Recent users */}
        <div className="bg-white rounded-2xl border border-gray-100 p-5">
          <h2 className="font-semibold mb-4 flex items-center gap-2">
            <Users size={18} className="text-blue-600" />
            Derniers utilisateurs
          </h2>
          <div className="space-y-3">
            {stats?.recentUsers.map(u => (
              <div key={u.id} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center text-green-700 font-bold text-sm">
                    {(u.display_name ?? 'U').charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <p className="text-sm font-medium">{u.display_name ?? 'Sans nom'}</p>
                    <p className="text-xs text-gray-400">{u.condition ? CONDITION_LABELS[u.condition] ?? u.condition : '—'}</p>
                  </div>
                </div>
                <span className="text-xs text-gray-400">
                  {new Date(u.created_at).toLocaleDateString('fr-FR')}
                </span>
              </div>
            ))}
            {!stats?.recentUsers.length && (
              <p className="text-sm text-gray-400">Aucun utilisateur pour l&apos;instant</p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
