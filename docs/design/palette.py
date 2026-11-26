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
C = {
 # fonds — V2 « cosy » : lin, mie de pain, chocolat
 "background":        ("#FBF3E7", "#1C1512", "Fond d'écran (lin ensoleillé / chocolat noir)"),
 "surface":           ("#FFFAF2", "#271E1A", "Cartes, listes groupées (blanc crème, jamais #FFF pur)"),
 "surfaceMuted":      ("#F4E7D5", "#33281F", "Chips au repos, champs, segments (lin)"),
 "surfaceRaised":     ("#FFFCF7", "#2E241F", "Sheets, popovers (élévation 2)"),
 "separator":         ("#EEE1CF", "#3A2E27", "Filets décoratifs, très discrets (non porteurs de sens)"),
 "border":            ("#937F69", "#8F7D6F", "Contours de champs/contrôles (≥ 3:1)"),
 # texte — bruns chauds au lieu de vert-de-gris
 "textPrimary":       ("#2F221B", "#F6EBDD", "Texte principal (espresso / crème)"),
 "textSecondary":     ("#6A5545", "#CDBBA9", "Légendes, métadonnées"),
 "textTertiary":      ("#6F5B4B", "#AA988A", "Placeholders, aides (reste ≥ 4.5:1)"),
 # interaction — terracotta « argile cuite » devient l'accent
 "accent":            ("#A1482A", "#F0A27D", "Terracotta : boutons, liens, sélection, anneau « aujourd'hui »"),
 "onAccent":          ("#FFFFFF", "#2B1307", "Texte/icône sur accent"),
 "accentSoft":        ("#F9E3D5", "#45291D", "Fond abricot : chip sélectionnée, carte check-in"),
 "onAccentSoft":      ("#7A3219", "#F9C5AA", "Texte sur accentSoft"),
 "leaf":              ("#556A2C", "#BFD08F", "Sauge dorée : nature, IG bas, confidentialité, réussite"),
 "leafSoft":          ("#EBEDD5", "#2E3119", "Fond sauge dorée"),
 "highlight":         ("#855810", "#EDC47C", "Miel : petit mot du jour, mise en avant ponctuelle"),
 "onHighlight":       ("#FFFFFF", "#2B1D06", "Texte sur highlight"),
 "highlightSoft":     ("#FBEACB", "#3D2E17", "Fond miel"),
 # états
 "success":           ("#4E6727", "#BBCD8C", "Confirmation (« C'est noté »)"),
 "successSoft":       ("#E9EDD3", "#2C301B", "Fond confirmation"),
 "warning":           ("#8A5300", "#F0C173", "Alerte douce (seuil 90 j, contre-indication)"),
 "warningSoft":       ("#FCEBCB", "#3D2C12", "Fond alerte douce"),
 "info":              ("#3D5F6B", "#A2C8D0", "Information, source, mention d'estimation (bleu-gris chaud)"),
 "infoSoft":          ("#E4ECE9", "#1F2E30", "Fond information"),
 "destructive":       ("#A3172B", "#FFB1AA", "Suppression de données UNIQUEMENT (jamais une donnée corporelle)"),
 # cycle — prune, nettement distincte du terracotta
 "period":            ("#86345F", "#E8A5C5", "Règles (toujours avec drop.fill + libellé)"),
 "onPeriod":          ("#FFFFFF", "#3A0F25", "Texte sur period"),
 "periodSoft":        ("#F6E2EA", "#3F2131", "Fond jour de règles"),
 "spotting":          ("#A9688A", "#CA8DAC", "Quelques traces (contour, jamais seul)"),
 # teintes de saison (catégories)
 "miel":              ("#7E5512", "#E7C37D", "Teinte miel"),
 "mielSoft":          ("#F9EACB", "#3B2D17", ""),
 "olive":             ("#566529", "#C3CF8F", "Teinte olive"),
 "oliveSoft":         ("#EDECD2", "#2F3019", ""),
 "lagon":             ("#2C625C", "#8ECFC2", "Teinte lagon (vert d'eau chaud)"),
 "lagonSoft":         ("#DFEDE6", "#1C3230", ""),
 "ardoise":           ("#544878", "#C0B6E4", "Teinte ardoise (bleu nuit tirant sur la prune)"),
 "ardoiseSoft":       ("#EDE5EC", "#30273A", ""),
 "cacao":             ("#74482F", "#DEB391", "Teinte cacao"),
 "cacaoSoft":         ("#F3E3D6", "#3A281D", ""),
 "lavande":           ("#694E86", "#CEB9E3", "Teinte lavande"),
 "lavandeSoft":       ("#EFE5F1", "#31263A", ""),
}

ALIASES = {
 "meal.breakfast": "miel", "meal.lunch": "olive", "meal.dinner": "ardoise", "meal.snack": "cacao",
 "activity.strength": "cacao", "activity.cardio": "miel", "activity.mobility": "lagon",
 "activity.breathing": "lavande", "activity.intervals": "ardoise",
}

HC = {  # variantes « Augmenter le contraste »
 "textSecondary": ("#4E3D31", "#E3D5C6"),
 "border":        ("#64543F", "#B3A294"),
 "accent":        ("#7E3418", "#F8BE9F"),
 "period":        ("#6B2149", "#F3C2D9"),
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
    checks.append((s, ["surface", "background", s + "Soft"], 4.5, "texte"))
    checks.append((s + "Soft", ["surface"], 1.0, "déco"))  # informative only

fail = False
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
    out.append("\n\n#### Variantes « Augmenter le contraste » (min. sur background/surface/surfaceMuted)\n")
    out.append("| Token | Light HC | ratio min | Dark HC | ratio min |\n|---|---|---|---|---|")
    for t, l, lv, d, dv in hc_rows:
        out.append(f"| `{t}` | `{l}` | {lv:.2f} | `{d}` | {dv:.2f} |")
    print("\n".join(out))

if "--json" in sys.argv:
    tokens = {
      "$schema_note": "Tokens Ovéa v2 (direction cosy). Couleurs sRGB hex. Généré par script de contraste (WCAG 2.x).",
      "color": {k: {"light": l, "dark": d, **({"description": u} if u else {})} for k, (l, d, u) in C.items()},
      "colorAliases": ALIASES,
      "colorHighContrast": {k: {"light": l, "dark": d} for k, (l, d) in HC.items()},
      "spacing": {"xxs": 2, "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 24, "xxl": 32, "xxxl": 48,
                  "screenMargin": 20, "cardPadding": 16, "sectionGap": 32, "minTapTarget": 44},
      "radius": {"xs": 8, "sm": 12, "md": 18, "lg": 24, "xl": 32, "button": 999, "capsule": 999,
                 "_note": "RoundedRectangle(style: .continuous) partout"},
      "elevation": {
        "0": {"light": "aucune", "dark": "aucune"},
        "1": {"light": {"color": "#5C341C", "opacity": 0.07, "radius": 20, "y": 8, "plus": {"opacity": 0.04, "radius": 2, "y": 1}},
              "dark": {"color": "#000000", "opacity": 0.28, "radius": 16, "y": 6, "surface": "surface"}},
        "2": {"light": {"color": "#5C341C", "opacity": 0.12, "radius": 32, "y": 12},
              "dark": {"color": "#000000", "opacity": 0.40, "radius": 28, "y": 10, "surface": "surfaceRaised"}}
      },
      "typography": {
        "_note": "Dynamic Type uniquement. family=Fraunces (OFL, embarquée, axe SOFT=100, opsz auto) avec repli New York ; default => SF Pro ; rounded => SF Pro Rounded.",
        "display":     {"textStyle": "largeTitle", "family": "Fraunces", "fallbackDesign": "serif", "weight": "semibold", "soft": 100},
        "title1":      {"textStyle": "title", "family": "Fraunces", "fallbackDesign": "serif", "weight": "semibold", "soft": 100},
        "title2":      {"textStyle": "title2", "family": "Fraunces", "fallbackDesign": "serif", "weight": "semibold", "soft": 100},
        "title3":      {"textStyle": "title3", "design": "default", "weight": "semibold"},
        "headline":    {"textStyle": "headline", "design": "default", "weight": "semibold"},
        "button":      {"textStyle": "headline", "design": "rounded", "weight": "semibold"},
        "body":        {"textStyle": "body", "design": "default", "weight": "regular"},
        "bodyEmphasis":{"textStyle": "body", "design": "default", "weight": "medium"},
        "callout":     {"textStyle": "callout", "design": "default", "weight": "regular"},
        "subheadline": {"textStyle": "subheadline", "design": "default", "weight": "regular"},
        "footnote":    {"textStyle": "footnote", "design": "default", "weight": "regular"},
        "caption":     {"textStyle": "caption", "design": "default", "weight": "medium"},
        "overline":    {"textStyle": "caption2", "design": "default", "weight": "semibold", "tracking": 0.6, "case": "uppercase"},
        "quote":       {"textStyle": "title3", "family": "Fraunces", "fallbackDesign": "serif", "weight": "regular", "italic": True, "soft": 100},
        "timer":       {"baseSize": 72, "relativeTo": "largeTitle", "design": "rounded", "weight": "light", "monospacedDigit": True},
        "metric":      {"textStyle": "title2", "design": "rounded", "weight": "semibold", "monospacedDigit": True}
      },
      "motion": {"standard": {"type": "spring", "duration": 0.35, "bounce": 0.0},
                 "gentle": {"type": "easeInOut", "duration": 0.25},
                 "reduceMotion": "opacity uniquement"}
    }
    with open(sys.argv[sys.argv.index("--json") + 1], "w", encoding="utf-8") as f:
        json.dump(tokens, f, ensure_ascii=False, indent=2); f.write("\n")

print("ALL OK" if not fail else "SOME FAIL", file=sys.stderr)
sys.exit(1 if fail else 0)
