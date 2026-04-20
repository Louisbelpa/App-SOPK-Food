import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Types matching the database schema
export interface Recipe {
  id: string
  title: string
  description: string | null
  image_url: string | null
  prep_time: number | null
  cook_time: number | null
  servings: number | null
  conditions: string[]
  meal_type: string
  tags: string[]
  created_at: string
}

export interface Ingredient {
  id: string
  recipe_id: string
  name: string
  quantity: number | null
  unit: string | null
  category: string | null
}

export interface Step {
  id: string
  recipe_id: string
  position: number
  instruction: string
}

export interface Profile {
  id: string
  display_name: string | null
  condition: string | null
  family_id: string | null
  role: string | null
  created_at: string
}

export interface Family {
  id: string
  name: string
  invite_code: string
  created_by: string | null
  created_at: string
}

export interface MealPlanEntry {
  id: string
  family_id: string
  recipe_id: string
  date: string
  meal_type: string
  added_by: string | null
}

export interface ShoppingItem {
  id: string
  family_id: string
  name: string
  quantity: number | null
  unit: string | null
  category: string | null
  is_checked: boolean
  added_by: string | null
  created_at: string
}

export const CONDITIONS = ['sopk', 'endometriose'] as const
export const MEAL_TYPES = ['breakfast', 'lunch', 'dinner', 'snack'] as const
export const MEAL_TYPE_LABELS: Record<string, string> = {
  breakfast: 'Petit-déjeuner',
  lunch: 'Déjeuner',
  dinner: 'Dîner',
  snack: 'Snack',
}
export const CONDITION_LABELS: Record<string, string> = {
  sopk: 'SOPK',
  endometriose: 'Endométriose',
  both: 'SOPK & Endométriose',
}
export const INGREDIENT_CATEGORIES = [
  'légumes', 'protéines', 'céréales', 'produits laitiers',
  'épices', 'matières grasses', 'fruits', 'autre',
]

