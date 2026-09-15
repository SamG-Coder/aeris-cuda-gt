"""Native Chromium DOM/input checks using local document injection.
The environment blocks HTTP navigation by policy. This tests real DOM/input,
not a full app/GPU playthrough. Runtime modules are tested separately in Node.
"""
import os,json,re
from pathlib import Path
from playwright.sync_api import sync_playwright
base=Path(__file__).resolve().parent.parent
checks=[]
def check(name,value):
 checks.append({'name':name,'passed':bool(value)})
 print(('PASS ' if value else 'FAIL ')+name)
html=(base/'index.html').read_text()
html=re.sub(r'<script[^>]*>[\s\S]*?</script>','',html)
html=html.replace('</head>','<style>'+(base/'src/style.css').read_text()+'</style></head>')
input_js=(base/'src/input.js').read_text().replace('export class DrivingInput','window.DrivingInput=class DrivingInput')
with sync_playwright() as p:
 browser=p.chromium.launch(executable_path=os.environ.get('CHROMIUM_PATH','/usr/bin/chromium'),headless=True,args=['--no-sandbox'])
 for w,h in [(1440,900),(1024,768),(390,844),(844,390)]:
  page=browser.new_page(viewport={'width':w,'height':h});errors=[];page.on('pageerror',lambda e:errors.append(str(e)))
  page.set_content(html);page.add_script_tag(content=input_js)
  check(f'{w} title',page.locator('h1').inner_text().startswith('AERIS'))
  check(f'{w} title button',page.locator('#start').is_visible())
  check(f'{w} no horizontal overflow',page.evaluate('document.documentElement.scrollWidth<=innerWidth+1'))
  page.evaluate("""() => {document.querySelector('#title').hidden=true;window.testCanvas=document.createElement('canvas');testCanvas.tabIndex=0;document.body.appendChild(testCanvas);window.testActions=[];window.testInput=new DrivingInput(testCanvas,{menu:()=>testActions.push('menu')});testCanvas.focus();} """)
  page.keyboard.down('w');check(f'{w} real W down',page.evaluate('testInput.sample().drive===1'))
  page.keyboard.up('w');check(f'{w} W release',page.evaluate('testInput.sample().drive===0'))
  page.keyboard.down('ArrowLeft');check(f'{w} left',page.evaluate('testInput.sample().steering===1'));page.keyboard.up('ArrowLeft')
  page.keyboard.down('Space');check(f'{w} handbrake',page.evaluate('testInput.sample().handbrake===1'));page.keyboard.up('Space')
  page.keyboard.down('w');page.evaluate("window.dispatchEvent(new Event('blur'))");check(f'{w} blur clears',page.evaluate('testInput.sample().drive===0'));page.keyboard.up('w')
  page.evaluate("document.querySelector('#settings').hidden=false;let el=document.querySelector('#light');for(let a=el;a;a=a.parentElement){a.hidden=false;}document.querySelector('#title').hidden=true;el.focus()");page.keyboard.down('w');check(f'{w} select ignores driving',page.evaluate('testInput.sample().drive===0'));page.keyboard.up('w')
  check(f'{w} controls fit',page.evaluate("document.querySelector('#settings').getBoundingClientRect().right<=innerWidth+1"))
  page.evaluate("document.querySelector('#settings').hidden=true;testCanvas.focus();testInput.enabled=false;")
  page.keyboard.press('Escape');check(f'{w} escape closes disabled menu',page.evaluate("testActions.includes('menu')"))
  page.evaluate("testInput.enabled=true;testInput.setTouch(1,'right',true);testInput.setTouch(2,'throttle',true);")
  check(f'{w} touch input',page.evaluate('testInput.sample().steering===-1&&testInput.sample().drive===1'))
  check(f'{w} input errors',len(errors)==0)
  page.evaluate('testInput.dispose()');page.close()
 browser.close()
(base/'docs/ui-validation.json').write_text(json.dumps({'kind':'Chromium local HTML/CSS injection and real keyboard events. No HTTP app navigation or WebGPU rendering.','passed':sum(x['passed'] for x in checks),'checks':checks},indent=2))
raise SystemExit(0 if all(x['passed'] for x in checks) else 1)
