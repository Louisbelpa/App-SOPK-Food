'use client'

import { useEffect, useState } from 'react'
import { supabase, Profile, CONDITION_LABELS } from '@/lib/supabase'
import { Search, Shield, User } from 'lucide-react'

interface ProfileWithFamily extends Profile {
  family_name?: string | null
}

export default function UsersPage() {
  const [profiles, setProfiles] = useState<ProfileWithFamily[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filterCondition, setFilterCondition] = useState('')

  useEffect(() => { fetchProfiles() }, [])

  async function fetchProfiles() {
    setLoading(true)
    let query = supabase
      .from('profiles')
      .select('*, families(name)')
      .order('created_at', { ascending: false })

    if (filterCondition) query = query.eq('condition', filterCondition)

    const { data } = await query
    const mapped: ProfileWithFamily[] = (data ?? []).map((row: Record<string, unknown>) => ({
      id: row.id as string,
      display_name: row.display_name as string | null,
      condition: row.condition as string | null,
      family_id: row.family_id as string | null,
      role: row.role as string | null,
      created_at: row.created_at as string,
      family_name: (row.families as Record<string, string> | null)?.name ?? null,
    }))
    setProfiles(mapped)
    setLoading(false)
  }

  async function toggleRole(profile: Profile) {
    const newRole = profile.role === 'admin' ? 'member' : 'admin'
    if (!confirm(`Passer ${profile.display_name ?? 'cet utilisateur'} en ${newRole} ?`)) return
    await supabase.from('profiles').update({ role: newRole }).eq('id', profile.id)
    setProfiles(prev => prev.map(p => p.id === profile.id ? { ...p, role: newRole } : p))
  }

  const filtered = profiles.filter(p =>
    (p.display_name ?? '').toLowerCase().includes(search.toLowerCase()) ||
    (p.condition ?? '').toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Utilisateurs</h1>
          <p className="text-gray-500 text-sm">{profiles.length} profil{profiles.length !== 1 ? 's' : ''} enregistré{profiles.length !== 1 ? 's' : ''}</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex gap-3 mb-6 flex-wrap">
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Rechercher un utilisateur…"
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="pl-9 pr-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
          />
        </div>
        <select
          value={filterCondition}
          onChange={e => { setFilterCondition(e.target.value); setTimeout(fetchProfiles, 0) }}
          className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none"
        >
          <option value="">Toutes conditions</option>
          <option value="sopk">SOPK</option>
          <option value="endometriose">Endométriose</option>
          <option value="both">SOPK & Endométriose</option>
        </select>
      </div>

      {/* Table */}
      {loading ? (
        <div className="text-center py-20 text-gray-400">Chargement…</div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-20 text-gray-400">
          <User size={48} className="mx-auto mb-3 opacity-40" />
          <p className="font-medium">Aucun utilisateur trouvé</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="text-left px-5 py-3.5 font-semibold text-gray-600">Utilisateur</th>
                <th className="text-left px-5 py-3.5 font-semibold text-gray-600">Condition</th>
                <th className="text-left px-5 py-3.5 font-semibold text-gray-600">Famille</th>
                <th className="text-left px-5 py-3.5 font-semibold text-gray-600">Rôle</th>
                <th className="text-left px-5 py-3.5 font-semibold text-gray-600">Inscrit le</th>
                <th className="text-left px-5 py-3.5 font-semibold text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.map(profile => (
                <tr key={profile.id} className="hover:bg-gray-50/50 transition-colors">
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-green-100 flex items-center justify-center text-green-700 font-bold text-sm flex-shrink-0">
                        {(profile.display_name ?? 'U').charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">{profile.display_name ?? 'Sans nom'}</p>
                        <p className="text-xs text-gray-400 font-mono truncate max-w-[160px]">{profile.id}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    {profile.condition ? (
                      <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-medium ${
                        profile.condition === 'sopk' ? 'bg-green-50 text-green-700' :
                        profile.condition === 'endometriose' ? 'bg-purple-50 text-purple-700' :
                        'bg-blue-50 text-blue-700'
                      }`}>
                        {CONDITION_LABELS[profile.condition] ?? profile.condition}
                      </span>
                    ) : (
                      <span className="text-gray-400">—</span>
                    )}
                  </td>
                  <td className="px-5 py-4 text-gray-600">
                    {profile.family_name ?? <span className="text-gray-400">—</span>}
                  </td>
                  <td className="px-5 py-4">
                    {profile.role === 'admin' ? (
                      <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-50 text-amber-700">
                        <Shield size={12} /> Admin
                      </span>
                    ) : (
                      <span className="text-gray-500 text-xs">Membre</span>
                    )}
                  </td>
                  <td className="px-5 py-4 text-gray-500">
                    {new Date(profile.created_at).toLocaleDateString('fr-FR')}
                  </td>
                  <td className="px-5 py-4">
                    <button
                      onClick={() => toggleRole(profile)}
                      className="text-xs text-gray-500 hover:text-gray-800 underline underline-offset-2 transition-colors"
                    >
                      {profile.role === 'admin' ? 'Rétrograder' : 'Promouvoir admin'}
                    </button>
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
