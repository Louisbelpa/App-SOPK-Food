# Outils copy

`strings.src.json` est la source des textes de l'app. **Ne pas éditer `../strings.fr.json` à la main.**

```bash
python3 build.py strings.src.json ../strings.fr.json   # typographie française (’, espaces insécables, …)
python3 check.py ../strings.fr.json                    # mots bannis, notifications, emojis, accords, longueurs
```
`check.py` signale aussi des avertissements (`LONG BUTTON`, `GENDER?`) à relire à la main.
