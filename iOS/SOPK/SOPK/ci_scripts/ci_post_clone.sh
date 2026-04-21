#!/bin/sh

# Xcode Cloud — post-clone script
# Génère Secrets.xcconfig depuis les variables d'env Xcode Cloud
# (SUPABASE_URL et SUPABASE_ANON_KEY à configurer dans le workflow Xcode Cloud)

set -e

SECRETS_FILE="$CI_PRIMARY_REPOSITORY_PATH/iOS/SOPK/SOPK/Secrets.xcconfig"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "Erreur : SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis dans les variables d'environnement Xcode Cloud."
  exit 1
fi

cat > "$SECRETS_FILE" <<EOF
SUPABASE_URL = $SUPABASE_URL
SUPABASE_ANON_KEY = $SUPABASE_ANON_KEY
EOF

echo "Secrets.xcconfig généré avec succès."
