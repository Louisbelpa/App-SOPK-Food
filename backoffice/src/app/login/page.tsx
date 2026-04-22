'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      setError('Email ou mot de passe incorrect')
      setLoading(false)
      return
    }

    // Vérifier le rôle admin
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) { setError('Utilisateur introuvable'); setLoading(false); return }

    const { data: profile, error: profileError } = await supabase.from('profiles').select('role').eq('id', user.id).single()
    if (profileError || profile?.role !== 'admin') {
      await supabase.auth.signOut()
      setError(profileError ? `Erreur profil: ${profileError.message}` : 'Accès réservé aux administrateurs')
      setLoading(false)
      return
    }

    router.push('/dashboard/recipes')
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="bg-white p-8 rounded-2xl shadow-sm w-full max-w-sm">
        <div className="text-center mb-8">
          <span className="text-5xl">🥗</span>
          <h1 className="text-2xl font-bold mt-3">SOPK Admin</h1>
          <p className="text-gray-500 text-sm mt-1">Back office — Gestion des recettes</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-4">
          <input
            type="email"
            placeholder="Email admin"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
          />
          <input
            type="password"
            placeholder="Mot de passe"
            value={password}
            onChange={e => setPassword(e.target.value)}
            required
            className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500"
          />
          {error && <p className="text-red-500 text-sm">{error}</p>}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-green-600 hover:bg-green-700 text-white rounded-xl font-semibold transition-colors disabled:opacity-50"
          >
            {loading ? 'Connexion…' : 'Se connecter'}
          </button>
        </form>
      </div>
    </div>
  )
}
