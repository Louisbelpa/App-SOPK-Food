'use client'

import { useState } from 'react'
import { supabase, Recipe, Ingredient, Step, CONDITIONS, MEAL_TYPES, MEAL_TYPE_LABELS, CONDITION_LABELS, INGREDIENT_CATEGORIES } from '@/lib/supabase'
import { Plus, Trash2, GripVertical } from 'lucide-react'

interface Props {
  recipe?: Recipe & { ingredients: Ingredient[], steps: Step[] }
  onSuccess: () => void
}

interface FormErrors {
  title?: string
  prepTime?: string
  cookTime?: string
  conditions?: string
}

function validatePositiveInteger(value: string, fieldName: string): string | undefined {
  if (value === '') return undefined
  const num = Number(value)
  if (!Number.isInteger(num) || num < 0) {
    return `${fieldName} doit être un entier positif ou nul`
  }
  return undefined
}

export default function RecipeForm({ recipe, onSuccess }: Props) {
  const isEdit = !!recipe

  const [title, setTitle] = useState(recipe?.title ?? '')
  const [description, setDescription] = useState(recipe?.description ?? '')
  const [prepTime, setPrepTime] = useState(recipe?.prep_time?.toString() ?? '')
  const [cookTime, setCookTime] = useState(recipe?.cook_time?.toString() ?? '')
  const [servings, setServings] = useState(recipe?.servings?.toString() ?? '')
  const [mealType, setMealType] = useState(recipe?.meal_type ?? 'lunch')
  const [conditions, setConditions] = useState<string[]>(recipe?.conditions ?? [])
  const [tags, setTags] = useState(recipe?.tags?.join(', ') ?? '')
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState(recipe?.image_url ?? '')
  const [ingredients, setIngredients] = useState<Omit<Ingredient, 'id' | 'recipe_id'>[]>(
    recipe?.ingredients.map(i => ({ name: i.name, quantity: i.quantity, unit: i.unit, category: i.category })) ?? [{ name: '', quantity: null, unit: '', category: 'légumes' }]
  )
  const [steps, setSteps] = useState<string[]>(
    recipe?.steps.map(s => s.instruction) ?? ['']
  )
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [fieldErrors, setFieldErrors] = useState<FormErrors>({})
  const [touched, setTouched] = useState<Record<string, boolean>>({})

  function validateForm(): FormErrors {
    const errors: FormErrors = {}

    if (!title.trim()) {
      errors.title = 'Le titre est obligatoire'
    } else if (title.trim().length < 3) {
      errors.title = 'Le titre doit contenir au moins 3 caractères'
    }

    const prepTimeError = validatePositiveInteger(prepTime, 'Le temps de préparation')
    if (prepTimeError) errors.prepTime = prepTimeError

    const cookTimeError = validatePositiveInteger(cookTime, 'Le temps de cuisson')
    if (cookTimeError) errors.cookTime = cookTimeError

    if (conditions.length === 0) {
      errors.conditions = 'Sélectionnez au moins une condition'
    }

    return errors
  }

  function handleBlur(field: string) {
    setTouched(prev => ({ ...prev, [field]: true }))
    const errors = validateForm()
    setFieldErrors(errors)
  }

  function toggleCondition(c: string) {
    const next = conditions.includes(c) ? conditions.filter(x => x !== c) : [...conditions, c]
    setConditions(next)
    if (touched.conditions) {
      setFieldErrors(prev => ({
        ...prev,
        conditions: next.length === 0 ? 'Sélectionnez au moins une condition' : undefined,
      }))
    }
  }

  function handleImageChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return
    setImageFile(file)
    setImagePreview(URL.createObjectURL(file))
  }

  async function uploadImage(file: File): Promise<string> {
    const ext = file.name.split('.').pop()
    const path = `${Date.now()}.${ext}`
    const { error } = await supabase.storage.from('recipe-images').upload(path, file)
    if (error) throw error
    const { data } = supabase.storage.from('recipe-images').getPublicUrl(path)
    return data.publicUrl
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError('')

    // Mark all validatable fields as touched and run full validation
    setTouched({ title: true, prepTime: true, cookTime: true, conditions: true })
    const errors = validateForm()
    setFieldErrors(errors)
    if (Object.keys(errors).length > 0) return

    setSaving(true)

    try {
      let imageUrl = recipe?.image_url ?? null
      if (imageFile) imageUrl = await uploadImage(imageFile)

      const payload = {
        title,
        description: description || null,
        image_url: imageUrl,
        prep_time: prepTime ? parseInt(prepTime) : null,
        cook_time: cookTime ? parseInt(cookTime) : null,
        servings: servings ? parseInt(servings) : null,
        meal_type: mealType,
        conditions,
        tags: tags.split(',').map(t => t.trim()).filter(Boolean),
      }

      let recipeId = recipe?.id
      if (isEdit) {
        await supabase.from('recipes').update(payload).eq('id', recipeId!)
        await supabase.from('ingredients').delete().eq('recipe_id', recipeId!)
        await supabase.from('steps').delete().eq('recipe_id', recipeId!)
      } else {
        const { data, error } = await supabase.from('recipes').insert(payload).select().single()
        if (error) throw error
        recipeId = data.id
      }

      const validIngredients = ingredients.filter(i => i.name.trim())
      if (validIngredients.length > 0) {
        await supabase.from('ingredients').insert(
          validIngredients.map(i => ({ ...i, recipe_id: recipeId }))
        )
      }

      const validSteps = steps.filter(s => s.trim())
      if (validSteps.length > 0) {
        await supabase.from('steps').insert(
          validSteps.map((instruction, idx) => ({ recipe_id: recipeId, position: idx + 1, instruction }))
        )
      }

      onSuccess()
    } catch (err: any) {
      setError(err.message ?? 'Une erreur est survenue')
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      {/* Infos générales */}
      <section className="bg-white rounded-2xl p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-lg">Informations générales</h2>

        <div>
          <label className="block text-sm font-medium mb-1">Titre *</label>
          <input
            type="text"
            value={title}
            onChange={e => {
              setTitle(e.target.value)
              if (touched.title) {
                const val = e.target.value.trim()
                setFieldErrors(prev => ({
                  ...prev,
                  title: !val
                    ? 'Le titre est obligatoire'
                    : val.length < 3
                    ? 'Le titre doit contenir au moins 3 caractères'
                    : undefined,
                }))
              }
            }}
            onBlur={() => handleBlur('title')}
            className={`w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 ${
              fieldErrors.title ? 'border-red-400' : 'border-gray-200'
            }`}
            placeholder="Ex : Smoothie anti-inflammatoire au curcuma"
          />
          {fieldErrors.title && (
            <p className="mt-1 text-xs text-red-500">{fieldErrors.title}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Description</label>
          <textarea
            value={description} onChange={e => setDescription(e.target.value)} rows={3}
            className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 resize-none"
          />
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div>
            <label className="block text-sm font-medium mb-1">Prép. (min)</label>
            <input
              type="number"
              value={prepTime}
              onChange={e => {
                setPrepTime(e.target.value)
                if (touched.prepTime) {
                  setFieldErrors(prev => ({
                    ...prev,
                    prepTime: validatePositiveInteger(e.target.value, 'Le temps de préparation'),
                  }))
                }
              }}
              onBlur={() => handleBlur('prepTime')}
              min="0"
              step="1"
              className={`w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 ${
                fieldErrors.prepTime ? 'border-red-400' : 'border-gray-200'
              }`}
            />
            {fieldErrors.prepTime && (
              <p className="mt-1 text-xs text-red-500">{fieldErrors.prepTime}</p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Cuisson (min)</label>
            <input
              type="number"
              value={cookTime}
              onChange={e => {
                setCookTime(e.target.value)
                if (touched.cookTime) {
                  setFieldErrors(prev => ({
                    ...prev,
                    cookTime: validatePositiveInteger(e.target.value, 'Le temps de cuisson'),
                  }))
                }
              }}
              onBlur={() => handleBlur('cookTime')}
              min="0"
              step="1"
              className={`w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 ${
                fieldErrors.cookTime ? 'border-red-400' : 'border-gray-200'
              }`}
            />
            {fieldErrors.cookTime && (
              <p className="mt-1 text-xs text-red-500">{fieldErrors.cookTime}</p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Portions</label>
            <input type="number" value={servings} onChange={e => setServings(e.target.value)} min="1"
              className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500" />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Type de repas *</label>
          <select value={mealType} onChange={e => setMealType(e.target.value)}
            className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none">
            {MEAL_TYPES.map(t => <option key={t} value={t}>{MEAL_TYPE_LABELS[t]}</option>)}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium mb-2">Conditions ciblées *</label>
          <div className="flex gap-3 flex-wrap">
            {CONDITIONS.map(c => (
              <button key={c} type="button" onClick={() => toggleCondition(c)}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${conditions.includes(c) ? 'bg-green-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>
                {CONDITION_LABELS[c]}
              </button>
            ))}
          </div>
          {fieldErrors.conditions && (
            <p className="mt-2 text-xs text-red-500">{fieldErrors.conditions}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Tags (séparés par des virgules)</label>
          <input type="text" value={tags} onChange={e => setTags(e.target.value)}
            placeholder="oméga-3, curcuma, faible IG, sans gluten…"
            className="w-full px-4 py-2.5 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500" />
        </div>
      </section>

      {/* Image */}
      <section className="bg-white rounded-2xl p-6 shadow-sm space-y-4">
        <h2 className="font-semibold text-lg">Image</h2>
        <input type="file" accept="image/*" onChange={handleImageChange}
          className="text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:bg-green-50 file:text-green-700 hover:file:bg-green-100" />
        {imagePreview && (
          <img src={imagePreview} alt="Aperçu" className="w-full h-48 object-cover rounded-xl" />
        )}
      </section>

      {/* Ingrédients */}
      <section className="bg-white rounded-2xl p-6 shadow-sm space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="font-semibold text-lg">Ingrédients</h2>
          <button type="button" onClick={() => setIngredients(prev => [...prev, { name: '', quantity: null, unit: '', category: 'légumes' }])}
            className="flex items-center gap-1 text-sm text-green-600 hover:text-green-700">
            <Plus size={16} /> Ajouter
          </button>
        </div>
        <div className="space-y-2">
          {ingredients.map((ing, idx) => (
            <div key={idx} className="flex gap-2 items-center">
              <input value={ing.name} onChange={e => setIngredients(prev => prev.map((x, i) => i === idx ? { ...x, name: e.target.value } : x))}
                placeholder="Ingrédient" className="flex-1 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-green-500" />
              <input type="number" value={ing.quantity ?? ''} onChange={e => setIngredients(prev => prev.map((x, i) => i === idx ? { ...x, quantity: e.target.value ? parseFloat(e.target.value) : null } : x))}
                placeholder="Qté" className="w-20 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none" />
              <input value={ing.unit ?? ''} onChange={e => setIngredients(prev => prev.map((x, i) => i === idx ? { ...x, unit: e.target.value } : x))}
                placeholder="Unité" className="w-20 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none" />
              <select value={ing.category ?? 'légumes'} onChange={e => setIngredients(prev => prev.map((x, i) => i === idx ? { ...x, category: e.target.value } : x))}
                className="px-2 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none">
                {INGREDIENT_CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
              </select>
              <button type="button" onClick={() => setIngredients(prev => prev.filter((_, i) => i !== idx))}
                className="p-2 text-red-400 hover:text-red-600">
                <Trash2 size={16} />
              </button>
            </div>
          ))}
        </div>
      </section>

      {/* Étapes */}
      <section className="bg-white rounded-2xl p-6 shadow-sm space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="font-semibold text-lg">Étapes</h2>
          <button type="button" onClick={() => setSteps(prev => [...prev, ''])}
            className="flex items-center gap-1 text-sm text-green-600 hover:text-green-700">
            <Plus size={16} /> Ajouter
          </button>
        </div>
        <div className="space-y-3">
          {steps.map((step, idx) => (
            <div key={idx} className="flex gap-2 items-start">
              <span className="mt-2.5 text-sm font-bold text-gray-400 w-6 text-center">{idx + 1}</span>
              <textarea value={step} onChange={e => setSteps(prev => prev.map((s, i) => i === idx ? e.target.value : s))}
                rows={2} placeholder={`Étape ${idx + 1}…`}
                className="flex-1 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-green-500 resize-none" />
              <button type="button" onClick={() => setSteps(prev => prev.filter((_, i) => i !== idx))}
                className="mt-1 p-2 text-red-400 hover:text-red-600">
                <Trash2 size={16} />
              </button>
            </div>
          ))}
        </div>
      </section>

      {error && <p className="text-red-500 text-sm">{error}</p>}

      <div className="flex gap-3">
        <button type="submit" disabled={saving}
          className="flex-1 py-3 bg-green-600 hover:bg-green-700 text-white rounded-xl font-semibold transition-colors disabled:opacity-50">
          {saving ? 'Enregistrement…' : isEdit ? 'Mettre à jour' : 'Créer la recette'}
        </button>
      </div>
    </form>
  )
}
