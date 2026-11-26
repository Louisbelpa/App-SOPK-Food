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
 # fonds
 "background":        ("#F8F5EF", "#121614", "Fond d'écran (crème lin / nuit de sous-bois)"),
 "surface":           ("#FFFFFF", "#1B201D", "Cartes, listes groupées"),
 "surfaceMuted":      ("#EFEAE1", "#252C28", "Chips au repos, champs, segments"),
 "surfaceRaised":     ("#FFFFFF", "#222825", "Sheets, popovers (élévation 2)"),
 "separator":         ("#E2DCD1", "#323A35", "Filets décoratifs (non porteurs de sens)"),
 "border":            ("#8A8276", "#7D8680", "Contours de champs/contrôles (≥ 3:1)"),
 # texte
 "textPrimary":       ("#1E2621", "#F0EDE6", "Texte principal"),
 "textSecondary":     ("#566059", "#B4BBB5", "Légendes, métadonnées"),
 "textTertiary":      ("#5F6661", "#959D97", "Placeholders, aides (reste ≥ 4.5:1)"),
 # interaction
 "accent":            ("#3B6A55", "#8EC3A6", "Sauge : boutons, liens, sélection, anneau « aujourd'hui »"),
 "onAccent":          ("#FFFFFF", "#0E2218", "Texte/icône sur accent"),
 "accentSoft":        ("#E2ECE5", "#21362B", "Fond chip sélectionnée, carte mise en avant"),
 "onAccentSoft":      ("#2A4F3F", "#AAD6BD", "Texte sur accentSoft"),
 "highlight":         ("#A54F2E", "#EE9F7D", "Terracotta : mise en avant ponctuelle (badge, illustration)"),
 "onHighlight":       ("#FFFFFF", "#2A1206", "Texte sur highlight"),
 "highlightSoft":     ("#F6E5DB", "#3B251B", "Fond terracotta doux"),
 # états
 "success":           ("#2D6A47", "#8DCB9F", "Confirmation (« C'est noté »)"),
 "successSoft":       ("#E1EEE4", "#1E3426", "Fond confirmation"),
 "warning":           ("#855600", "#E8BD69", "Alerte douce (seuil 90 j, contre-indication)"),
 "warningSoft":       ("#FAEFD8", "#372C13", "Fond alerte douce"),
 "info":              ("#2E5C78", "#90C1DE", "Information, source, mention d'estimation"),
 "infoSoft":          ("#E2EDF3", "#1B2E39", "Fond information"),
 "destructive":       ("#B3261E", "#FFB4AB", "Suppression de données UNIQUEMENT (jamais une donnée corporelle)"),
 # cycle
 "period":            ("#9E3957", "#F097AF", "Règles (toujours avec drop.fill + libellé)"),
 "onPeriod":          ("#FFFFFF", "#33101C", "Texte sur period"),
 "periodSoft":        ("#F5E3E7", "#3C1E28", "Fond jour de règles"),
 "spotting":          ("#B2647A", "#D99AAB", "Spotting (contour, jamais seul)"),
 # teintes de saison (catégories)
 "miel":              ("#795610", "#E3BF72", "Teinte miel"),
 "mielSoft":          ("#F6ECD3", "#382E17", ""),
 "olive":             ("#4A6220", "#B6CB86", "Teinte olive"),
 "oliveSoft":         ("#E7EED8", "#2A321F", ""),
 "lagon":             ("#1E6662", "#80CAC7", "Teinte lagon"),
 "lagonSoft":         ("#DBEEED", "#173434", ""),
 "ardoise":           ("#3C4E86", "#A9B6EB", "Teinte ardoise"),
 "ardoiseSoft":       ("#E4E8F5", "#222A43", ""),
 "argile":            ("#984829", "#EDA585", "Teinte argile"),
 "argileSoft":        ("#F7E5DB", "#3B251B", ""),
 "lavande":           ("#654F8E", "#C7B7E6", "Teinte lavande"),
 "lavandeSoft":       ("#ECE6F5", "#2D273E", ""),
}

ALIASES = {
 "meal.breakfast": "miel", "meal.lunch": "olive", "meal.dinner": "ardoise", "meal.snack": "argile",
 "activity.strength": "argile", "activity.cardio": "miel", "activity.mobility": "lagon",
 "activity.breathing": "lavande", "activity.intervals": "ardoise",
}

HC = {  # variantes « Augmenter le contraste »
 "textSecondary": ("#3F4842", "#D2D8D3"),
 "border":        ("#5E574D", "#A3ACA6"),
 "accent":        ("#2C5442", "#A9DABF"),
 "period":        ("#7E2643", "#F7B8C9"),
}

BG3 = ["background", "surface", "surfaceMuted"]
checks = []  # (fg, [bgs], min, kind)
for t in ["textPrimary", "textSecondary", "textTertiary", "accent", "highlight", "success",
          "warning", "info", "destructive", "period"]:
    checks.append((t, BG3, 4.5, "texte"))
for t in ["border", "spotting"]:
    checks.append((t, BG3, 3.0, "UI"))
checks += [
 ("onAccent", ["accent"], 4.5, "texte"),
 ("onAccentSoft", ["accentSoft"], 4.5, "texte"),
 ("accent", ["accentSoft"], 4.5, "texte"),
 ("onHighlight", ["highlight"], 4.5, "texte"),
 ("highlight", ["highlightSoft"], 4.5, "texte"),
 ("success", ["successSoft"], 4.5, "texte"),
 ("warning", ["warningSoft"], 4.5, "texte"),
 ("info", ["infoSoft"], 4.5, "texte"),
 ("onPeriod", ["period"], 4.5, "texte"),
 ("period", ["periodSoft"], 4.5, "texte"),
 ("textPrimary", ["periodSoft", "accentSoft", "surfaceRaised"], 4.5, "texte"),
 ("textSecondary", ["surfaceRaised"], 4.5, "texte"),
 ("accent", ["surfaceMuted"], 3.0, "UI"),
]
for s in ["miel", "olive", "lagon", "ardoise", "argile", "lavande"]:
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
      "$schema_note": "Tokens Ovéa v1. Couleurs sRGB hex. Généré par script de contraste (WCAG 2.x).",
      "color": {k: {"light": l, "dark": d, **({"description": u} if u else {})} for k, (l, d, u) in C.items()},
      "colorAliases": ALIASES,
      "colorHighContrast": {k: {"light": l, "dark": d} for k, (l, d) in HC.items()},
      "spacing": {"xxs": 2, "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 24, "xxl": 32, "xxxl": 48,
                  "screenMargin": 20, "cardPadding": 16, "sectionGap": 32, "minTapTarget": 44},
      "radius": {"xs": 6, "sm": 10, "md": 14, "lg": 20, "xl": 28, "capsule": 999,
                 "_note": "RoundedRectangle(style: .continuous) partout"},
      "elevation": {
        "0": {"light": "aucune", "dark": "aucune"},
        "1": {"light": {"color": "#2B3A30", "opacity": 0.06, "radius": 12, "y": 4, "plus": {"opacity": 0.04, "radius": 2, "y": 1}},
              "dark": {"shadow": "aucune", "surface": "surface", "stroke": "separator 0.5pt"}},
        "2": {"light": {"color": "#2B3A30", "opacity": 0.10, "radius": 24, "y": 8},
              "dark": {"shadow": "aucune", "surface": "surfaceRaised", "stroke": "separator 0.5pt"}}
      },
      "typography": {
        "_note": "Dynamic Type uniquement. design=serif => New York ; default => SF Pro ; rounded => SF Pro Rounded.",
        "display":     {"textStyle": "largeTitle", "design": "serif", "weight": "semibold"},
        "title1":      {"textStyle": "title", "design": "serif", "weight": "semibold"},
        "title2":      {"textStyle": "title2", "design": "serif", "weight": "semibold"},
        "title3":      {"textStyle": "title3", "design": "default", "weight": "semibold"},
        "headline":    {"textStyle": "headline", "design": "default", "weight": "semibold"},
        "body":        {"textStyle": "body", "design": "default", "weight": "regular"},
        "bodyEmphasis":{"textStyle": "body", "design": "default", "weight": "medium"},
        "callout":     {"textStyle": "callout", "design": "default", "weight": "regular"},
        "subheadline": {"textStyle": "subheadline", "design": "default", "weight": "regular"},
        "footnote":    {"textStyle": "footnote", "design": "default", "weight": "regular"},
        "caption":     {"textStyle": "caption", "design": "default", "weight": "medium"},
        "overline":    {"textStyle": "caption2", "design": "default", "weight": "semibold", "tracking": 0.6, "case": "uppercase"},
        "quote":       {"textStyle": "title3", "design": "serif", "weight": "regular", "italic": True},
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
