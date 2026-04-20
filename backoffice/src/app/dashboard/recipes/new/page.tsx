'use client'

import { useRouter } from 'next/navigation'
import RecipeForm from '@/components/RecipeForm'

export default function NewRecipePage() {
  const router = useRouter()
  return (
    <div className="p-6 max-w-3xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Nouvelle recette</h1>
      <RecipeForm onSuccess={() => router.push('/dashboard/recipes')} />
    </div>
  )
}
