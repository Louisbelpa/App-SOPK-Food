# Usage : python3 docs/design/illustrations/gen_svg.py docs/design/illustrations  — régénère les SVG (Mousse + plats) depuis ce script.
# Générateur des prototypes d'illustration Ovéa V3 (mascotte « Mousse » + plats).
# Toutes les pièces partagent la même grille (viewBox 240, pas de 8), un seul trait (4 u, encre, bouts ronds)
# et la palette d'illustration limitée. Aucun filtre, aucun dégradé, aucun clipPath.
import math, os, sys

OUT = sys.argv[1] if len(sys.argv) > 1 else "out"
os.makedirs(OUT, exist_ok=True)

P = {
    "encre": "#2A2438",
    "galet": "#CEC7DB", "galetOmbre": "#B2A8C4",
    "mousse": "#8DB34A", "mousseOmbre": "#6F9736", "mousseClaire": "#C2DB86",
    "abricot": "#F4B49A", "abricotOmbre": "#E3957A",
    "courge": "#F2A23A", "courgeOmbre": "#DA8228",
    "paprika": "#D9573B",
    "betterave": "#A63A6B", "betteraveClaire": "#D2709B",
    "porcelaine": "#FAF8F5",
    "bois": "#CC9563", "boisOmbre": "#AE7546",
    "table": "#E5E3EF", "tableOmbre": "#D2CFE1",
    "cacao": "#6B4331",
    "creme": "#EFE6D3",
}
SW = 4  # trait unique
LINE = f'stroke="{P["encre"]}" stroke-width="{SW}" stroke-linecap="round" stroke-linejoin="round"'


def f(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def svg(body, title, desc, w=240, h=240):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" '
            f'role="img" aria-labelledby="t d">\n<title id="t">{title}</title>\n<desc id="d">{desc}</desc>\n'
            f'{body}\n</svg>\n')


# ---------------------------------------------------------------- Mousse
BODY_PTS = [  # (u, v) normalisés : contour du galet, toujours plus large que haut (jamais ovoïde)
    ("M", (.154, 1)),
    ("C", (.044, 1), (-.011, .815), (.011, .611)),
    ("C", (.044, .278), (.253, 0), (.505, 0)),
    ("C", (.769, 0), (.967, .259), (.989, .630)),
    ("C", (1.005, .907), (.923, 1), (.824, 1)),
]


class Mousse:
    def __init__(self, cx=121, top=92, ground=200, hw=91, lift=0, tilt=0):
        self.cx, self.top, self.ground, self.hw, self.lift, self.tilt = cx, top, ground - lift, hw, lift, tilt
        self.realground = ground
        self.L = cx - hw
        self.W = 2 * hw
        self.H = self.ground - top

    def p(self, u, v):
        return self.L + u * self.W, self.top + v * self.H

    def body_d(self):
        out = []
        for seg in BODY_PTS:
            pts = " ".join(f"{f(x)} {f(y)}" for x, y in (self.p(*q) for q in seg[1:]))
            out.append(seg[0] + pts)
        return " ".join(out) + " Z"

    def shade_d(self):
        # croissant d'ombre bas-droite, à l'intérieur du contour (pas de clipPath)
        a = self.p(.989, .630); c1 = self.p(1.005, .907); c2 = self.p(.923, 1); b = self.p(.824, 1)
        s = self.p(.30, 1); k1 = self.p(.66, .93); k2 = self.p(.90, .86)
        return (f"M{f(a[0])} {f(a[1])} C{f(c1[0])} {f(c1[1])} {f(c2[0])} {f(c2[1])} {f(b[0])} {f(b[1])} "
                f"L{f(s[0])} {f(s[1])} C{f(k1[0])} {f(k1[1])} {f(k2[0])} {f(k2[1])} {f(a[0])} {f(a[1])} Z")

    def top_anchor(self):
        return self.p(.505, 0)


def leaf(x, y, ang, ln=26, fill=None):
    fill = fill or P["mousse"]
    return (f'<path transform="translate({f(x)} {f(y)}) rotate({f(ang)})" '
            f'd="M0 0 C{f(ln*.25)} {f(-ln*.40)} {f(ln*.72)} {f(-ln*.42)} {f(ln)} 0 '
            f'C{f(ln*.72)} {f(ln*.30)} {f(ln*.25)} {f(ln*.32)} 0 0 Z" fill="{fill}" {LINE}/>')


def sprig(x, y, kind):
    """La tige sur la tête de Mousse : son indicateur d'énergie (1, 2 ou 3 feuilles)."""
    if kind == "low":  # penchée, une feuille qui pend : posée, pas triste
        stem = f"M{x} {y} C{x} {y-14} {x+6} {y-22} {x+18} {y-24}"
        return (f'<path d="{stem}" fill="none" {LINE}/>' + leaf(x + 18, y - 24, 48, 22))
    if kind == "rest":  # couchée sur la mousse
        return leaf(x + 22, y + 6, 18, 22)
    if kind == "mid":
        stem = f"M{x} {y} C{x-2} {y-14} {x+4} {y-26} {x+14} {y-34}"
        return (f'<path d="{stem}" fill="none" {LINE}/>' + leaf(x + 14, y - 34, -40, 24)
                + leaf(x + 1, y - 16, 205, 20))
    if kind in ("high", "new", "sway"):
        dx = 8 if kind == "sway" else 0
        stem = f"M{x} {y} C{x-2} {y-18} {x+2+dx/2} {y-34} {x+6+dx} {y-48}"
        tip = leaf(x + 6 + dx, y - 48, -70 + dx, 24, P["mousseClaire"] if kind == "new" else None)
        return (f'<path d="{stem}" fill="none" {LINE}/>' + tip
                + leaf(x + 1, y - 18, 200, 21) + leaf(x + 3 + dx/3, y - 32, -18, 21))
    raise ValueError(kind)


def moss_cap(x, y):
    d = (f"M{x-36} {y+12} C{x-38} {y} {x-28} {y-8} {x-18} {y-4} C{x-14} {y-14} {x+2} {y-16} {x+8} {y-8} "
         f"C{x+16} {y-14} {x+30} {y-10} {x+30} {y+2} C{x+36} {y+4} {x+38} {y+12} {x+32} {y+16} "
         f"C{x+12} {y+8} {x-14} {y+8} {x-36} {y+12} Z")
    shade = (f'<path d="M{x-30} {y+10} C{x-12} {y+6} {x+12} {y+6} {x+30} {y+13} C{x+16} {y+9} {x-12} {y+9} {x-30} {y+10} Z" '
             f'fill="{P["mousseOmbre"]}"/>')
    tufts = (f'<circle cx="{x-16}" cy="{y+1}" r="2.6" fill="{P["mousseOmbre"]}"/>'
             f'<circle cx="{x+14}" cy="{y-1}" r="2.6" fill="{P["mousseOmbre"]}"/>')
    return f'<path d="{d}" fill="{P["mousse"]}"/>' + shade + tufts + f'<path d="{d}" fill="none" {LINE}/>'


def eyes(m, kind):
    lx, ly = m.p(.405, .50); rx, ry = m.p(.615, .50)
    out = []
    for (x, y) in ((lx, ly), (rx, ry)):
        if kind in ("open", "look_r", "look_up"):
            ox = 3 if kind == "look_r" else 0
            oy = -2 if kind == "look_up" else 0
            out.append(f'<ellipse cx="{f(x+ox)}" cy="{f(y+oy)}" rx="4.6" ry="6.2" fill="{P["encre"]}"/>'
                       f'<circle cx="{f(x+ox-1.4)}" cy="{f(y+oy-2.4)}" r="1.6" fill="{P["porcelaine"]}"/>')
        elif kind == "closed":
            out.append(f'<path d="M{f(x-6)} {f(y)} Q{f(x)} {f(y+5)} {f(x+6)} {f(y)}" fill="none" {LINE}/>')
        elif kind == "happy":
            out.append(f'<path d="M{f(x-6)} {f(y+2)} Q{f(x)} {f(y-6)} {f(x+6)} {f(y+2)}" fill="none" {LINE}/>')
    return "".join(out)


def cheeks(m):
    a = m.p(.315, .66); b = m.p(.705, .66)
    return "".join(f'<ellipse cx="{f(x)}" cy="{f(y)}" rx="9" ry="5" fill="{P["abricot"]}"/>' for x, y in (a, b))


def mouth(m, kind):
    x, y = m.p(.51, .64)
    if kind == "smile":
        return f'<path d="M{f(x-7)} {f(y-1)} Q{f(x)} {f(y+6)} {f(x+7)} {f(y-1)}" fill="none" {LINE}/>'
    if kind == "soft":
        return f'<path d="M{f(x-4)} {f(y)} Q{f(x)} {f(y+3)} {f(x+4)} {f(y)}" fill="none" {LINE}/>'
    if kind == "o":
        return f'<ellipse cx="{f(x)}" cy="{f(y+1)}" rx="3.4" ry="4" fill="{P["encre"]}"/>'
    return ""


def arm(x, y, ang, ln=26, r=8):
    # petit bras « capsule de galet » : n'apparaît que quand Mousse fait quelque chose
    return (f'<rect x="{f(-r)}" y="{f(-ln)}" width="{f(2*r)}" height="{f(ln)}" rx="{f(r)}" '
            f'transform="translate({f(x)} {f(y)}) rotate({f(ang)})" fill="{P["galet"]}" {LINE}/>')


def speckles(m):
    pts = [(.20, .42, 3), (.25, .33, 2), (.86, .80, 2.4)]
    return "".join(f'<circle cx="{f(m.p(u,v)[0])}" cy="{f(m.p(u,v)[1])}" r="{r}" fill="{P["galetOmbre"]}"/>' for u, v, r in pts)


def ground(m, rx=None):
    rx = rx or m.hw * .86
    return f'<ellipse cx="{f(m.cx)}" cy="{f(m.realground+5)}" rx="{f(rx)}" ry="7" fill="{P["encre"]}" opacity=".12"/>'


def mousse(m, eye="open", mo="smile", sp="mid", arms_back="", arms_front="", cheek=True, cap=True):
    tx, ty = m.top_anchor()
    parts = [arms_back,
             f'<path d="{m.body_d()}" fill="{P["galet"]}"/>',
             f'<path d="{m.shade_d()}" fill="{P["galetOmbre"]}"/>',
             speckles(m),
             f'<path d="{m.body_d()}" fill="none" {LINE}/>']
    if cap:
        if sp != "rest":
            parts.append(sprig(round(tx), round(ty - 10), sp))
        parts.append(moss_cap(round(tx), round(ty)))
        if sp == "rest":  # la feuille repose sur la mousse, devant
            parts.append(sprig(round(tx), round(ty - 10), sp))
    if cheek:
        parts.append(cheeks(m))
    parts += [eyes(m, eye), mouth(m, mo), arms_front]
    g = "\n".join(p for p in parts if p)
    if m.tilt:
        g = f'<g transform="rotate({m.tilt} {f(m.cx)} {f(m.ground)})">\n{g}\n</g>'
    return g


def steam(x, y, n=2, gap=12, h=22):
    s = ""
    for i in range(n):
        xx = x + i * gap
        s += (f'<path d="M{xx} {y} C{xx-6} {y-h*.3} {xx+6} {y-h*.6} {xx} {y-h}" fill="none" {LINE} opacity=".55"/>')
    return s


mascots = {}

m = Mousse(cx=110)
wave = f'<path d="M200 82 q8 2 12 9 M207 72 q10 3 15 13" fill="none" {LINE} opacity=".5"/>'
mascots["accueil"] = ("Mousse dit bonjour", "Mousse, un galet couvert de mousse, lève un petit bras pour saluer.",
                      ground(m) + mousse(m, "open", "smile", "mid", arms_front=arm(168, 132, 28, 38)) + wave)

m = Mousse(top=114, hw=95)
mascots["energie-basse"] = ("Mousse, énergie basse", "Mousse est posée, les yeux mi-clos, sa tige penchée ne porte qu'une feuille. Elle est calme, pas triste.",
                            ground(m) + mousse(m, "closed", "soft", "low"))

m = Mousse()
mascots["energie-moyenne"] = ("Mousse, énergie moyenne", "Mousse, les yeux ouverts, sa tige porte deux feuilles.",
                              ground(m) + mousse(m, "open", "soft", "mid"))

m = Mousse(top=80, hw=88)
mascots["energie-bonne"] = ("Mousse, bonne énergie", "Mousse se tient un peu plus haute, sa tige droite porte trois feuilles.",
                            ground(m) + mousse(m, "open", "smile", "high"))

# jour difficile : sous un plaid, une tasse à côté
m = Mousse(cx=112, top=112, hw=88)
plaid_top = m.top + m.H * .58
pl = (f"M{f(m.L-10)} {f(m.ground+2)} C{f(m.L-14)} {f(plaid_top+20)} {f(m.L+4)} {f(plaid_top+2)} {f(m.L+34)} {f(plaid_top-4)} "
      f"C{f(m.cx-10)} {f(plaid_top+8)} {f(m.cx+30)} {f(plaid_top-6)} {f(m.L+m.W-14)} {f(plaid_top-2)} "
      f"C{f(m.L+m.W+10)} {f(plaid_top+6)} {f(m.L+m.W+14)} {f(m.ground-20)} {f(m.L+m.W+8)} {f(m.ground+2)} Z")
stripes = ""
for i, xx in enumerate([m.L + 22, m.L + 62, m.cx + 26, m.cx + 64]):
    stripes += f'<path d="M{f(xx)} {f(plaid_top+4)} L{f(xx-4)} {f(m.ground)}" stroke="{P["courgeOmbre"]}" stroke-width="6" stroke-linecap="butt"/>'
stripes += f'<path d="M{f(m.L-6)} {f(plaid_top+30)} C{f(m.cx-40)} {f(plaid_top+36)} {f(m.cx+40)} {f(plaid_top+28)} {f(m.L+m.W+10)} {f(plaid_top+32)}" fill="none" stroke="{P["courgeOmbre"]}" stroke-width="6"/>'
stripes += f'<path d="M{f(m.L-8)} {f(plaid_top+16)} C{f(m.cx-40)} {f(plaid_top+22)} {f(m.cx+40)} {f(plaid_top+14)} {f(m.L+m.W+12)} {f(plaid_top+18)}" fill="none" stroke="{P["porcelaine"]}" stroke-width="2.5" opacity=".7"/>'
fold = f'<path d="M{f(m.L+34)} {f(plaid_top-4)} C{f(m.L+44)} {f(plaid_top+10)} {f(m.L+40)} {f(plaid_top+22)} {f(m.L+30)} {f(plaid_top+30)}" fill="none" {LINE}/>'
cupx, cupy = 206, 172
cup = (f'<path d="M{cupx-18} {cupy} h36 v14 a16 16 0 0 1 -16 16 h-4 a16 16 0 0 1 -16 -16 Z" fill="{P["porcelaine"]}" {LINE}/>'
       f'<path d="M{cupx+18} {cupy+5} c10 0 12 14 0 14" fill="none" {LINE}/>'
       f'<path d="M{cupx-12} {cupy+8} h24" stroke="{P["mousse"]}" stroke-width="{SW}" stroke-linecap="round"/>'
       + steam(cupx - 6, cupy - 8, 2, 12, 22))
mascots["jour-difficile"] = ("Mousse sous un plaid", "Mousse se repose sous un plaid, les yeux fermés, une tasse fumante à côté d'elle.",
                             ground(m, m.hw * .95) + mousse(m, "closed", "soft", "rest")
                             + f'<path d="{pl}" fill="#F5C766"/>' + stripes + f'<path d="{pl}" fill="none" {LINE}/>' + fold + cup)

# cuisine : une cuillère en bois dans une cocotte
m = Mousse(cx=92, top=104, hw=70)
potx, poty = 184, 150
pot = (f'<ellipse cx="{potx}" cy="204" rx="44" ry="6" fill="{P["encre"]}" opacity=".12"/>'
       f'<path d="M{potx-40} {poty} h80 v30 a20 20 0 0 1 -20 20 h-40 a20 20 0 0 1 -20 -20 Z" fill="{P["paprika"]}" {LINE}/>'
       f'<path d="M{potx-52} {poty+8} h12 M{potx+40} {poty+8} h12" fill="none" {LINE}/>'
       f'<ellipse cx="{potx}" cy="{poty}" rx="40" ry="8" fill="{P["courge"]}" {LINE}/>')
spoon = (f'<g transform="translate({potx-6} {poty-2}) rotate(-38)">'
         f'<rect x="-4" y="-64" width="8" height="58" rx="4" fill="{P["bois"]}" {LINE}/>'
         f'<ellipse cx="0" cy="-2" rx="9" ry="6" fill="{P["bois"]}" {LINE}/></g>')
mascots["cuisine"] = ("Mousse cuisine", "Mousse tourne une cuillère en bois dans une cocotte qui fume.",
                      ground(m) + steam(potx + 8, poty - 12, 2, 14, 26) + pot + spoon
                      + mousse(m, "look_r", "smile", "mid", arms_front=arm(150, 150, 70, 26)))

# mouvement : petit saut, bras levés
m = Mousse(top=78, ground=200, hw=84, lift=16, tilt=-5)
mascots["mouvement"] = ("Mousse bouge", "Mousse fait un petit saut, les deux bras levés, sa tige se balance.",
                        f'<ellipse cx="{m.cx}" cy="205" rx="56" ry="6" fill="{P["encre"]}" opacity=".12"/>'
                        f'<path d="M62 204 h14 M164 204 h14" fill="none" {LINE} opacity=".4"/>'
                        + mousse(m, "happy", "o", "sway",
                                 arms_front=f'<g transform="rotate(-5 {m.cx} {m.ground})">{arm(64, 120, -38, 36)}{arm(178, 120, 38, 36)}</g>'))

# repos : endormie sur un coussin
m = Mousse(top=108, ground=184, hw=86)
cush = (f'<path d="M24 196 C20 178 40 170 120 170 C200 170 222 178 216 196 C212 210 30 210 24 196 Z" fill="{P["abricot"]}" {LINE}/>'
        f'<path d="M44 190 C90 196 150 196 196 190" fill="none" stroke="{P["abricotOmbre"]}" stroke-width="{SW}" stroke-linecap="round"/>')
mascots["repos"] = ("Mousse se repose", "Mousse dort sur un coussin, les yeux fermés, sa tige couchée.",
                    cush + mousse(m, "closed", "soft", "rest"))

# état vide : un bol vide à côté, elle regarde vers nous
m = Mousse(cx=100, top=98, hw=78)
bx = 196
bowl = (f'<ellipse cx="{bx}" cy="205" rx="34" ry="5" fill="{P["encre"]}" opacity=".12"/>'
        f'<path d="M{bx-34} 170 h68 a34 32 0 0 1 -34 32 a34 32 0 0 1 -34 -32 Z" fill="{P["porcelaine"]}" {LINE}/>'
        f'<ellipse cx="{bx}" cy="170" rx="34" ry="7" fill="{P["table"]}" {LINE}/>')
mascots["etat-vide"] = ("Mousse et un bol vide", "Mousse est assise à côté d'un bol vide et regarde vers toi, tranquille.",
                        ground(m) + bowl + mousse(m, "look_up", "soft", "mid", arms_front=arm(166, 168, 84, 22, 7)))

# célébration douce : une nouvelle feuille, les yeux plissés de contentement
m = Mousse(top=86, hw=89)
tx, ty = m.top_anchor()
glow = (f'<path d="M{f(tx+30)} {f(ty-64)} l8 -6 M{f(tx+34)} {f(ty-50)} l10 0" fill="none" {LINE} opacity=".45"/>')
mascots["celebration"] = ("Mousse contente", "Mousse ferme les yeux de contentement : une nouvelle feuille, plus claire, a poussé sur sa tige.",
                          ground(m) + mousse(m, "happy", "smile", "new") + glow)

for k, (t, d, b) in mascots.items():
    open(os.path.join(OUT, f"mousse-{k}.svg"), "w").write(svg(b, t, d))


# ---------------------------------------------------------------- Plats (vue de dessus, sauf bocaux en 3/4)
def bg():
    return f'<rect width="240" height="240" fill="{P["table"]}"/>'


def plate(cx, cy, r, inner=None, fill=None):
    s = (f'<circle cx="{cx+5}" cy="{cy+7}" r="{r}" fill="{P["tableOmbre"]}"/>'
         f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill or P["porcelaine"]}" {LINE}/>')
    return s


def dots(pts, r, color):
    return "".join(f'<circle cx="{f(x)}" cy="{f(y)}" r="{r}" fill="{color}"/>' for x, y in pts)


def ring_pts(cx, cy, rr, n, start=0, jitter=0):
    out = []
    for i in range(n):
        a = start + i * 2 * math.pi / n + (jitter * math.sin(i * 7.3))
        rad = rr * (1 + .12 * math.sin(i * 3.7))
        out.append((cx + rad * math.cos(a), cy + rad * math.sin(a)))
    return out


def herb(x, y, s=1, col=None, ang=0):
    col = col or P["mousse"]
    # feuille de coriandre/persil : trois lobes en aplat, sans contour
    return (f'<g transform="translate({f(x)} {f(y)}) rotate({ang}) scale({s})" fill="{col}">'
            f'<circle cx="0" cy="-5" r="4.5"/><circle cx="-5" cy="2" r="4.5"/><circle cx="5" cy="2" r="4.5"/></g>')


dishes = {}

# 1. Dahl
b = bg() + plate(104, 112, 80)
b += f'<circle cx="104" cy="112" r="64" fill="{P["courge"]}" {LINE}/>'
b += f'<path d="M78 120 C70 96 96 80 116 92 C132 102 124 124 106 120 C96 118 96 106 104 104" fill="none" stroke="{P["porcelaine"]}" stroke-width="{SW}" stroke-linecap="round"/>'
for x, y, a in [(132, 84, 12), (140, 122, -8), (92, 146, 20), (66, 100, -14), (120, 150, 4), (78, 74, 30)]:
    b += f'<rect x="-7" y="-7" width="14" height="14" rx="3" transform="translate({x} {y}) rotate({a})" fill="{P["courgeOmbre"]}"/>'
b += dots([(112, 70), (146, 104), (60, 128), (100, 132), (128, 136)], 2.4, P["paprika"])
for x, y, a in [(118, 108, 0), (88, 92, 40), (138, 142, -30), (74, 136, 15)]:
    b += herb(x, y, .9, ang=a)
b += plate(190, 192, 38)
b += f'<circle cx="190" cy="192" r="28" fill="{P["creme"]}"/>'
for i, (x, y) in enumerate(ring_pts(190, 192, 16, 9) + ring_pts(190, 192, 6, 4, .5)):
    b += f'<ellipse cx="{f(x)}" cy="{f(y)}" rx="3.2" ry="1.6" transform="rotate({(i*47)%180} {f(x)} {f(y)})" fill="{P["bois"]}" opacity=".45"/>'
dishes["diner-dahl-lentilles-corail-butternut"] = (
    "Dahl de lentilles corail et butternut", "Vu de dessus : un grand bol de dahl orangé avec des dés de butternut, un filet de lait de coco et de la coriandre, à côté d'un petit bol de riz.", b)

# 2. Bowl quinoa
b = bg() + plate(120, 120, 92)
b += f'<circle cx="120" cy="120" r="76" fill="{P["creme"]}"/>'
# quinoa (bas-gauche)
b += dots(ring_pts(84, 150, 22, 16, 0, .2) + ring_pts(84, 150, 10, 8, .3), 2.6, P["bois"])
# chou rouge (haut-gauche) : lanières en traits colorés
for i in range(7):
    y0 = 70 + i * 7
    b += f'<path d="M{62+i*2} {y0} C{76+i} {y0-6} {92} {y0+2} {104-i} {y0-4}" fill="none" stroke="{P["betterave"]}" stroke-width="{SW}" stroke-linecap="round"/>'
# carottes rôties (haut-droite) : rondelles
for x, y in [(146, 72), (166, 84), (150, 96), (172, 106), (136, 90)]:
    b += f'<circle cx="{x}" cy="{y}" r="9" fill="{P["courge"]}" {LINE}/><circle cx="{x}" cy="{y}" r="3" fill="{P["courgeOmbre"]}"/>'
# pois chiches (bas-droite)
for x, y in [(140, 140), (156, 136), (170, 148), (150, 156), (166, 166), (136, 162), (154, 176)]:
    b += f'<circle cx="{x}" cy="{y}" r="8" fill="#E7C17E" {LINE}/>'
    b += f'<path d="M{x-3} {y-2} q3 -3 6 0" fill="none" stroke="{P["courgeOmbre"]}" stroke-width="2.5" stroke-linecap="round"/>'
# filet de tahini
b += f'<path d="M66 118 C86 104 96 134 116 120 C136 106 146 134 170 122" fill="none" stroke="{P["porcelaine"]}" stroke-width="{SW+2}" stroke-linecap="round"/>'
b += f'<path d="M66 118 C86 104 96 134 116 120 C136 106 146 134 170 122" fill="none" stroke="{P["bois"]}" stroke-width="1.5" stroke-linecap="round" opacity=".5"/>'
for x, y, a in [(118, 150, 0), (108, 86, 30), (126, 98, -20)]:
    b += herb(x, y, .85, ang=a)
dishes["dejeuner-bowl-quinoa-pois-chiches-cumin-tahini"] = (
    "Bowl quinoa, pois chiches au cumin et sauce tahini", "Vu de dessus : un bol partagé entre quinoa, chou rouge, carottes rôties et pois chiches, avec un filet de sauce tahini.", b)

# 3. Houmous de betterave et crudités
b = bg()
b += f'<rect x="28" y="40" width="190" height="170" rx="28" fill="{P["tableOmbre"]}" transform="translate(5 7)"/>'
b += f'<rect x="28" y="40" width="190" height="170" rx="28" fill="{P["bois"]}" {LINE}/>'
b += f'<path d="M48 64 C90 58 150 58 196 66 M48 186 C100 192 150 192 198 184" fill="none" stroke="{P["boisOmbre"]}" stroke-width="{SW}" stroke-linecap="round"/>'
# endives
for x, y, a in [(176, 168, -40), (190, 140, -70), (182, 112, -100)]:
    b += (f'<path transform="translate({x} {y}) rotate({a})" d="M0 0 C10 -6 34 -8 46 0 C34 8 10 6 0 0 Z" fill="#E9EDBF" {LINE}/>'
          f'<path transform="translate({x} {y}) rotate({a})" d="M6 0 H38" stroke="#C9D58A" stroke-width="3" stroke-linecap="round"/>')
# carottes
for x, y, a in [(56, 92, -60), (66, 80, -40), (50, 150, 70)]:
    b += f'<rect x="-6" y="-38" width="12" height="40" rx="6" transform="translate({x} {y}) rotate({a})" fill="{P["courge"]}" {LINE}/>'
b += plate(116, 124, 56)
b += f'<circle cx="116" cy="124" r="44" fill="{P["betteraveClaire"]}" {LINE}/>'
b += f'<path d="M92 128 C88 108 110 96 126 106 C138 114 132 132 118 130 C108 128 108 116 116 114" fill="none" stroke="{P["betterave"]}" stroke-width="{SW}" stroke-linecap="round"/>'
b += f'<path d="M126 132 c6 -2 12 2 10 8 c-2 6 -12 6 -14 0 c-1 -4 1 -7 4 -8 Z" fill="{P["courge"]}" opacity=".9"/>'
b += dots([(100, 112), (134, 118), (106, 144), (124, 100)], 1.8, P["cacao"])
b += herb(140, 142, .8, ang=20)
dishes["collation-houmous-betterave-crudites"] = (
    "Houmous de betterave et crudités", "Vu de dessus : un bol de houmous rose vif avec un filet d'huile, entouré de bâtonnets de carotte et de feuilles d'endive sur une planche en bois.", b)

# 4. Saumon, poireaux, écrasé de haricots blancs
b = bg() + plate(120, 120, 94)
# écrasé de haricots
eh = "M60 140 C50 120 62 100 82 104 C96 92 116 104 112 122 C124 136 110 162 90 158 C74 170 54 158 60 140 Z"
b += f'<path d="{eh}" fill="{P["creme"]}" {LINE}/>'
b += dots([(78, 120), (94, 134), (84, 146), (98, 116)], 2, P["bois"])
b += f'<path d="M72 132 C80 124 92 128 98 122" fill="none" stroke="{P["courge"]}" stroke-width="3" stroke-linecap="round" opacity=".7"/>'
# poireaux fondants (rondelles)
for x, y in [(134, 168), (156, 158), (118, 176), (150, 180), (170, 140), (128, 152)]:
    b += f'<circle cx="{x}" cy="{y}" r="11" fill="#D7E5A4" {LINE}/><circle cx="{x}" cy="{y}" r="5" fill="none" stroke="{P["mousse"]}" stroke-width="3"/>'
# pavé de saumon
b += (f'<g transform="translate(150 104) rotate(-14)">'
      f'<rect x="-36" y="-26" width="72" height="52" rx="12" fill="#F39C7C" {LINE}/>'
      f'<path d="M-36 -10 H36 M-36 -10" stroke="{P["paprika"]}" stroke-width="0"/>'
      f'<path d="M-20 -24 C-26 -8 -26 8 -20 24 M-2 -25 C-8 -8 -8 8 -2 25 M16 -25 C10 -8 10 8 16 25" fill="none" stroke="{P["porcelaine"]}" stroke-width="3" stroke-linecap="round" opacity=".85"/>'
      f'</g>')
# citron
b += f'<path d="M168 56 a26 26 0 0 1 26 26 h-26 Z" fill="#F5D35A" {LINE}/><path d="M174 64 l10 10 M170 72 l8 2" fill="none" stroke="#E2B92E" stroke-width="3" stroke-linecap="round"/>'
# thym
b += f'<path d="M112 72 C120 66 128 66 138 60" fill="none" stroke="{P["mousseOmbre"]}" stroke-width="3" stroke-linecap="round"/>'
b += dots([(116, 68), (122, 70), (128, 64), (134, 64), (124, 62)], 2.6, P["mousseOmbre"])
dishes["diner-saumon-poireaux-fondants-ecrase-haricots-blancs"] = (
    "Saumon, poireaux fondants et écrasé de haricots blancs", "Vu de dessus : une assiette avec un pavé de saumon doré sur des rondelles de poireaux, un écrasé de haricots blancs, du thym et un quartier de citron.", b)

# 5. Overnight oats (3/4, bocal)
b = bg()
b += f'<ellipse cx="120" cy="206" rx="70" ry="9" fill="{P["tableOmbre"]}"/>'
jar = "M70 70 H170 V184 a20 20 0 0 1 -20 20 H90 a20 20 0 0 1 -20 -20 Z"
b += f'<path d="{jar}" fill="#F3F2F9"/>'
b += f'<path d="M74 132 H166 V184 a16 16 0 0 1 -16 16 H90 a16 16 0 0 1 -16 -16 Z" fill="{P["creme"]}"/>'
b += f'<path d="M74 104 C96 98 140 110 166 102 V134 C140 140 100 128 74 136 Z" fill="#E7E9A6"/>'
b += dots([(90, 150), (110, 166), (140, 156), (126, 182), (98, 186), (152, 176), (118, 146)], 2.4, P["bois"])
for x, y in [(92, 116), (112, 120), (132, 114), (150, 118)]:
    b += f'<rect x="-5" y="-5" width="10" height="10" rx="2" transform="translate({x} {y}) rotate({x%30})" fill="#D3D876"/>'
for x, y in [(96, 92), (132, 90), (114, 86)]:
    b += f'<path transform="translate({x} {y})" d="M-10 0 C-10 -8 -2 -10 0 -5 C2 -10 10 -8 10 0 C10 6 2 8 0 4 C-2 8 -10 6 -10 0 Z" fill="#A8703F" {LINE}/>'
b += dots([(82, 98), (150, 96), (120, 100)], 2, P["cacao"])
b += f'<path d="{jar}" fill="none" {LINE}/>'
b += f'<path d="M64 62 H176 V74 H64 Z" fill="{P["mousse"]}" {LINE}/>'
b += f'<path d="M84 150 V186" stroke="{P["porcelaine"]}" stroke-width="{SW+2}" stroke-linecap="round" opacity=".8"/>'
# pomme
b += f'<circle cx="196" cy="184" r="22" fill="{P["paprika"]}" {LINE}/><path d="M196 162 c0 -8 4 -12 8 -14" fill="none" {LINE}/>'
b += leaf(200, 156, -20, 16)
b += f'<path d="M186 176 q4 -6 10 -6" fill="none" stroke="{P["porcelaine"]}" stroke-width="3" stroke-linecap="round" opacity=".7"/>'
dishes["petit-dejeuner-overnight-oats-pomme-cannelle-noix"] = (
    "Overnight oats pomme, cannelle et noix", "Vu de trois quarts : un bocal en verre de flocons d'avoine crémeux, une couche de pomme en dés et des cerneaux de noix, une pomme posée à côté.", b)

# 6. Bouchées cacao-amandes
b = bg()
b += f'<rect x="34" y="54" width="180" height="140" rx="24" fill="{P["tableOmbre"]}" transform="translate(5 7)"/>'
b += f'<rect x="34" y="54" width="180" height="140" rx="24" fill="{P["bois"]}" {LINE}/>'
b += f'<path d="M54 76 C100 70 160 72 196 78 M54 172 C100 178 160 176 194 170" fill="none" stroke="{P["boisOmbre"]}" stroke-width="{SW}" stroke-linecap="round"/>'
balls = [(78, 104, "c"), (118, 98, "w"), (158, 106, "c"), (92, 146, "w"), (134, 142, "c"), (176, 148, "w"), (60, 152, "c")]
for x, y, k in balls:
    fill = P["cacao"] if k == "c" else P["creme"]
    b += f'<circle cx="{x}" cy="{y}" r="17" fill="{fill}" {LINE}/>'
    if k == "w":
        b += dots([(x - 6, y - 4), (x + 5, y - 7), (x + 7, y + 4), (x - 3, y + 7), (x - 9, y + 3)], 1.6, P["bois"])
    else:
        b += f'<path d="M{x-8} {y-6} q5 -5 11 -4" fill="none" stroke="#8C5D46" stroke-width="3" stroke-linecap="round"/>'
for x, y, a in [(196, 92, 30), (186, 118, -20), (150, 172, 60)]:
    b += f'<ellipse cx="0" cy="0" rx="8" ry="5" transform="translate({x} {y}) rotate({a})" fill="#E0B07E"/>'
dishes["collation-bouchees-cacao-amandes-sans-cuisson"] = (
    "Bouchées cacao-amandes sans cuisson", "Vu de dessus : des boules au cacao, certaines roulées dans la noix de coco, et quelques amandes sur une planche.", b)

for k, (t, d, bb) in dishes.items():
    open(os.path.join(OUT, f"{k}.svg"), "w").write(svg(bb, t, d))

print("ok", len(mascots), len(dishes))
