import json, re, sys
p = sys.argv[1]
def nodup(pairs):
    keys=[k for k,_ in pairs]; d=[k for k in set(keys) if keys.count(k)>1]
    assert not d, f"duplicate keys {d}"; return dict(pairs)
data = json.load(open(p,encoding='utf-8'), object_pairs_hook=nodup)
leaves={}
def walk(o,pre=""):
    for k,v in o.items():
        key=f"{pre}.{k}" if pre else k
        if isinstance(v,dict): walk(v,key)
        else:
            assert isinstance(v,str), key; leaves[key]=v
walk(data)
ui={k:v for k,v in leaves.items() if "_notes" not in k and not k.startswith("_meta")}
print("leaves:",len(leaves),"ui strings:",len(ui))
banned=r"\b(retard|en retard|trich\w*|écart|craqu\w*|calorie\w*|kcal|normale?s?|anormal\w*|lutter|combat\w*|guéri\w*|soign\w*|régime|minceur|maigrir|détox|phase\w*|fertile\w*|streak|série|il faut|tu dois|échec|patiente|souffr\w*|hirsutisme|surpoids|kystes?|parfait\w*|boost\w*|interdit\w*|faible)\b"
# allowed contexts: disclaimer/about negations mention ovulation/fertilité
bad=[(k,m.group(0)) for k,v in ui.items() for m in re.finditer(banned,v,re.I)]
for b in bad: print("BANNED?",b)
for k,v in ui.items():
    if re.search(r"\b(ovulation|fertilité)\b",v,re.I) and not re.search(r"disclaimer\.body|about\.limit2",k): print("OVUL/FERT outside disclaimer:",k)
notifban=r"(sopk|règle|cycle|ovul|fertil|symptôm|douleur|saign|santé|médecin|traitement|pilule|hormon|poids|humeur|anxi|ventre|peau|poil|grossesse|bébé|\{|\d|!|❤)"
for k,v in ui.items():
    if k.startswith("notifications.") and not k.startswith("notifications.byType"):
        if re.search(notifban,v,re.I): print("NOTIF BAD:",k,v)
        if len(v)>60: print("NOTIF TOO LONG",k,len(v))
dw=[v for k,v in ui.items() if k.startswith("dailyWords.")]
print("dailyWords:",len(dw),"max len",max(map(len,dw)))
print("reminders:",len(data["notifications"]["reminders"]))
for k,v in ui.items():
    if k.endswith((".cta",".ctaConsult",".ctaAddPeriod")) and len(v)>24: print("LONG BUTTON",k,len(v),v)
    if re.search(r"[\U0001F300-\U0001FAFF]",v): print("EMOJI",k)
    if "'" in v or "..." in v: print("TYPO",k)
# gender heuristics
for k,v in ui.items():
    if re.search(r"\b(prête|contente|ravie?|seule|fatiguée|motivée|placée|douce avec)\b",v,re.I): print("GENDER?",k,v)
