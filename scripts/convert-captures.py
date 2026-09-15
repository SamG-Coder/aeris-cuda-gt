from pathlib import Path
import json,numpy as np
from PIL import Image
root=Path(__file__).resolve().parents[1]
for meta in (root/'docs/raw').glob('*.json'):
 m=json.loads(meta.read_text());a=np.fromfile(meta.with_suffix('.rgba'),np.uint8).reshape(m['height'],m['stride'])[:,:m['width']*4].reshape(m['height'],m['width'],4)
 if m['format'].startswith('bgra'):a=a[:,:,[2,1,0,3]]
 Image.fromarray(a).convert('RGB').save(root/'docs'/f'{meta.stem}.webp',quality=92)
 print(meta.stem)
