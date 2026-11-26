"""Convertit docs/design/maquettes.html (page autonome) en page publiable comme Artifact."""
import re
import sys

src, out = sys.argv[1], sys.argv[2]
h = open(src, encoding='utf-8').read()
head = h[h.index('<head>') + 6:h.index('</head>')]
links = '\n'.join(re.findall(r'<link[^>]+>', head))
style = h[h.index('<style>') + 7:h.index('</style>')]
body = h[h.index('<body>') + 6:h.index('</body>')]

dark = re.search(r'html\[data-theme="dark"\] \{(.*?)\n\}', style, re.S).group(1)
dark2 = re.search(r'html\[data-theme="dark"\] \{ (--page-bg.*?) color-scheme: dark; \}', style).group(1)
style = style.replace('html[data-theme="dark"]', ':root[data-theme="dark"]')
style += ('\n@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {' + dark
          + '\n  ' + dark2 + ' color-scheme: dark; } }\n')
style += ('.page-head, .rail { padding-left: max(16px, env(safe-area-inset-left, 0px)); '
          'padding-right: max(16px, env(safe-area-inset-right, 0px)); }\n')
style += '@media (prefers-reduced-motion: reduce) { body, .phone { transition: none; } }\n'

old = """  btn.addEventListener('click', function () {
    apply(root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
  });"""
new = """  function current() {
    var t = root.getAttribute('data-theme');
    if (t === 'dark' || t === 'light') return t;
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  apply(current());
  btn.addEventListener('click', function () { apply(current() === 'dark' ? 'light' : 'dark'); });"""
assert body.count(old) == 1, 'script du bouton introuvable'
body = body.replace(old, new)

page = ('<title>Maquettes Ovéa</title>\n<meta name="claude:viewport-fit-sides" content="cover">\n'
        + links + '\n<style>' + style + '</style>\n' + body)
open(out, 'w', encoding='utf-8').write(page)
print(len(page))
