-- Migration : ajout des champs santé sur profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS last_period_date DATE,
  ADD COLUMN IF NOT EXISTS cycle_length     INT DEFAULT 28 CHECK (cycle_length BETWEEN 21 AND 45),
  ADD COLUMN IF NOT EXISTS symptoms         TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS avoid_tags       TEXT[] DEFAULT '{}';
