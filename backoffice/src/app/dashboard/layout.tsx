'use client'

import { useEffect, useState } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import Link from 'next/link'
import { supabase } from '@/lib/supabase'
import { UtensilsCrossed, LogOut, LayoutDashboard, Users } from 'lucide-react'

const navItems = [
  { href: '/dashboard', label: 'Tableau de bord', icon: LayoutDashboard },
  { href: '/dashboard/recipes', label: 'Recettes', icon: UtensilsCrossed },
  { href: '/dashboard/users', label: 'Utilisateurs', icon: Users },
]

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()
  const [checking, setChecking] = useState(true)

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) { router.push('/login'); return }
      setChecking(false)
    })
  }, [router])

  async function logout() {
    await supabase.auth.signOut()
    router.push('/login')
  }

  if (checking) return <div className="min-h-screen flex items-center justify-center text-gray-400">Vérification…</div>

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <aside className="w-56 bg-white border-r border-gray-100 flex flex-col">
        <div className="p-5 border-b border-gray-100">
          <div className="flex items-center gap-2">
            <span className="text-2xl">🥗</span>
            <div>
              <p className="font-bold text-sm">Nourrir Admin</p>
              <p className="text-xs text-gray-400">Back office</p>
            </div>
          </div>
        </div>

        <nav className="flex-1 p-3 space-y-1">
          {navItems.map(item => {
            const isActive = pathname === item.href || (item.href !== '/dashboard' && pathname.startsWith(item.href))
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-2 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-green-50 text-green-700'
                    : 'text-gray-600 hover:bg-gray-50'
                }`}
              >
                <item.icon size={18} />
                {item.label}
              </Link>
            )
          })}
        </nav>

        <div className="p-3 border-t border-gray-100">
          <button onClick={logout}
            className="flex items-center gap-2 w-full px-3 py-2.5 rounded-xl text-sm text-gray-500 hover:bg-gray-50 transition-colors">
            <LogOut size={18} />
            Déconnexion
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  )
}
