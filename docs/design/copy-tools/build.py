"""Génère docs/design/strings.fr.json depuis strings.src.json en appliquant la typographie française.
Usage : python3 build.py strings.src.json ../strings.fr.json
"""
import json, re, sys
src, out = sys.argv[1], sys.argv[2]
raw = open(src, encoding='utf-8').read()
data = json.loads(raw)
def typo(s):
    s = s.replace("...", "…").replace("'", "\u2019")
    s = re.sub(r"\s+([?!;])", "\u202f\\1", s)
    s = re.sub(r"\s+:", "\u00a0:", s)
    s = re.sub(r"«\s*", "«\u00a0", s); s = re.sub(r"\s*»", "\u00a0»", s)
    s = re.sub(r"(\d|\})\s+(min|h|j|jours|kg|mois|ans)\b", "\\1\u00a0\\2", s)
    return s
def walk(o):
    if isinstance(o, dict): return {k: walk(v) for k,v in o.items()}
    assert isinstance(o, str), o
    return typo(o)
data = walk(data)
json.dump(data, open(out,'w',encoding='utf-8'), ensure_ascii=False, indent=2); open(out,'a').write("\n")
