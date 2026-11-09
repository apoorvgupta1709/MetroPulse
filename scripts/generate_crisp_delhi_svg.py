import json
import math
import os

DATA_PATH = r'MetroPulse\data\production\delhi_metro_production.json'
OUT_SVG = r'MetroPulse\metropulse_main\assets\maps\delhi_metro_schematic.svg'

with open(DATA_PATH, 'r', encoding='utf-8') as f:
    data = json.load(f)

lines_meta = {l['id']: l for l in data['lines']}
stations = data['stations']
stations_by_id = {s['id']: s for s in stations}

# Canvas dimensions
WIDTH = 3800
HEIGHT = 3200

# Key Schematic Anchor Coordinates (Authentic DMRC System Map Grid)
coords = {}

# 1. Yellow Line Stations (37 stations) from Top (Samaypur Badli) to Bottom (Millennium City Centre)
yl_stations = lines_meta['yellow']['stationIds']
y_start = 220
y_end = 2800
yl_step = (y_end - y_start) / (len(yl_stations) - 1)
for i, sid in enumerate(yl_stations):
    coords[sid] = (1600, y_start + i * yl_step)

# Fix specific hubs on Yellow Line
coords['del_kashmere_gate'] = (1600, 750)
coords['del_chandni_chowk'] = (1600, 920)
coords['del_chawri_bazar'] = (1600, 1020)
coords['del_new_delhi'] = (1600, 1120)
coords['del_rajiv_chowk'] = (1600, 1250)
coords['del_patel_chowk'] = (1600, 1350)
coords['del_central_secretariat'] = (1600, 1450)
coords['del_udyog_bhawan'] = (1600, 1540)
coords['del_lok_kalyan_marg'] = (1600, 1630)
coords['del_jor_bagh'] = (1600, 1720)
coords['del_dilli_haat_ina'] = (1600, 1810)
coords['del_aiims'] = (1600, 1890)
coords['del_green_park'] = (1600, 1960)
coords['del_hauz_khas'] = (1600, 2040)
coords['del_malviya_nagar'] = (1600, 2130)
coords['del_saket'] = (1600, 2210)
coords['del_qutab_minar'] = (1600, 2290)
coords['del_chhattarpur'] = (1600, 2370)
coords['del_sultanpur'] = (1600, 2440)
coords['del_ghitorni'] = (1600, 2510)
coords['del_arjan_garh'] = (1600, 2580)
coords['del_guru_dronacharya'] = (1600, 2650)
coords['del_sikanderpur'] = (1600, 2720)
coords['del_mg_road'] = (1600, 2800)
coords['del_iffco_chowk'] = (1500, 2800)
coords['del_millennium_city_centre'] = (1400, 2800)

# 2. Red Line Stations (29 stations) from Rithala to Shaheed Sthal
rl_stations = lines_meta['red']['stationIds']
kg_idx = rl_stations.index('del_kashmere_gate')
for i in range(kg_idx):
    sid = rl_stations[i]
    x = 450 + (i / kg_idx) * (1600 - 450)
    coords[sid] = (x, 750)

east_red = rl_stations[kg_idx+1:]
for j, sid in enumerate(east_red):
    if j < 8:
        x = 1600 + (j + 1) * 85
        coords[sid] = (x, 750)
    else:
        x = 1600 + 8 * 85 + (j - 7) * 75
        y = 750 + (j - 7) * 25
        coords[sid] = (x, y)

coords['del_netaji_subhash_place'] = (980, 750)
coords['del_inderlok'] = (1220, 750)
coords['del_welcome'] = (2050, 750)

# 3. Blue Line Main (50 stations)
bl_stations = lines_meta['blue']['stationIds']
rc_idx = bl_stations.index('del_rajiv_chowk')

for idx in range(rc_idx):
    sid = bl_stations[idx]
    if idx <= 8:
        coords[sid] = (380 + idx * 40, 2250 - idx * 45)
    elif idx <= 13:
        f = (idx - 8) / 5
        coords[sid] = (700 + f * 120, 1890 - f * 240)
    elif idx <= 18:
        f = (idx - 13) / 5
        coords[sid] = (820 + f * 200, 1650 - f * 220)
    elif idx <= 21:
        f = (idx - 18) / 3
        coords[sid] = (1020 + f * 180, 1430 - f * 100)
    else:
        f = (idx - 21) / (rc_idx - 21)
        coords[sid] = (1200 + f * 400, 1330 - f * 80)

coords['del_janakpuri_west'] = (820, 1650)
coords['del_rajouri_garden'] = (1020, 1430)
coords['del_kirti_nagar'] = (1200, 1330)
coords['del_shadipur'] = (1280, 1310)
coords['del_patel_nagar'] = (1360, 1290)
coords['del_rajendra_place'] = (1440, 1270)
coords['del_karol_bagh'] = (1500, 1250)
coords['del_jhandewalan'] = (1540, 1250)
coords['del_rk_ashram_marg'] = (1570, 1250)
coords['del_rajiv_chowk'] = (1600, 1250)
coords['del_barakhamba_road'] = (1720, 1250)
coords['del_mandi_house'] = (1850, 1250)
coords['del_supreme_court'] = (1950, 1250)
coords['del_indraprastha'] = (2020, 1250)
coords['del_yamuna_bank'] = (2100, 1250)

bg_idx = bl_stations.index('del_botanical_garden')
yb_idx = bl_stations.index('del_yamuna_bank')
for idx in range(yb_idx + 1, bg_idx):
    f = (idx - yb_idx) / (bg_idx - yb_idx)
    sid = bl_stations[idx]
    coords[sid] = (2100 + f * 550, 1250 + f * 300)

coords['del_akshardham'] = (2190, 1300)
coords['del_mayur_vihar_1'] = (2280, 1350)
coords['del_mayur_vihar_ext'] = (2370, 1400)
coords['del_new_ashok_nagar'] = (2460, 1450)
coords['del_noida_sec_15'] = (2520, 1480)
coords['del_noida_sec_16'] = (2580, 1515)
coords['del_noida_sec_18'] = (2640, 1550)
coords['del_botanical_garden'] = (2700, 1550)

nec_idx = len(bl_stations) - 1
for idx in range(bg_idx + 1, len(bl_stations)):
    f = (idx - bg_idx) / (nec_idx - bg_idx)
    sid = bl_stations[idx]
    coords[sid] = (2700 + f * 680, 1550)

coords['del_golf_course'] = (2770, 1550)
coords['del_noida_city_centre'] = (2840, 1550)
coords['del_noida_sec_34'] = (2910, 1550)
coords['del_noida_sec_52'] = (2980, 1550)
coords['del_noida_sec_61'] = (3070, 1550)
coords['del_noida_sec_59'] = (3160, 1550)
coords['del_noida_sec_62'] = (3250, 1550)
coords['del_noida_electronic_city'] = (3380, 1550)

# 4. Blue Line Branch (Vaishali Branch): Yamuna Bank -> Vaishali
blv_stations = lines_meta['blue_vaishali']['stationIds']
coords['del_laxmi_nagar'] = (2180, 1170)
coords['del_nirman_vihar'] = (2260, 1100)
coords['del_preet_vihar'] = (2340, 1030)
coords['del_karkarduma'] = (2440, 960)
coords['del_anand_vihar_isbt'] = (2540, 960)
coords['del_kaushambi'] = (2660, 960)
coords['del_vaishali'] = (2780, 960)

# 5. Violet Line: Kashmere Gate to Raja Nahar Singh Ballabhgarh
vl_stations = lines_meta['violet']['stationIds']
coords['del_kashmere_gate'] = (1600, 750)
coords['del_lal_quila'] = (1670, 830)
coords['del_jama_masjid'] = (1710, 890)
coords['del_delhi_gate'] = (1750, 960)
coords['del_ito'] = (1790, 1060)
coords['del_mandi_house'] = (1850, 1250)
coords['del_janpath'] = (1730, 1370)
coords['del_central_secretariat'] = (1600, 1450)
coords['del_khan_market'] = (1700, 1540)
coords['del_jawaharlal_nehru_stadium'] = (1780, 1620)
coords['del_jangpura'] = (1860, 1690)
coords['del_lajpat_nagar'] = (1940, 1760)
coords['del_moolchand'] = (1980, 1830)
coords['del_kailash_colony'] = (2020, 1890)
coords['del_nehru_place'] = (2060, 1950)
coords['del_kalkaji_mandir'] = (2100, 2020)

vl_km_idx = vl_stations.index('del_kalkaji_mandir')
vl_faridabad = vl_stations[vl_km_idx + 1:]
for k, sid in enumerate(vl_faridabad):
    y = 2020 + (k + 1) * 55
    coords[sid] = (2100, y)

coords['del_badarpur_border'] = (2100, 2400)
coords['del_raja_nahar_singh'] = (2100, 2950)

# 6. Pink Line Ring Loop (Majlis Park to Shiv Vihar)
pl_stations = lines_meta['pink']['stationIds']
coords['del_majlis_park'] = (1450, 360)
coords['del_azadpur'] = (1300, 470)
coords['del_shalimar_bagh'] = (1140, 580)
coords['del_netaji_subhash_place'] = (980, 750)
coords['del_shakurpur'] = (920, 890)
coords['del_punjabi_bagh_west'] = (880, 1030)
coords['del_esi_basaidarapur'] = (930, 1180)
coords['del_rajouri_garden'] = (1020, 1430)
coords['del_maya_puri'] = (1080, 1550)
coords['del_naraina_vihar'] = (1140, 1640)
coords['del_delhi_cantt'] = (1200, 1720)
coords['del_durgabai_deshmukh_south_campus'] = (1270, 1780)
coords['del_sir_m_vishweshwaraiah_moti_bagh'] = (1360, 1810)
coords['del_bhikaji_cama_place'] = (1440, 1810)
coords['del_sarojini_nagar'] = (1520, 1810)
coords['del_dilli_haat_ina'] = (1600, 1810)
coords['del_south_extension'] = (1770, 1780)
coords['del_lajpat_nagar'] = (1940, 1760)
coords['del_vinobapuri'] = (2050, 1710)
coords['del_ashram'] = (2140, 1630)
coords['del_sarai_kale_khan_hazrat_nizamuddin'] = (2210, 1520)
coords['del_mayur_vihar_1'] = (2280, 1350)
coords['del_mayur_vihar_pocket_1'] = (2350, 1260)
coords['del_trilokpuri_sanjay_lake'] = (2420, 1180)
coords['del_east_vinod_nagar_mayur_vihar_2'] = (2480, 1110)
coords['del_mandawali_west_vinod_nagar'] = (2520, 1050)
coords['del_ip_extension'] = (2540, 1000)
coords['del_anand_vihar_isbt'] = (2540, 960)
coords['del_karkarduma'] = (2440, 960)
coords['del_karkarduma_court'] = (2360, 910)
coords['del_krishna_nagar'] = (2280, 850)
coords['del_east_azad_nagar'] = (2170, 800)
coords['del_welcome'] = (2050, 750)
coords['del_jaffrabad'] = (2050, 640)
coords['del_maujpur_babarpur'] = (2050, 530)
coords['del_gokulpuri'] = (2130, 440)
coords['del_johri_enclave'] = (2210, 360)
coords['del_shiv_vihar'] = (2300, 300)

# 7. Magenta Line: Janakpuri West to Botanical Garden
mg_stations = lines_meta['magenta']['stationIds']
coords['del_janakpuri_west'] = (820, 1650)
coords['del_dabri_mor_janakpuri_south'] = (800, 1770)
coords['del_dashrath_puri'] = (800, 1860)
coords['del_palam'] = (820, 1950)
coords['del_sadaar_bazar_cantonment'] = (870, 2030)
coords['del_terminal_1_igi_airport'] = (950, 2100)
coords['del_shankar_vihar'] = (1050, 2130)
coords['del_vasant_vihar'] = (1160, 2130)
coords['del_munirka'] = (1270, 2130)
coords['del_rk_puram'] = (1380, 2130)
coords['del_iit_delhi'] = (1490, 2100)
coords['del_hauz_khas'] = (1600, 2040)
coords['del_panchsheel_park'] = (1720, 2040)
coords['del_chirag_delhi'] = (1820, 2040)
coords['del_greater_kailash'] = (1920, 2040)
coords['del_nehru_enclave'] = (2010, 2040)
coords['del_kalkaji_mandir'] = (2100, 2020)
coords['del_okhla_nsic'] = (2210, 1970)
coords['del_sukhdev_vihar'] = (2300, 1910)
coords['del_jamia_millia_islamia'] = (2380, 1850)
coords['del_okhla_vihar'] = (2450, 1780)
coords['del_jasola_vihar_shaheen_bagh'] = (2520, 1710)
coords['del_kalindi_kunj'] = (2580, 1640)
coords['del_okhla_bird_sanctuary'] = (2640, 1590)
coords['del_botanical_garden'] = (2700, 1550)

# 8. Airport Express (Orange Line): New Delhi -> Yashobhoomi Dwarka Sec 25
coords['del_new_delhi'] = (1600, 1120)
coords['del_shivaji_stadium'] = (1480, 1280)
coords['del_dhaula_kuan'] = (1230, 1740)
coords['del_delhi_aerocity'] = (990, 2210)
coords['del_igi_airport_t3'] = (780, 2350)
coords['del_dwarka_sec_21'] = (380, 2250)
coords['del_yashobhoomi_dwarka_sec_25'] = (260, 2250)

# 9. Grey Line: Dwarka to Dhansa Bus Stand
coords['del_dwarka'] = (640, 2100)
coords['del_nangli'] = (520, 2100)
coords['del_najafgarh'] = (400, 2100)
coords['del_dhansa_bus_stand'] = (280, 2100)

# 10. Rapid Metro Gurugram
coords['del_sikanderpur'] = (1600, 2720)
coords['del_phase_2'] = (1690, 2660)
coords['del_phase_3'] = (1770, 2660)
coords['del_moulsari_avenue'] = (1850, 2710)
coords['del_cyber_city'] = (1850, 2780)
coords['del_belvedere_towers'] = (1770, 2830)
coords['del_phase_1'] = (1690, 2810)
coords['del_sector_42_43'] = (1690, 2880)
coords['del_sector_53_54'] = (1690, 2950)
coords['del_sector_54_chowk'] = (1690, 3020)
coords['del_sector_55_56'] = (1690, 3090)

# 11. Green Line: Brigadier Hoshiar Singh -> Inderlok / Kirti Nagar
coords['del_inderlok'] = (1220, 750)
coords['del_ashok_park_main'] = (1120, 890)
coords['del_kirti_nagar'] = (1200, 1330)
coords['del_satguru_ram_singh_marg'] = (1160, 1110)
coords['del_punjabi_bagh'] = (1030, 890)
coords['del_shivaji_park'] = (950, 890)
coords['del_madipur'] = (880, 890)
coords['del_paschim_vihar_east'] = (810, 890)
coords['del_paschim_vihar_west'] = (740, 890)
coords['del_peera_garhi'] = (670, 890)
coords['del_udyog_nagar'] = (600, 890)
coords['del_maharaja_surajmal_stadium'] = (530, 890)
coords['del_nangloi'] = (460, 890)
coords['del_nangloi_railway_station'] = (400, 890)
coords['del_rajdhani_park'] = (340, 890)
coords['del_mundka'] = (280, 890)
coords['del_mundka_industrial_area'] = (230, 890)
coords['del_ghevra'] = (180, 890)
coords['del_tikri_kalan'] = (140, 890)
coords['del_tikri_border'] = (100, 890)
coords['del_pandit_shree_ram_sharma'] = (70, 890)
coords['del_bahadurgarh_city'] = (40, 890)
coords['del_brigadier_hoshiar_singh'] = (10, 890)

# 12. Aqua Line (NMRC): Noida Sector 51 to Depot Station Greater Noida
aqua_stations = lines_meta['aqua_noida']['stationIds']
coords['del_noida_sec_51'] = (2980, 1680)
for a_idx, sid in enumerate(aqua_stations):
    if a_idx == 0:
        continue
    elif a_idx <= 14:
        coords[sid] = (2980, 1680 + a_idx * 55)
    else:
        off = a_idx - 14
        coords[sid] = (2980 + off * 65, 1680 + 14 * 55 + off * 45)

missing = [sid for sid in stations_by_id if sid not in coords]
if missing:
    for m in missing:
        coords[m] = (1600, 1250)

def generate_svg_path(station_ids):
    points = [coords[sid] for sid in station_ids if sid in coords]
    if not points:
        return ""
    d = [f"M {points[0][0]:.1f} {points[0][1]:.1f}"]
    for pt in points[1:]:
        d.append(f"L {pt[0]:.1f} {pt[1]:.1f}")
    return " ".join(d)

svg_parts = []
svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" width="100%" height="100%">')

# Clean pure white background
svg_parts.append(f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#FFFFFF"/>')

# Yamuna River
svg_parts.append('<!-- Yamuna River Waterway -->')
svg_parts.append('<path d="M 2350 0 C 2300 450, 2220 750, 2060 1050 C 1950 1280, 2050 1550, 2250 1780 C 2420 1980, 2580 2300, 2640 3200" fill="none" stroke="#E0F2FE" stroke-width="48" stroke-linecap="round"/>')
svg_parts.append('<text x="2100" y="1120" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(58 2100 1120)">YAMUNA RIVER</text>')

# Transfers
svg_parts.append('<!-- Transfer Pathways -->')
dk = coords['del_dhaula_kuan']
sc = coords['del_durgabai_deshmukh_south_campus']
svg_parts.append(f'<line x1="{dk[0]}" y1="{dk[1]}" x2="{sc[0]}" y2="{sc[1]}" stroke="#94A3B8" stroke-width="3" stroke-dasharray="4,4"/>')
svg_parts.append(f'<text x="{(dk[0]+sc[0])/2 - 30}" y="{(dk[1]+sc[1])/2}" font-family="sans-serif" font-size="9" font-weight="600" fill="#64748B">Travelator</text>')

s52 = coords['del_noida_sec_52']
s51 = coords['del_noida_sec_51']
svg_parts.append(f'<line x1="{s52[0]}" y1="{s52[1]}" x2="{s51[0]}" y2="{s51[1]}" stroke="#00BCD4" stroke-width="3.5" stroke-dasharray="5,5"/>')
svg_parts.append(f'<text x="{s52[0] + 12}" y="{(s52[1]+s51[1])/2 + 4}" font-family="sans-serif" font-size="9" font-weight="700" fill="#00838F">Exit - 300 m External Pathway</text>')

ap = coords['del_ashok_park_main']
il = coords['del_inderlok']
kn = coords['del_kirti_nagar']
sr = coords['del_satguru_ram_singh_marg']

line_render_order = [
    ('grey', '#78909C', 8),
    ('rapid_metro', '#0288D1', 8),
    ('aqua_noida', '#00BCD4', 8),
    ('green', '#388E3C', 9),
    ('magenta', '#C2185B', 9),
    ('pink', '#EC407A', 9.5),
    ('violet', '#7B1FA2', 9),
    ('airport_express', '#F57C00', 8.5),
    ('red', '#D32F2F', 9.5),
    ('blue_vaishali', '#1565C0', 9),
    ('blue', '#1976D2', 10),
    ('yellow', '#FBC02D', 10),
]

svg_parts.append('<!-- METRO LINE ROUTES -->')
svg_parts.append('<g stroke-linecap="round" stroke-linejoin="round">')
for lid, color, width in line_render_order:
    if lid not in lines_meta:
        continue
    lm = lines_meta[lid]
    p_data = generate_svg_path(lm['stationIds'])
    svg_parts.append(f'  <path id="route-{lid}" d="{p_data}" fill="none" stroke="{color}" stroke-width="{width}"/>')

svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {il[0]} {il[1]}" fill="none" stroke="#388E3C" stroke-width="9"/>')
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {sr[0]} {sr[1]} L {kn[0]} {kn[1]}" fill="none" stroke="#388E3C" stroke-width="9"/>')
svg_parts.append('</g>')

svg_parts.append('<!-- STATION NODES & BILINGUAL LABELS -->')
svg_parts.append('<g id="stations-layer">')

for s in stations:
    sid = s['id']
    if sid not in coords:
        continue
    x, y = coords[sid]
    is_ic = s.get('isInterchange', False)
    name_en = s['name'].replace('&', '&amp;')
    name_hi = s.get('hindiName', '').replace('&', '&amp;')
    
    dx = 14
    dy = -6
    text_anchor = "start"

    if x > 2800:
        dx = 14
    elif 'yellow' in s['lineIds'] and not is_ic:
        dx = 14
    elif 'red' in s['lineIds'] and not is_ic:
        dx = 0
        dy = -16
        text_anchor = "middle"
    elif 'aqua_noida' in s['lineIds']:
        dx = 14
    elif x < 900:
        dx = -14
        text_anchor = "end"

    if is_ic:
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="11" fill="#FFFFFF" stroke="#0F172A" stroke-width="3"/>')
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="4.5" fill="#0F172A"/>')
        svg_parts.append(f'  <text x="{x + dx}" y="{y + dy}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="10" font-weight="600" fill="#334155">{name_hi}</text>')
        svg_parts.append(f'  <text x="{x + dx}" y="{y + dy + 13}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="12" font-weight="bold" fill="#0F172A">{name_en}</text>')
    else:
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="4.5" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')
        svg_parts.append(f'  <text x="{x + dx}" y="{y + dy}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="9" font-weight="500" fill="#475569">{name_hi}</text>')
        svg_parts.append(f'  <text x="{x + dx}" y="{y + dy + 10}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#0F172A">{name_en}</text>')

svg_parts.append('</g>')

leg_x = 2950
leg_y = 60
leg_w = 780
leg_h = 680

svg_parts.append('<!-- CLEAN LEGEND CARD -->')
svg_parts.append(f'<g transform="translate({leg_x}, {leg_y})">')
svg_parts.append(f'  <rect width="{leg_w}" height="{leg_h}" rx="16" ry="16" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>')
svg_parts.append('  <text x="30" y="42" font-family="sans-serif" font-size="15" font-weight="bold" fill="#0F172A" letter-spacing="1">DELHI NCR METRO NETWORK</text>')
svg_parts.append('  <line x1="30" y1="56" x2="740" y2="56" stroke="#E2E8F0" stroke-width="1.5"/>')

legend_items = [
    ('#D32F2F', 'Red Line: Shaheed Sthal - Rithala'),
    ('#FBC02D', 'Yellow Line: Samaypur Badli - Millennium City Centre'),
    ('#1976D2', 'Blue Line Main: Dwarka Sec 21 - Noida Electronic City'),
    ('#1565C0', 'Blue Line Branch: Yamuna Bank - Vaishali'),
    ('#388E3C', 'Green Line: Brigadier Hoshiar Singh - Inderlok / Kirti Nagar'),
    ('#7B1FA2', 'Violet Line: Kashmere Gate - Raja Nahar Singh (Ballabhgarh)'),
    ('#EC407A', 'Pink Line: Majlis Park - Shiv Vihar (Loop)'),
    ('#C2185B', 'Magenta Line: Janakpuri West - Botanical Garden Noida'),
    ('#78909C', 'Grey Line: Dwarka - Dhansa Bus Stand'),
    ('#F57C00', 'Airport Express: New Delhi - Yashobhoomi Dwarka Sec 25'),
    ('#0288D1', 'Rapid Metro: Gurugram Sikanderpur Loop - Sec 55-56'),
    ('#00BCD4', 'Aqua Line (NMRC): Noida Sector 51 - Depot Station Greater Noida'),
]

for idx, (lcolor, ltext) in enumerate(legend_items):
    item_y = 86 + idx * 36
    svg_parts.append(f'  <circle cx="45" cy="{item_y}" r="6.5" fill="{lcolor}"/>')
    svg_parts.append(f'  <text x="64" y="{item_y + 4}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">{ltext}</text>')

sym_y = 86 + len(legend_items) * 36 + 15
svg_parts.append(f'  <line x1="30" y1="{sym_y - 12}" x2="740" y2="{sym_y - 12}" stroke="#E2E8F0" stroke-width="1.5"/>')
svg_parts.append(f'  <circle cx="45" cy="{sym_y + 12}" r="8" fill="#FFFFFF" stroke="#0F172A" stroke-width="2.5"/>')
svg_parts.append(f'  <circle cx="45" cy="{sym_y + 12}" r="3" fill="#0F172A"/>')
svg_parts.append(f'  <text x="64" y="{sym_y + 16}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">Interchange Station</text>')

svg_parts.append(f'  <circle cx="260" cy="{sym_y + 12}" r="4.5" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')
svg_parts.append(f'  <text x="278" y="{sym_y + 16}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">Regular Station</text>')

svg_parts.append(f'  <line x1="450" y1="{sym_y + 12}" x2="495" y2="{sym_y + 12}" stroke="#00BCD4" stroke-width="3" stroke-dasharray="4,4"/>')
svg_parts.append(f'  <text x="510" y="{sym_y + 16}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">External Transfer (300m)</text>')

svg_parts.append('</g>')
svg_parts.append('</svg>')

svg_content = "\n".join(svg_parts)

with open(OUT_SVG, 'w', encoding='utf-8') as f:
    f.write(svg_content)

print(f"Generated clean Delhi SVG to {OUT_SVG} ({len(svg_content)} bytes)")
