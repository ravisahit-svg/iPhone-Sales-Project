from pathlib import Path
from html import escape

folder = Path(__file__).parent / 'screenshots'
images = sorted(folder.glob('*.png'), key=lambda p:int(p.stem))
items = ''.join(f'<section><h2>{escape(p.stem)}</h2><a href="{escape(p.name)}"><img src="{escape(p.name)}" alt="{escape(p.stem)}"></a></section>' for p in images)
html = '<!doctype html><html><head><meta charset="utf-8"><title>Ravi iPhone Sales Project Screenshots</title><style>body{font:16px Arial;margin:32px;background:#f3f4f6;color:#111827}section{margin:36px 0}h1{font-size:28px}h2{font-size:20px}img{max-width:100%;border:1px solid #d1d5db}p{line-height:1.6}</style></head><body><h1>Ravi iPhone Sales Project Screenshots</h1><p>Direct captures of actual console windows executing Hive and HDFS commands. Click a numbered screenshot to view it at full size. Matching execution logs are retained in the project logs folder.</p>'+items+'</body></html>'
(folder/'index.html').write_text(html,encoding='utf-8')
print('Screenshot gallery created:',len(images),'images')
