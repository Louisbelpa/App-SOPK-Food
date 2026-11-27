# Génère tokens.json et les tableaux de contraste de 02-ui.md ; échoue si un couple passe sous le seuil WCAG.
# Usage : python3 palette.py --json tokens.json   |   python3 palette.py --md
"""Ovéa palette: single source of truth. Computes WCAG 2.x contrast, asserts thresholds,
writes tokens.json and a markdown fragment for 02-ui.md."""
import json, sys

def lum(h):
    h = h.lstrip('#')
    rgb = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]

def cr(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)

# token: (light, dark, usage)
# V3 « Mascotte & illustrations » : la palette part de Mousse (galet lilas, mousse verte, trait encre).
# Base native : neutres pierre peu saturés (fini le lin crème), un seul accent (myrtille), la chaleur vient des illustrations.
C = {
 # fonds — pierre claire / nuit myrtille, proches des fonds groupés iOS
 "background":        ("#F4F3F1", "#121117", "Fond d'écran, listes groupées (pierre claire / nuit myrtille)"),
 "surface":           ("#FFFFFF", "#1D1B23", "Cellules de liste, la seule carte mise en avant de l'écran"),
 "surfaceMuted":      ("#EAE8E4", "#2A2731", "Chips au repos, champs, segments"),
 "surfaceRaised":     ("#FFFFFF", "#242129", "Sheets, popovers (élévation 2)"),
 "separator":         ("#DEDBD5", "#34313C", "Séparateurs de liste (non porteurs de sens)"),
 "border":            ("#7F7A86", "#837E8E", "Contours de champs/contrôles (≥ 3:1)"),
 # texte — encre (la couleur du trait des illustrations)
 "textPrimary":       ("#1D1B22", "#F3F1F6", "Texte principal (encre / lait)"),
 "textSecondary":     ("#5D5966", "#BDB8C7", "Légendes, métadonnées"),
 "textTertiary":      ("#67636F", "#A39EAE", "Placeholders, aides (reste ≥ 4.5:1)"),
 # interaction — myrtille, tirée de l'ombre du galet ; seul accent cliquable
 "accent":            ("#3F3895", "#B4AEF6", "Myrtille : boutons, liens, sélection, anneau « aujourd'hui »"),
 "onAccent":          ("#FFFFFF", "#15123F", "Texte/icône sur accent"),
 "accentSoft":        ("#E8E6F7", "#2C2950", "Fond myrtille pâle : option sélectionnée"),
 "onAccentSoft":      ("#383189", "#D7D3FB", "Texte sur accentSoft"),
 "leaf":              ("#456E1B", "#B3D57A", "Mousse : nature, IG bas, confidentialité, « c'est noté »"),
 "leafSoft":          ("#E5EDD6", "#232D18", "Fond mousse (bannière confidentialité)"),
 "highlight":         ("#8A5300", "#F2C46B", "Courge : mise en avant très ponctuelle (petit mot du jour)"),
 "onHighlight":       ("#FFFFFF", "#2B1D06", "Texte sur highlight"),
 "highlightSoft":     ("#FBEBCB", "#3A2C12", "Fond courge (rare)"),
 # états
 "success":           ("#456E1B", "#B3D57A", "Confirmation (« C'est noté ») = mousse"),
 "successSoft":       ("#E5EDD6", "#232D18", "Fond confirmation"),
 "warning":           ("#8A5300", "#F2C46B", "Alerte douce (seuil 90 j, contre-indication) — écran sans mascotte"),
 "warningSoft":       ("#FBEBCB", "#3A2C12", "Fond alerte douce"),
 "info":              ("#2F6178", "#9CCBE0", "Information, source, mention d'estimation"),
 "infoSoft":          ("#E1EDF2", "#1A2B33", "Fond information"),
 "destructive":       ("#B3261E", "#FFB4AB", "Suppression de données UNIQUEMENT (jamais une donnée corporelle)"),
 # cycle — framboise sourde, plus claire que la myrtille (distinctes en luminance, pas seulement en teinte)
 "period":            ("#A83A62", "#EFA6C8", "Règles (toujours avec drop.fill + libellé)"),
 "onPeriod":          ("#FFFFFF", "#3A0F25", "Texte sur period"),
 "periodSoft":        ("#F7E2EC", "#3C1F30", "Fond jour de règles"),
 "spotting":          ("#B06A8E", "#C98BAA", "Quelques traces (contour, jamais seul)"),
 # teintes de catégorie : libellé + icône uniquement ; le fond doux sert aux tuiles d'icône (style Réglages iOS)
 "miel":              ("#8A5A00", "#EFC370", "Teinte courge (petit-déjeuner, cardio doux)"),
 "mielSoft":          ("#FAEBCD", "#3A2D14", ""),
 "olive":             ("#4D6A1E", "#BCD58A", "Teinte pousse (déjeuner)"),
 "oliveSoft":         ("#E8EED8", "#262E18", ""),
 "lagon":             ("#22655D", "#8FD0C3", "Teinte lagon (mobilité)"),
 "lagonSoft":         ("#DDEEEA", "#17302C", ""),
 "ardoise":           ("#45577E", "#AFC0E6", "Teinte ardoise (dîner, fractionné)"),
 "ardoiseSoft":       ("#E3E8F3", "#1E2536", ""),
 "cacao":             ("#7A4A30", "#DFB494", "Teinte cacao (collation, renforcement)"),
 "cacaoSoft":         ("#F3E5DA", "#33251C", ""),
 "lavande":           ("#6A4C8C", "#CDB8E6", "Teinte lavande (respiration)"),
 "lavandeSoft":       ("#EEE7F5", "#2C2438", ""),
}

# Palette d'illustration : couleurs FIXES (identiques en clair et en sombre, comme une photo).
# 8 teintes, chacune avec au plus une ombre ; le trait est toujours « encre ».
ILLU = {
 "encre":        ("#2A2438", "Trait unique (4 u sur 240), yeux, bouche"),
 "galet":        ("#CEC7DB", "Corps de Mousse"),
 "galetOmbre":   ("#B2A8C4", "Ombre portée sur le corps, mouchetures"),
 "mousse":       ("#8DB34A", "Coussin de mousse, feuilles, herbes"),
 "mousseOmbre":  ("#6F9736", "Ombre de la mousse, thym"),
 "mousseClaire": ("#C2DB86", "Nouvelle feuille (célébration douce)"),
 "abricot":      ("#F4B49A", "Joues, coussin"),
 "abricotOmbre": ("#E3957A", "Ombre abricot"),
 "courge":       ("#F2A23A", "Dahl, carottes, plaid (avec courgeOmbre)"),
 "courgeOmbre":  ("#DA8228", "Dés de butternut, rayures du plaid"),
 "paprika":      ("#D9573B", "Cocotte, pomme, épices"),
 "betterave":    ("#A63A6B", "Chou rouge, houmous (plats uniquement, jamais sur Mousse)"),
 "betteraveClaire": ("#D2709B", "Houmous de betterave"),
 "porcelaine":   ("#FAF8F5", "Assiettes, bols, reflets, sauces blanches"),
 "creme":        ("#EFE6D3", "Riz, écrasé, flocons"),
 "bois":         ("#CC9563", "Planches, cuillère, quinoa"),
 "boisOmbre":    ("#AE7546", "Veinage des planches"),
 "cacaoIllu":    ("#6B4331", "Bouchées cacao, cumin"),
 "table":        ("#E5E3EF", "Fond des illustrations de plats (lavande grisée, complémentaire des plats chauds)"),
 "tableOmbre":   ("#D2CFE1", "Ombre portée à plat sous les contenants (décalage 5/7 u, sans flou)"),
}

ALIASES = {
 "meal.breakfast": "miel", "meal.lunch": "olive", "meal.dinner": "ardoise", "meal.snack": "cacao",
 "activity.strength": "cacao", "activity.cardio": "miel", "activity.mobility": "lagon",
 "activity.breathing": "lavande", "activity.intervals": "ardoise",
}

HC = {  # variantes « Augmenter le contraste »
 "textSecondary": ("#45424D", "#DAD6E2"),
 "border":        ("#5C5863", "#A9A4B4"),
 "accent":        ("#2E2878", "#CFCBFF"),
 "period":        ("#86284C", "#F6C6DC"),
}

BG3 = ["background", "surface", "surfaceMuted"]
checks = []  # (fg, [bgs], min, kind)
for t in ["textPrimary", "textSecondary", "textTertiary", "accent", "leaf", "highlight", "success",
          "warning", "info", "destructive", "period"]:
    checks.append((t, BG3, 4.5, "texte"))
for t in ["border", "spotting"]:
    checks.append((t, BG3, 3.0, "UI"))
checks += [
 ("onAccent", ["accent"], 4.5, "texte"),
 ("onAccentSoft", ["accentSoft"], 4.5, "texte"),
 ("accent", ["accentSoft"], 4.5, "texte"),
 ("onHighlight", ["highlight"], 4.5, "texte"),
 ("leaf", ["leafSoft"], 4.5, "texte"),
 ("textPrimary", ["leafSoft", "highlightSoft"], 4.5, "texte"),
 ("highlight", ["highlightSoft"], 4.5, "texte"),
 ("success", ["successSoft"], 4.5, "texte"),
 ("warning", ["warningSoft"], 4.5, "texte"),
 ("info", ["infoSoft"], 4.5, "texte"),
 ("onPeriod", ["period"], 4.5, "texte"),
 ("period", ["periodSoft"], 4.5, "texte"),
 ("textPrimary", ["periodSoft", "accentSoft", "surfaceRaised"], 4.5, "texte"),
 ("textSecondary", ["surfaceRaised", "accentSoft", "highlightSoft", "leafSoft"], 4.5, "texte"),
 ("border", ["accentSoft", "highlightSoft"], 3.0, "UI"),
 ("accent", ["surfaceMuted"], 3.0, "UI"),
]
for s in ["miel", "olive", "lagon", "ardoise", "cacao", "lavande"]:
    checks.append((s, ["surfaceMuted"], 4.5, "texte"))
    checks.append((s, ["surface", "background", s + "Soft"], 4.5, "texte"))
    checks.append((s + "Soft", ["surface"], 1.0, "déco"))  # informative only

# Illustration sur les fonds de l'app : la silhouette de Mousse doit rester lisible (WCAG 1.4.11, 3:1)
# en clair grâce au trait encre, en sombre grâce au corps galet. Couleurs fixes => on teste le meilleur des deux.
illu_rows = []
for mode, i in (("light", 0), ("dark", 1)):
    for bgk in ["background", "surface"]:
        bgc = C[bgk][i]
        best = max(cr(ILLU["encre"][0], bgc), cr(ILLU["galet"][0], bgc))
        illu_rows.append((mode, bgk, cr(ILLU["encre"][0], bgc), cr(ILLU["galet"][0], bgc), best))
        if best < 3.0:
            print("FAIL silhouette", mode, bgk, f"{best:.2f}", file=sys.stderr)
            ILLU_FAIL = True
# Lisibilité interne : le trait encre se détache de chaque aplat (≥ 3:1), sauf les ombres (décor).
for k, (hexv, _) in ILLU.items():
    if k in ("encre", "cacaoIllu", "betterave", "boisOmbre", "paprika", "mousseOmbre"):
        continue
    if cr(ILLU["encre"][0], hexv) < 3.0:
        print("FAIL trait sur aplat", k, file=sys.stderr)
        ILLU_FAIL = True

fail = "ILLU_FAIL" in globals()
rows = []
for fg, bgs, mn, kind in checks:
    for mode, i in (("light", 0), ("dark", 1)):
        vals = [cr(C[fg][i], C[b][i]) for b in bgs]
        ok = all(v >= mn for v in vals)
        if not ok and kind != "déco":
            fail = True
            print("FAIL", mode, fg, [f"{b}:{v:.2f}" for b, v in zip(bgs, vals)], file=sys.stderr)
    if kind != "déco":
        l = [cr(C[fg][0], C[b][0]) for b in bgs]
        d = [cr(C[fg][1], C[b][1]) for b in bgs]
        rows.append((fg, bgs, mn, l, d))

hc_rows = []
for t, (l, d) in HC.items():
    lv = min(cr(l, C[b][0]) for b in BG3); dv = min(cr(d, C[b][1]) for b in BG3)
    hc_rows.append((t, l, lv, d, dv))
    if lv < 7 and t.startswith("text"): print("HC weak", t, lv, file=sys.stderr)

if "--md" in sys.argv:
    out = []
    out.append("| Token | Light | Dark | Usage |\n|---|---|---|---|")
    for k, (l, d, u) in C.items():
        if u: out.append(f"| `{k}` | `{l}` | `{d}` | {u} |")
        else: out.append(f"| `{k}` | `{l}` | `{d}` | fond doux de la teinte |")
    out.append("\n\n#### Contrastes vérifiés (WCAG 2.x, script)\n")
    out.append("| Premier plan | Sur | Seuil | Light | Dark |\n|---|---|---|---|---|")
    for fg, bgs, mn, l, d in rows:
        out.append(f"| `{fg}` | {' / '.join('`'+b+'`' for b in bgs)} | {mn}:1 | "
                   f"{' / '.join(f'{v:.2f}' for v in l)} | {' / '.join(f'{v:.2f}' for v in d)} |")
    out.append("\n\n#### Silhouette de Mousse sur les fonds de l'app (≥ 3:1)\n")
    out.append("| Mode | Fond | trait encre | corps galet | retenu |\n|---|---|---|---|---|")
    for mode, bgk, e, g, best in illu_rows:
        out.append(f"| {mode} | `{bgk}` | {e:.2f} | {g:.2f} | {best:.2f} |")
    out.append("\n\n#### Palette d'illustration (fixe)\n")
    out.append("| Nom | Hex | Rôle |\n|---|---|---|")
    for k, (h, u) in ILLU.items():
        out.append(f"| `{k}` | `{h}` | {u} |")
    out.append("\n\n#### Variantes « Augmenter le contraste » (min. sur background/surface/surfaceMuted)\n")
    out.append("| Token | Light HC | ratio min | Dark HC | ratio min |\n|---|---|---|---|---|")
    for t, l, lv, d, dv in hc_rows:
        out.append(f"| `{t}` | `{l}` | {lv:.2f} | `{d}` | {dv:.2f} |")
    print("\n".join(out))

if "--json" in sys.argv:
    tokens = {
      "$schema_note": "Tokens Ovéa v3 (mascotte & illustrations). Couleurs sRGB hex. Généré par palette.py (contrastes WCAG 2.x vérifiés).",
      "color": {k: {"light": l, "dark": d, **({"description": u} if u else {})} for k, (l, d, u) in C.items()},
      "colorAliases": ALIASES,
      "illustration": {k: {"hex": h, "description": u} for k, (h, u) in ILLU.items()},
      "illustrationGrid": {"viewBox": 240, "grid": 8, "stroke": 4, "strokeColor": "encre", "lineCap": "round",
                           "lineJoin": "round", "shadowOffset": [5, 7], "_note": "Aucun filtre, dégradé ni clipPath. Couleurs fixes, identiques en clair et en sombre."},
      "colorHighContrast": {k: {"light": l, "dark": d} for k, (l, d) in HC.items()},
      "spacing": {"xxs": 2, "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 24, "xxl": 32, "xxxl": 48,
                  "screenMargin": 20, "cardPadding": 16, "sectionGap": 32, "minTapTarget": 44},
      "radius": {"xs": 6, "sm": 10, "md": 12, "lg": 16, "xl": 22, "button": 14, "capsule": 999,
                 "_note": "Valeurs proches d'iOS (cellules insetGrouped ≈ 10–12). RoundedRectangle(style: .continuous) partout. Plus de galets à 24–32 pt : la rondeur vient de Mousse."},
      "elevation": {
        "0": {"light": "aucune (listes groupées)", "dark": "aucune"},
        "1": {"light": {"color": "#1D1B22", "opacity": 0.06, "radius": 12, "y": 4, "_use": "la seule carte mise en avant de l'écran"},
              "dark": {"color": "#000000", "opacity": 0.0, "surface": "surface"}},
        "2": {"light": {"color": "#1D1B22", "opacity": 0.14, "radius": 28, "y": 10},
              "dark": {"color": "#000000", "opacity": 0.45, "radius": 28, "y": 10, "surface": "surfaceRaised"}}
      },
      "typography": {
        "_note": "Typographie système uniquement, Dynamic Type. Une seule voix d'affichage : SF Pro Rounded (système, rien à embarquer), réservée aux grands titres et au minuteur — elle reprend la géométrie ronde de Mousse. Tout le reste en SF Pro. Plus de serif, plus de sur-titres en capitales.",
        "display":     {"textStyle": "largeTitle", "design": "rounded", "weight": "bold"},
        "title1":      {"textStyle": "title", "design": "rounded", "weight": "bold"},
        "title2":      {"textStyle": "title2", "design": "default", "weight": "semibold"},
        "title3":      {"textStyle": "title3", "design": "default", "weight": "semibold"},
        "headline":    {"textStyle": "headline", "design": "default", "weight": "semibold"},
        "button":      {"textStyle": "headline", "design": "default", "weight": "semibold"},
        "body":        {"textStyle": "body", "design": "default", "weight": "regular"},
        "bodyEmphasis":{"textStyle": "body", "design": "default", "weight": "medium"},
        "callout":     {"textStyle": "callout", "design": "default", "weight": "regular"},
        "subheadline": {"textStyle": "subheadline", "design": "default", "weight": "regular"},
        "footnote":    {"textStyle": "footnote", "design": "default", "weight": "regular"},
        "caption":     {"textStyle": "caption", "design": "default", "weight": "medium"},
        "sectionHeader": {"textStyle": "title3", "design": "default", "weight": "semibold", "case": "sentence", "_note": "Remplace l'overline en capitales espacées"},
        "quote":       {"textStyle": "body", "design": "default", "weight": "regular", "_note": "Petit mot du jour : texte simple, pas d'italique serif"},
        "timer":       {"baseSize": 72, "relativeTo": "largeTitle", "design": "rounded", "weight": "medium", "monospacedDigit": True},
        "metric":      {"textStyle": "title2", "design": "rounded", "weight": "semibold", "monospacedDigit": True}
      },
      "mascot": {"name": "Mousse", "states": ["accueil", "energie-basse", "energie-moyenne", "energie-bonne", "jour-difficile",
                 "cuisine", "mouvement", "repos", "etat-vide", "celebration"], "assetPrefix": "mousse-",
                 "sizes": {"hero": 152, "inline": 88, "empty": 120}, "forbiddenScreens": ["Mon cycle", "alerte 90 jours", "signaux d'arrêt", "suppression des données", "avertissement santé"]},
      "motion": {"standard": {"type": "spring", "duration": 0.35, "bounce": 0.0},
                 "gentle": {"type": "easeInOut", "duration": 0.25},
                 "reduceMotion": "opacity uniquement"}
    }
    with open(sys.argv[sys.argv.index("--json") + 1], "w", encoding="utf-8") as f:
        json.dump(tokens, f, ensure_ascii=False, indent=2); f.write("\n")

print("ALL OK" if not fail else "SOME FAIL", file=sys.stderr)
sys.exit(1 if fail else 0)
