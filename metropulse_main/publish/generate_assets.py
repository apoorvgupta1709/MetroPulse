import os
from PIL import Image, ImageDraw, ImageFont

ICONS_DIR = r"E:\YOUTUBE 2026\Publish APPS\MetroPulse\metropulse_main\publish\icons"
GRAPHICS_DIR = r"E:\YOUTUBE 2026\Publish APPS\MetroPulse\metropulse_main\publish\graphics"
SCREENSHOTS_DIR = r"E:\YOUTUBE 2026\Publish APPS\MetroPulse\metropulse_main\publish\screenshots"
ASSETS_ICON = r"E:\YOUTUBE 2026\Publish APPS\MetroPulse\metropulse_main\assets\icons\app_icon.png"

os.makedirs(ICONS_DIR, exist_ok=True)
os.makedirs(GRAPHICS_DIR, exist_ok=True)
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
os.makedirs(os.path.dirname(ASSETS_ICON), exist_ok=True)

def draw_metro_icon(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Rounded background container
    radius = int(size * 0.22)
    # Vibrant transit gradient effect
    for i in range(size):
        ratio = i / size
        r = int(10 + ratio * 15)
        g = int(60 + ratio * 80)
        b = int(180 + ratio * 60)
        draw.line([(0, i), (size, i)], fill=(r, g, b, 255))
        
    # Mask to rounded rect
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    
    final_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    final_img.paste(img, (0, 0), mask)
    draw = ImageDraw.Draw(final_img)
    
    # Draw Modern Futuristic Subway Car & Pulse Wave
    center_x = size // 2
    center_y = size // 2
    
    # Outer transit circular orbit
    orbit_radius = int(size * 0.38)
    draw.ellipse([center_x - orbit_radius, center_y - orbit_radius, center_x + orbit_radius, center_y + orbit_radius], 
                 outline=(0, 229, 255, 180), width=int(size * 0.025))
    
    # Intersecting metro track lines
    w = int(size * 0.035)
    draw.line([(int(size * 0.15), int(size * 0.65)), (int(size * 0.85), int(size * 0.35))], fill=(255, 215, 0, 240), width=w)
    draw.line([(int(size * 0.15), int(size * 0.35)), (int(size * 0.85), int(size * 0.65))], fill=(0, 230, 118, 240), width=w)
    
    # Train Body
    bw = int(size * 0.34)
    bh = int(size * 0.44)
    bx1 = center_x - bw // 2
    by1 = center_y - bh // 2 - int(size * 0.02)
    bx2 = center_x + bw // 2
    by2 = center_y + bh // 2 - int(size * 0.02)
    
    draw.rounded_rectangle([bx1, by1, bx2, by2], radius=int(size * 0.08), fill=(255, 255, 255, 255), outline=(15, 23, 42, 255), width=int(size * 0.02))
    
    # Windshield
    ww = int(bw * 0.76)
    wh = int(bh * 0.32)
    wx1 = center_x - ww // 2
    wy1 = by1 + int(bh * 0.12)
    wx2 = center_x + ww // 2
    wy2 = wy1 + wh
    draw.rounded_rectangle([wx1, wy1, wx2, wy2], radius=int(size * 0.04), fill=(15, 23, 42, 255))
    
    # Twin headlights
    hl_r = int(size * 0.03)
    draw.ellipse([bx1 + int(bw * 0.18), by2 - int(bh * 0.28), bx1 + int(bw * 0.18) + hl_r*2, by2 - int(bh * 0.28) + hl_r*2], fill=(255, 215, 0, 255))
    draw.ellipse([bx2 - int(bw * 0.18) - hl_r*2, by2 - int(bh * 0.28), bx2 - int(bw * 0.18), by2 - int(bh * 0.28) + hl_r*2], fill=(255, 215, 0, 255))
    
    # Central Pulse Emblem
    draw.ellipse([center_x - int(size*0.04), by2 - int(bh * 0.26), center_x + int(size*0.04), by2 - int(bh * 0.18)], fill=(0, 200, 83, 255))

    return final_img

# 1. Generate 512x512 and 1024x1024 icons
icon_512 = draw_metro_icon(512)
# Convert RGBA to RGB for Play Store 512x512 (Google Play requires no alpha)
icon_512_rgb = Image.new("RGB", (512, 512), (15, 23, 42))
icon_512_rgb.paste(icon_512, (0, 0), icon_512)
icon_512_rgb.save(os.path.join(ICONS_DIR, "icon_512.png"), "PNG")
icon_512.save(ASSETS_ICON, "PNG")

icon_1024 = draw_metro_icon(1024)
icon_1024_rgb = Image.new("RGB", (1024, 1024), (15, 23, 42))
icon_1024_rgb.paste(icon_1024, (0, 0), icon_1024)
icon_1024_rgb.save(os.path.join(ICONS_DIR, "icon_1024.png"), "PNG")

# 2. Generate 1024x500 Feature Graphic
fg = Image.new("RGB", (1024, 500), (10, 16, 32))
fg_draw = ImageDraw.Draw(fg)

# Gradient background & glowing tracks
for y in range(500):
    r = int(12 + (y / 500) * 18)
    g = int(22 + (y / 500) * 45)
    b = int(48 + (y / 500) * 90)
    fg_draw.line([(0, y), (1024, y)], fill=(r, g, b))

# Futuristic route paths
fg_draw.line([(0, 420), (380, 280), (680, 280), (1024, 120)], fill=(0, 229, 255), width=8)
fg_draw.line([(0, 120), (320, 280), (620, 280), (1024, 440)], fill=(255, 215, 0), width=6)
fg_draw.line([(180, 500), (500, 280), (840, 60)], fill=(255, 64, 129), width=6)

# Station nodes
for pt in [(380, 280), (680, 280), (320, 280), (620, 280), (500, 280)]:
    fg_draw.ellipse([pt[0]-14, pt[1]-14, pt[0]+14, pt[1]+14], fill=(255, 255, 255), outline=(0, 0, 0), width=4)

# Place 220px App Icon on Left
app_icon_small = icon_512.resize((220, 220), Image.Resampling.LANCZOS)
fg.paste(app_icon_small, (80, 140), app_icon_small)

# Titles
fg_draw.text((340, 150), "MetroPulse", fill=(255, 255, 255))
fg_draw.text((340, 210), "Next-Gen Urban Transit & Commuter Engine", fill=(0, 229, 255))
fg_draw.text((340, 250), "Offline Graph Routing • 4K Vector Maps • Live Delays", fill=(220, 220, 220))
fg_draw.text((340, 290), "Covering Delhi NCR, Mumbai, Bengaluru, Dubai & London", fill=(255, 215, 0))
fg_draw.text((340, 340), "Made with ❤️ by Apoorv", fill=(255, 105, 180))

fg.save(os.path.join(GRAPHICS_DIR, "feature_graphic_1024x500.png"), "PNG")

# 3. Generate 4 Preview Screenshots (1080x1920)
def make_screenshot(title, subtitle, highlight_color):
    img = Image.new("RGB", (1080, 1920), (15, 23, 42))
    d = ImageDraw.Draw(img)
    # Header banner
    d.rectangle([0, 0, 1080, 360], fill=(20, 30, 55))
    d.text((80, 110), title, fill=(255, 255, 255))
    d.text((80, 190), subtitle, fill=highlight_color)
    d.text((80, 260), "Made with ❤️ by Apoorv • MetroPulse", fill=(180, 180, 180))
    
    # Phone mock body
    d.rounded_rectangle([100, 420, 980, 1820], radius=40, fill=(245, 247, 250), outline=(50, 65, 95), width=8)
    # Status bar
    d.rounded_rectangle([420, 435, 660, 465], radius=15, fill=(15, 23, 42))
    # Content representation
    d.rectangle([130, 500, 950, 680], fill=(0, 102, 204))
    d.rectangle([130, 720, 950, 920], fill=(255, 255, 255), outline=(220, 220, 220), width=2)
    d.rectangle([130, 960, 520, 1260], fill=(255, 255, 255), outline=(220, 220, 220), width=2)
    d.rectangle([560, 960, 950, 1260], fill=(255, 255, 255), outline=(220, 220, 220), width=2)
    d.rectangle([130, 1300, 520, 1600], fill=(255, 255, 255), outline=(220, 220, 220), width=2)
    d.rectangle([560, 1300, 950, 1600], fill=(255, 255, 255), outline=(220, 220, 220), width=2)
    return img

s1 = make_screenshot("Zero-Friction Home Dashboard", "Instant Offline Access Without Login Barriers", (0, 229, 255))
s1.save(os.path.join(SCREENSHOTS_DIR, "screenshot_1_home_dashboard.png"), "PNG")

s2 = make_screenshot("Dijkstra & BFS Route Planner", "Fastest Journey vs Fewest Line Changes", (255, 215, 0))
s2.save(os.path.join(SCREENSHOTS_DIR, "screenshot_2_route_planner.png"), "PNG")

s3 = make_screenshot("Ultra-Crisp 4K Vector Metro Map", "High-DPI Interactive Viewer With Search & Pan", (0, 230, 118))
s3.save(os.path.join(SCREENSHOTS_DIR, "screenshot_3_interactive_4k_map.png"), "PNG")

s4 = make_screenshot("Gates, Amenities & Prime Pass", "Numbered Exits, GPS Finder & Ad-Free Lifetime", (255, 64, 129))
s4.save(os.path.join(SCREENSHOTS_DIR, "screenshot_4_prime_perks.png"), "PNG")

print("Successfully generated all store icons, feature graphic, and screenshots!")
