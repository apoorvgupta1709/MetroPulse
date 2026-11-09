import glob
import re

for svg in glob.glob('MetroPulse/metropulse_main/assets/maps/*.svg'):
    with open(svg, encoding='utf-8') as f:
        text = f.read()
    vb = re.search(r'viewBox="0 0 (\d+) (\d+)"', text)
    if not vb:
        continue
    w, h = int(vb.group(1)), int(vb.group(2))
    circles = re.findall(r'cy="([^"]+)"', text)
    ys = [float(y) for y in circles]
    texts = re.findall(r'<text[^>]+y="([^"]+)"', text)
    y_texts = [float(y) for y in texts if y.replace('.', '', 1).replace('-', '', 1).isdigit()]
    all_y = ys + y_texts
    if all_y:
        max_y = max(all_y)
        min_y = min(all_y)
        if max_y > h - 50:
            print(f'CLIPPING ALERT! {svg}: max_y={max_y:.1f}, min_y={min_y:.1f}, height={h}')
        else:
            print(f'OK: {svg}: max_y={max_y:.1f}, min_y={min_y:.1f}, height={h}')
