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

WIDTH = 3800
HEIGHT = 3000

# ==========================================
# 1. GEOMETRIC SCHEMATIC ANCHORS
# ==========================================
coords = {}

# 1. Yellow Line: Vertical spine along X = 1450
yl = lines_meta['yellow']['stationIds']
coords['del_samaypur_badli'] = (1450, 160)
coords['del_rohini_sec_18_19'] = (1450, 220)
coords['del_haiderpur_badli_mor'] = (1450, 280)
coords['del_jahangirpuri'] = (1450, 340)
coords['del_adarsh_nagar'] = (1450, 400)
coords['del_azadpur'] = (1450, 470) # Pink interchange
coords['del_model_town'] = (1450, 540)
coords['del_gtb_nagar'] = (1450, 605)
coords['del_vishwavidyalaya'] = (1450, 665)
coords['del_vidhan_sabha'] = (1450, 715)
coords['del_civil_lines'] = (1450, 760)
coords['del_kashmere_gate'] = (1450, 810) # Triple interchange (Red, Yellow, Violet)
coords['del_chandni_chowk'] = (1450, 910)
coords['del_chawri_bazar'] = (1450, 1000)
coords['del_new_delhi'] = (1450, 1090) # Airport Express interchange
coords['del_rajiv_chowk'] = (1450, 1200) # Blue interchange (Canvas Center Hub)
coords['del_patel_chowk'] = (1450, 1315)
coords['del_central_secretariat'] = (1450, 1425) # Violet interchange
coords['del_udyog_bhawan'] = (1450, 1520)
coords['del_lok_kalyan_marg'] = (1450, 1610)
coords['del_jor_bagh'] = (1450, 1700)
coords['del_dilli_haat_ina'] = (1450, 1795) # Pink interchange
coords['del_aiims'] = (1450, 1875)
coords['del_green_park'] = (1450, 1950)
coords['del_hauz_khas'] = (1450, 2040) # Magenta interchange
coords['del_malviya_nagar'] = (1450, 2125)
coords['del_saket'] = (1450, 2200)
coords['del_qutab_minar'] = (1450, 2275)
coords['del_chhattarpur'] = (1450, 2350)
coords['del_sultanpur'] = (1450, 2420)
coords['del_ghitorni'] = (1450, 2480)
coords['del_arjan_garh'] = (1450, 2540)
coords['del_guru_dronacharya'] = (1450, 2600)
coords['del_sikanderpur'] = (1450, 2660) # Rapid Metro interchange
coords['del_mg_road'] = (1450, 2730)
coords['del_iffco_chowk'] = (1360, 2800)
coords['del_millennium_city_centre'] = (1250, 2800)

# 2. Red Line: Horizontal spine along Y = 810
rl = lines_meta['red']['stationIds']
kg_idx = rl.index('del_kashmere_gate')

# West section (Rithala to Tis Hazari)
r_west = rl[:kg_idx]
for idx, sid in enumerate(r_west):
    coords[sid] = (380 + idx * 88, 810)

coords['del_netaji_subhash_place'] = (908, 810) # Pink interchange
coords['del_inderlok'] = (1172, 810) # Green interchange
coords['del_kashmere_gate'] = (1450, 810)

# East section (Shastri Park to Ghaziabad)
r_east = rl[kg_idx+1:]
for j, sid in enumerate(r_east):
    if j < 8: # upto Dilshad Garden
        coords[sid] = (1450 + (j + 1) * 95, 810)
    else: # Ghaziabad branch angled 30° down-right
        step = j - 7
        coords[sid] = (1450 + 8 * 95 + step * 72, 810 + step * 42)

coords['del_welcome'] = (1830, 810) # Pink interchange

# 3. Blue Line Main (Y = 1200 in center)
# West Dwarka Section: X = 250..650, Y = 2480..1950
bl = lines_meta['blue']['stationIds']
for idx in range(9):
    sid = bl[idx]
    coords[sid] = (250 + idx * 45, 2480 - idx * 55)

coords['del_dwarka_sec_21'] = (250, 2480) # Airport Express interchange
coords['del_dwarka'] = (610, 2040) # Grey interchange

# Uttam Nagar to Janakpuri West
for idx in range(9, 14):
    f = (idx - 9) / 4
    sid = bl[idx]
    coords[sid] = (630 + f * 110, 1980 - f * 260)

coords['del_janakpuri_west'] = (740, 1720) # Magenta interchange

# Janakpuri West to Rajouri Garden (ascending diagonal)
for idx in range(14, 19):
    f = (idx - 13) / 5
    sid = bl[idx]
    coords[sid] = (740 + f * 170, 1720 - f * 260)

coords['del_rajouri_garden'] = (910, 1460) # Pink interchange

# Rajouri Garden to Kirti Nagar to Karol Bagh (approaching horizontal)
coords['del_ramesh_nagar'] = (990, 1370)
coords['del_moti_nagar'] = (1060, 1300)
coords['del_kirti_nagar'] = (1130, 1200) # Green interchange
coords['del_shadipur'] = (1200, 1200)
coords['del_patel_nagar'] = (1260, 1200)
coords['del_rajendra_place'] = (1320, 1200)
coords['del_karol_bagh'] = (1370, 1200)
coords['del_jhandewalan'] = (1400, 1200)
coords['del_rk_ashram_marg'] = (1425, 1200)

# Central Horizontal: Rajiv Chowk to Yamuna Bank
coords['del_rajiv_chowk'] = (1450, 1200)
coords['del_barakhamba_road'] = (1580, 1200)
coords['del_mandi_house'] = (1710, 1200) # Violet interchange
coords['del_supreme_court'] = (1840, 1200)
coords['del_indraprastha'] = (1950, 1200)
coords['del_yamuna_bank'] = (2060, 1200) # Branching point

# Descending to Noida (Yamuna Bank to Botanical Garden)
coords['del_akshardham'] = (2150, 1280)
coords['del_mayur_vihar_1'] = (2240, 1360) # Pink interchange
coords['del_mayur_vihar_ext'] = (2320, 1435)
coords['del_new_ashok_nagar'] = (2400, 1500)
coords['del_noida_sec_15'] = (2480, 1560)
coords['del_noida_sec_16'] = (2560, 1615)
coords['del_noida_sec_18'] = (2640, 1665)
coords['del_botanical_garden'] = (2740, 1690) # Magenta interchange

# Noida Corridor (Horizontal along Y = 1690)
coords['del_golf_course'] = (2840, 1690)
coords['del_noida_city_centre'] = (2940, 1690)
coords['del_noida_sec_34'] = (3040, 1690)
coords['del_noida_sec_52'] = (3140, 1690) # Transfer to Aqua Line
coords['del_noida_sec_61'] = (3240, 1690)
coords['del_noida_sec_59'] = (3340, 1690)
coords['del_noida_sec_62'] = (3440, 1690)
coords['del_noida_electronic_city'] = (3560, 1690)

# 4. Blue Line Branch (Yamuna Bank to Vaishali)
coords['del_laxmi_nagar'] = (2150, 1100)
coords['del_nirman_vihar'] = (2240, 1010)
coords['del_preet_vihar'] = (2330, 930)
coords['del_karkarduma'] = (2440, 870) # Pink interchange
coords['del_anand_vihar_isbt'] = (2560, 870) # Pink interchange
coords['del_kaushambi'] = (2670, 870)
coords['del_vaishali'] = (2780, 870)

# 5. Violet Line: East Curve with generous clearance from Yellow Line
# Kashmere Gate (1450, 810) -> Lal Quila -> Mandi House -> Central Sec
coords['del_lal_quila'] = (1620, 880)
coords['del_jama_masjid'] = (1710, 955)
coords['del_delhi_gate'] = (1775, 1030)
coords['del_ito'] = (1800, 1115)
coords['del_mandi_house'] = (1710, 1200) # Crosses Blue Line
coords['del_janpath'] = (1580, 1315)
coords['del_central_secretariat'] = (1450, 1425) # Meets Yellow Line

# South of Central Secretariat: Violet sweeps east to JLN and Lajpat Nagar
coords['del_khan_market'] = (1630, 1515)
coords['del_jawaharlal_nehru_stadium'] = (1740, 1585)
coords['del_jangpura'] = (1840, 1650)
coords['del_lajpat_nagar'] = (1940, 1715) # Pink interchange
coords['del_moolchand'] = (2000, 1785)
coords['del_kailash_colony'] = (2060, 1855)
coords['del_nehru_place'] = (2120, 1925)
coords['del_kalkaji_mandir'] = (2180, 1995) # Magenta interchange

# South along X = 2180 straight into Faridabad
vl = lines_meta['violet']['stationIds']
km_idx = vl.index('del_kalkaji_mandir')
for k, sid in enumerate(vl[km_idx + 1:]):
    coords[sid] = (2180, 1995 + (k + 1) * 52)

# 6. Pink Line: Grand Orbital Ring
coords['del_majlis_park'] = (1300, 360)
coords['del_azadpur'] = (1450, 470) # Yellow interchange
coords['del_shalimar_bagh'] = (1160, 580)
coords['del_netaji_subhash_place'] = (908, 810) # Red interchange
coords['del_shakurpur'] = (820, 960)
coords['del_punjabi_bagh_west'] = (780, 1100) # Green interchange
coords['del_esi_basaidarapur'] = (820, 1270)
coords['del_rajouri_garden'] = (910, 1460) # Blue interchange
coords['del_maya_puri'] = (960, 1570)
coords['del_naraina_vihar'] = (1010, 1655)
coords['del_delhi_cantt'] = (1070, 1735)
coords['del_durgabai_deshmukh_south_campus'] = (1150, 1795)
coords['del_sir_m_vishweshwaraiah_moti_bagh'] = (1230, 1795)
coords['del_bhikaji_cama_place'] = (1310, 1795)
coords['del_sarojini_nagar'] = (1380, 1795)
coords['del_dilli_haat_ina'] = (1450, 1795) # Yellow interchange
coords['del_south_extension'] = (1700, 1770)
coords['del_lajpat_nagar'] = (1940, 1715) # Violet interchange
coords['del_vinobapuri'] = (2040, 1660)
coords['del_ashram'] = (2120, 1590)
coords['del_sarai_kale_khan_hazrat_nizamuddin'] = (2190, 1495)
coords['del_mayur_vihar_1'] = (2240, 1360) # Blue interchange
coords['del_mayur_vihar_pocket_1'] = (2310, 1260)
coords['del_trilokpuri_sanjay_lake'] = (2370, 1170)
coords['del_east_vinod_nagar_mayur_vihar_2'] = (2430, 1085)
coords['del_mandawali_west_vinod_nagar'] = (2480, 1005)
coords['del_ip_extension'] = (2520, 940)
coords['del_anand_vihar_isbt'] = (2560, 870) # Blue Branch interchange
coords['del_karkarduma'] = (2440, 870) # Blue Branch interchange
coords['del_karkarduma_court'] = (2330, 810)
coords['del_krishna_nagar'] = (2210, 760)
coords['del_east_azad_nagar'] = (2080, 730)
coords['del_welcome'] = (1830, 810) # Red interchange
coords['del_jaffrabad'] = (1830, 680)
coords['del_maujpur_babarpur'] = (1830, 560)
coords['del_gokulpuri'] = (1920, 470)
coords['del_johri_enclave'] = (2010, 390)
coords['del_shiv_vihar'] = (2100, 310)

# 7. Magenta Line: Clean Southern Crosstown
coords['del_janakpuri_west'] = (740, 1720) # Blue interchange
coords['del_dabri_mor_janakpuri_south'] = (710, 1840)
coords['del_dashrath_puri'] = (710, 1940)
coords['del_palam'] = (730, 2030)
coords['del_sadaar_bazar_cantonment'] = (780, 2110)
coords['del_terminal_1_igi_airport'] = (850, 2170)
coords['del_shankar_vihar'] = (950, 2200)
coords['del_vasant_vihar'] = (1050, 2200)
coords['del_munirka'] = (1150, 2200)
coords['del_rk_puram'] = (1250, 2200)
coords['del_iit_delhi'] = (1350, 2160)
coords['del_hauz_khas'] = (1450, 2040) # Yellow interchange
coords['del_panchsheel_park'] = (1590, 2040)
coords['del_chirag_delhi'] = (1710, 2040)
coords['del_greater_kailash'] = (1830, 2040)
coords['del_nehru_enclave'] = (1960, 2040)
coords['del_kalkaji_mandir'] = (2180, 1995) # Violet interchange

# Kalkaji to Botanical Garden: graceful ascent to East
coords['del_okhla_nsic'] = (2290, 1930)
coords['del_sukhdev_vihar'] = (2390, 1860)
coords['del_jamia_millia_islamia'] = (2480, 1795)
coords['del_okhla_vihar'] = (2570, 1735)
coords['del_jasola_vihar_shaheen_bagh'] = (2650, 1690)
coords['del_kalindi_kunj'] = (2700, 1690)
coords['del_okhla_bird_sanctuary'] = (2720, 1690)
coords['del_botanical_garden'] = (2740, 1690) # Blue interchange

# 8. Airport Express Line
coords['del_new_delhi'] = (1450, 1090)
coords['del_shivaji_stadium'] = (1310, 1260)
coords['del_dhaula_kuan'] = (1100, 1740)
coords['del_delhi_aerocity'] = (880, 2220)
coords['del_igi_airport_t3'] = (640, 2370)
coords['del_dwarka_sec_21'] = (250, 2480)
coords['del_yashobhoomi_dwarka_sec_25'] = (140, 2480)

# 9. Grey Line
coords['del_dwarka'] = (610, 2040)
coords['del_nangli'] = (480, 2040)
coords['del_najafgarh'] = (350, 2040)
coords['del_dhansa_bus_stand'] = (210, 2040)

# 10. Green Line: Clean Y-Fork Trunk
green_trunk = [
    'del_brigadier_hoshiar_singh', 'del_bahadurgarh_city', 'del_pandit_shree_ram_sharma',
    'del_tikri_border', 'del_tikri_kalan', 'del_ghevra_metro', 'del_mundka_industrial_area',
    'del_mundka', 'del_rajdhani_park', 'del_nangloi_railway_station', 'del_nangloi',
    'del_surajmal_stadium', 'del_udyog_nagar', 'del_peera_garhi', 'del_paschim_vihar_west',
    'del_paschim_vihar_east', 'del_madipur', 'del_shivaji_park', 'del_punjabi_bagh',
    'del_punjabi_bagh_west', 'del_ashok_park_main'
]
g_start = 80
g_end = 1050
for idx, sid in enumerate(green_trunk):
    coords[sid] = (g_start + idx * ((g_end - g_start) / (len(green_trunk)-1)), 970)

coords['del_ashok_park_main'] = (1050, 970)
coords['del_punjabi_bagh_west'] = (780, 1100)
coords['del_inderlok'] = (1172, 810)
coords['del_satguru_ram_singh_marg'] = (1090, 1085)
coords['del_kirti_nagar'] = (1130, 1200)

# 11. Rapid Metro Gurugram
coords['del_sikanderpur'] = (1450, 2660)
coords['del_phase_2'] = (1560, 2600)
coords['del_phase_3'] = (1660, 2600)
coords['del_moulsari_avenue'] = (1760, 2660)
coords['del_cyber_city'] = (1760, 2740)
coords['del_belvedere_towers'] = (1660, 2800)
coords['del_phase_1'] = (1560, 2760)
coords['del_sector_42_43'] = (1560, 2830)
coords['del_sector_53_54'] = (1560, 2890)
coords['del_sector_54_chowk'] = (1560, 2945)
coords['del_sector_55_56'] = (1560, 2990)

# 12. Aqua Line (NMRC): Noida Sec 51 to Greater Noida Depot
coords['del_noida_sec_51'] = (3140, 1800)
aqua_stations = lines_meta['aqua_noida']['stationIds']
for a_idx, sid in enumerate(aqua_stations):
    if a_idx == 0:
        continue
    elif a_idx <= 14:
        coords[sid] = (3140, 1800 + a_idx * 50)
    else:
        off = a_idx - 14
        coords[sid] = (3140 + off * 60, 1800 + 14 * 50 + off * 40)

# Fallback for any missing station
for s in stations:
    if s['id'] not in coords:
        coords[s['id']] = (1450, 1200)

print(f"Total {len(coords)} stations mapped to coordinates.")

# ==========================================
# 2. EXTRACT TRACK LINE SEGMENTS
# ==========================================
line_segments = []

def add_path_segments(station_ids, width=10):
    for i in range(len(station_ids) - 1):
        s1 = station_ids[i]
        s2 = station_ids[i+1]
        if s1 in coords and s2 in coords:
            p1 = coords[s1]
            p2 = coords[s2]
            line_segments.append((p1, p2, width))

# Add all line segments
for lid, linfo in lines_meta.items():
    if lid == 'green':
        # Green trunk + branches
        add_path_segments(green_trunk, 9)
        ap = coords['del_ashok_park_main']
        il = coords['del_inderlok']
        sr = coords['del_satguru_ram_singh_marg']
        kn = coords['del_kirti_nagar']
        line_segments.append((ap, il, 9))
        line_segments.append((ap, sr, 9))
        line_segments.append((sr, kn, 9))
    else:
        add_path_segments(linfo['stationIds'], 9)

print(f"Extracted {len(line_segments)} track line segments for collision detection.")

# ==========================================
# 3. MATHEMATICAL COLLISION DETECTION ENGINE
# ==========================================
def dist_pt_to_seg(px, py, x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1
    if dx == 0 and dy == 0:
        return math.hypot(px - x1, py - y1)
    t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
    t = max(0.0, min(1.0, t))
    proj_x = x1 + t * dx
    proj_y = y1 + t * dy
    return math.hypot(px - proj_x, py - proj_y)

def seg_intersects_seg(p1, p2, p3, p4):
    def ccw(A, B, C):
        return (C[1]-A[1]) * (B[0]-A[0]) > (B[1]-A[1]) * (C[0]-A[0])
    return (ccw(p1, p3, p4) != ccw(p2, p3, p4)) and (ccw(p1, p2, p3) != ccw(p1, p2, p4))

def seg_intersects_rect(p1, p2, rx1, ry1, rx2, ry2):
    if (rx1 <= p1[0] <= rx2 and ry1 <= p1[1] <= ry2) or (rx1 <= p2[0] <= rx2 and ry1 <= p2[1] <= ry2):
        return True
    corners = [(rx1, ry1), (rx2, ry1), (rx2, ry2), (rx1, ry2)]
    for i in range(4):
        c1 = corners[i]
        c2 = corners[(i+1)%4]
        if seg_intersects_seg(p1, p2, c1, c2):
            return True
    return False

def rect_overlaps_rect(r1, r2):
    return not (r1[2] < r2[0] or r1[0] > r2[2] or r1[3] < r2[1] or r1[1] > r2[3])

# ==========================================
# 4. INTELLIGENT LABEL PLACER
# ==========================================
placed_labels = {}

STATION_BIAS = {
    # Kashmere Gate Hub: Label placed safely ABOVE both Red & Yellow tracks
    'del_kashmere_gate': {'side': 'top_left', 'angle': 0},
    'del_gtb_nagar': {'side': 'right', 'angle': 0},
    'del_vishwavidyalaya': {'side': 'right', 'angle': 0},
    'del_vidhan_sabha': {'side': 'right', 'angle': 0},
    'del_civil_lines': {'side': 'right', 'angle': 0},
    'del_chandni_chowk': {'side': 'left', 'angle': 0}, # Yellow line: face WEST away from Lal Quila
    'del_chawri_bazar': {'side': 'left', 'angle': 0},
    'del_new_delhi': {'side': 'left', 'angle': 0},
    'del_rajiv_chowk': {'side': 'top_right', 'angle': 0},
    'del_patel_chowk': {'side': 'left', 'angle': 0},
    'del_central_secretariat': {'side': 'left', 'angle': 0},
    'del_udyog_bhawan': {'side': 'left', 'angle': 0}, # Face WEST away from Violet Line!
    'del_lok_kalyan_marg': {'side': 'left', 'angle': 0},
    'del_jor_bagh': {'side': 'left', 'angle': 0},
    'del_aiims': {'side': 'left', 'angle': 0},
    'del_green_park': {'side': 'left', 'angle': 0},
    'del_malviya_nagar': {'side': 'left', 'angle': 0},
    'del_saket': {'side': 'left', 'angle': 0},
    'del_qutab_minar': {'side': 'left', 'angle': 0},
    'del_chhattarpur': {'side': 'left', 'angle': 0},
    'del_sultanpur': {'side': 'left', 'angle': 0},

    # Violet Line (North): Face EAST
    'del_lal_quila': {'side': 'right', 'angle': 0},
    'del_jama_masjid': {'side': 'right', 'angle': 0},
    'del_delhi_gate': {'side': 'right', 'angle': 0},
    'del_ito': {'side': 'right', 'angle': 0},
    'del_janpath': {'side': 'right', 'angle': 0},

    # Violet Line (South of Central Sec): Face EAST away from Yellow Line!
    'del_khan_market': {'side': 'right', 'angle': 0},
    'del_jawaharlal_nehru_stadium': {'side': 'right', 'angle': 0},
    'del_jangpura': {'side': 'right', 'angle': 0},
    'del_lajpat_nagar': {'side': 'right', 'angle': 0},

    # Blue Line Central
    'del_barakhamba_road': {'side': 'bottom', 'angle': 0},
    'del_mandi_house': {'side': 'top', 'angle': 0},
    'del_supreme_court': {'side': 'bottom', 'angle': 0},
    'del_indraprastha': {'side': 'top', 'angle': 0},

    # Magenta Line East (Kalkaji to Botanical Garden) - HORIZONTAL to avoid overlapping track!
    'del_okhla_nsic': {'side': 'bottom_right', 'angle': 0},
    'del_sukhdev_vihar': {'side': 'bottom_right', 'angle': 0},
    'del_jamia_millia_islamia': {'side': 'bottom_right', 'angle': 0},
    'del_okhla_vihar': {'side': 'bottom_right', 'angle': 0},
    'del_jasola_vihar_shaheen_bagh': {'side': 'bottom_right', 'angle': 0},
    'del_kalindi_kunj': {'side': 'bottom_right', 'angle': 0},
    'del_okhla_bird_sanctuary': {'side': 'bottom_right', 'angle': 0},
    'del_botanical_garden': {'side': 'top_right', 'angle': 0},
}

sorted_stations = sorted(stations, key=lambda s: (0 if s.get('isInterchange') else 1, s['id']))

for s in sorted_stations:
    sid = s['id']
    sx, sy = coords[sid]
    name_en = s['name']
    name_hi = s.get('hindiName', '')
    is_ic = s.get('isInterchange', False)

    char_len = max(len(name_en), len(name_hi))
    label_w = max(char_len * 7.0 + 16, 75)
    label_h = 32 if is_ic else 28

    candidates = []

    # 1. Right (horizontal)
    candidates.append({
        'name': 'right',
        'angle': 0,
        'lx': sx + 16,
        'ly': sy - 4,
        'anchor': 'start',
        'rx': sx + 14,
        'ry': sy - 18,
        'rw': label_w,
        'rh': label_h
    })

    # 2. Left (horizontal)
    candidates.append({
        'name': 'left',
        'angle': 0,
        'lx': sx - 16,
        'ly': sy - 4,
        'anchor': 'end',
        'rx': sx - 16 - label_w,
        'ry': sy - 18,
        'rw': label_w,
        'rh': label_h
    })

    # 3. Top (horizontal)
    candidates.append({
        'name': 'top',
        'angle': 0,
        'lx': sx,
        'ly': sy - 20,
        'anchor': 'middle',
        'rx': sx - label_w / 2,
        'ry': sy - 20 - label_h + 14,
        'rw': label_w,
        'rh': label_h
    })

    # 4. Bottom (horizontal)
    candidates.append({
        'name': 'bottom',
        'angle': 0,
        'lx': sx,
        'ly': sy + 22,
        'anchor': 'middle',
        'rx': sx - label_w / 2,
        'ry': sy + 10,
        'rw': label_w,
        'rh': label_h
    })

    # 5. Top-Right Angled -45 (great for horizontal tracks like Red/Green line)
    box_extent = label_w * 0.72
    candidates.append({
        'name': 'top_right_angled',
        'angle': -45,
        'lx': sx + 10,
        'ly': sy - 12,
        'anchor': 'start',
        'rx': sx + 8,
        'ry': sy - 12 - box_extent,
        'rw': box_extent + 20,
        'rh': box_extent + 20
    })

    # 6. Bottom-Right Offset Horizontal (under diagonal track)
    candidates.append({
        'name': 'bottom_right',
        'angle': 0,
        'lx': sx + 16,
        'ly': sy + 18,
        'anchor': 'start',
        'rx': sx + 14,
        'ry': sy + 4,
        'rw': label_w,
        'rh': label_h
    })

    # 7. Top-Left (for Kashmere gate or junctions)
    candidates.append({
        'name': 'top_left',
        'angle': 0,
        'lx': sx - 16,
        'ly': sy - 24,
        'anchor': 'end',
        'rx': sx - 16 - label_w,
        'ry': sy - 24 - label_h + 14,
        'rw': label_w,
        'rh': label_h
    })

    best_cand = None
    min_penalty = float('inf')

    bias_info = STATION_BIAS.get(sid)

    for cand in candidates:
        penalty = 0
        r_box = (cand['rx'], cand['ry'], cand['rx'] + cand['rw'], cand['ry'] + cand['rh'])

        if bias_info and cand['name'] == bias_info['side']:
            penalty -= 20000

        if cand['name'] in ('right', 'left'):
            penalty += 50
        elif cand['name'] in ('top', 'bottom'):
            penalty += 200
        elif cand['name'] == 'top_right_angled':
            penalty += 400

        for p1, p2, w in line_segments:
            is_endpoint = (math.hypot(p1[0]-sx, p1[1]-sy) < 2) or (math.hypot(p2[0]-sx, p2[1]-sy) < 2)
            if seg_intersects_rect(p1, p2, r_box[0], r_box[1], r_box[2], r_box[3]):
                if is_endpoint:
                    penalty += 3000
                else:
                    penalty += 80000

        for other_sid, other_info in placed_labels.items():
            o_box = other_info['box']
            if rect_overlaps_rect(r_box, o_box):
                penalty += 150000

        for osid, opt in coords.items():
            if osid != sid:
                if r_box[0] <= opt[0] <= r_box[2] and r_box[1] <= opt[1] <= r_box[3]:
                    penalty += 40000

        if penalty < min_penalty:
            min_penalty = penalty
            best_cand = cand

    cand = best_cand
    cand['box'] = (cand['rx'], cand['ry'], cand['rx'] + cand['rw'], cand['ry'] + cand['rh'])
    placed_labels[sid] = cand

print("Optimal collision-free label placements computed for all stations.")

# ==========================================
# 5. GENERATE CLEAN SVG
# ==========================================
svg_parts = []
svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" width="100%" height="100%">')

svg_parts.append(f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#FFFFFF"/>')

# Graceful Yamuna River (Curved Band)
svg_parts.append('<!-- Yamuna River -->')
svg_parts.append('<path d="M 2250 0 C 2200 400, 2150 750, 1980 1020 C 1880 1200, 1950 1480, 2150 1720 C 2320 1920, 2480 2200, 2550 3000" fill="none" stroke="#E0F2FE" stroke-width="54" stroke-linecap="round"/>')
svg_parts.append('<text x="2000" y="1080" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(56 2000 1080)">YAMUNA RIVER</text>')

# External Pathways
svg_parts.append('<!-- External Transfers -->')
dk = coords['del_dhaula_kuan']
sc = coords['del_durgabai_deshmukh_south_campus']
svg_parts.append(f'<line x1="{dk[0]}" y1="{dk[1]}" x2="{sc[0]}" y2="{sc[1]}" stroke="#94A3B8" stroke-width="3" stroke-dasharray="4,4"/>')
svg_parts.append(f'<text x="{(dk[0]+sc[0])/2 - 25}" y="{(dk[1]+sc[1])/2 - 6}" font-family="sans-serif" font-size="9" font-weight="bold" fill="#64748B">Travelator</text>')

s52 = coords['del_noida_sec_52']
s51 = coords['del_noida_sec_51']
svg_parts.append(f'<line x1="{s52[0]}" y1="{s52[1]}" x2="{s51[0]}" y2="{s51[1]}" stroke="#00BCD4" stroke-width="3.5" stroke-dasharray="5,5"/>')
svg_parts.append(f'<text x="{s52[0] + 16}" y="{(s52[1]+s51[1])/2 + 4}" font-family="sans-serif" font-size="9.5" font-weight="bold" fill="#00838F">Exit - 300 m External Pathway</text>')

# Metro Line paths
svg_parts.append('<!-- LINES LAYER -->')
svg_parts.append('<g stroke-linecap="round" stroke-linejoin="round">')

def generate_svg_path(s_list):
    pts = [coords[sid] for sid in s_list if sid in coords]
    if not pts:
        return ""
    d = [f"M {pts[0][0]:.1f} {pts[0][1]:.1f}"]
    for p in pts[1:]:
        d.append(f"L {p[0]:.1f} {p[1]:.1f}")
    return " ".join(d)

line_render_order = [
    ('grey', '#78909C', 8, lines_meta['grey']['stationIds']),
    ('rapid_metro', '#0288D1', 8, lines_meta['rapid_metro']['stationIds']),
    ('aqua_noida', '#00BCD4', 8, lines_meta['aqua_noida']['stationIds']),
    ('magenta', '#C2185B', 9, lines_meta['magenta']['stationIds']),
    ('pink', '#EC407A', 9.5, lines_meta['pink']['stationIds']),
    ('violet', '#7B1FA2', 9, lines_meta['violet']['stationIds']),
    ('airport_express', '#F57C00', 8.5, lines_meta['airport_express']['stationIds']),
    ('red', '#D32F2F', 9.5, lines_meta['red']['stationIds']),
    ('blue_vaishali', '#1565C0', 9, lines_meta['blue_vaishali']['stationIds']),
    ('blue', '#1976D2', 10, lines_meta['blue']['stationIds']),
    ('yellow', '#FBC02D', 10, lines_meta['yellow']['stationIds']),
]

for lid, color, width, s_list in line_render_order:
    d = generate_svg_path(s_list)
    svg_parts.append(f'  <path id="route-{lid}" d="{d}" fill="none" stroke="{color}" stroke-width="{width}"/>')

# Green Line Trunk + 2 distinct branches
green_d = generate_svg_path(green_trunk)
svg_parts.append(f'  <path id="route-green-trunk" d="{green_d}" fill="none" stroke="#388E3C" stroke-width="9"/>')
ap = coords['del_ashok_park_main']
il = coords['del_inderlok']
sr = coords['del_satguru_ram_singh_marg']
kn = coords['del_kirti_nagar']
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {il[0]} {il[1]}" fill="none" stroke="#388E3C" stroke-width="9"/>')
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {sr[0]} {sr[1]} L {kn[0]} {kn[1]}" fill="none" stroke="#388E3C" stroke-width="9"/>')

svg_parts.append('</g>')

# Station Nodes & Typography with Smart White Backdrop Capsule (Zero line crossing interference!)
svg_parts.append('<!-- STATIONS & SMART LABELS LAYER -->')
svg_parts.append('<g id="stations-layer">')

for s in stations:
    sid = s['id']
    x, y = coords[sid]
    is_ic = s.get('isInterchange', False)
    name_en = s['name'].replace('&', '&amp;')
    name_hi = s.get('hindiName', '').replace('&', '&amp;')
    
    cand = placed_labels[sid]
    angle = cand['angle']
    lx = cand['lx']
    ly = cand['ly']
    anchor = cand['anchor']
    rx = cand['rx']
    ry = cand['ry']
    rw = cand['rw']
    rh = cand['rh']

    transform_attr = f' transform="rotate({angle} {lx} {ly})"' if angle != 0 else ''
    
    if angle == 0:
        svg_parts.append(f'  <rect x="{rx:.1f}" y="{ry:.1f}" width="{rw:.1f}" height="{rh:.1f}" rx="4" ry="4" fill="#FFFFFF" fill-opacity="0.94"/>')
    else:
        svg_parts.append(f'  <rect x="{lx - 2:.1f}" y="{ly - 18:.1f}" width="{rw:.1f}" height="{rh:.1f}" rx="4" ry="4" fill="#FFFFFF" fill-opacity="0.94"{transform_attr}/>')

    if is_ic:
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="10" fill="#FFFFFF" stroke="#0F172A" stroke-width="3"/>')
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="4" fill="#0F172A"/>')
    else:
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="4" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')

    if is_ic:
        svg_parts.append(f'  <g{transform_attr}>')
        if name_hi:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="bold" fill="#334155">{name_hi}</text>')
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 14:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="13.5" font-weight="900" fill="#020617">{name_en}</text>')
        else:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 6:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="13.5" font-weight="900" fill="#020617">{name_en}</text>')
        svg_parts.append('  </g>')
    else:
        svg_parts.append(f'  <g{transform_attr}>')
        if name_hi:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="9.5" font-weight="600" fill="#475569">{name_hi}</text>')
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 12:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11" font-weight="bold" fill="#0F172A">{name_en}</text>')
        else:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11" font-weight="bold" fill="#0F172A">{name_en}</text>')
        svg_parts.append('  </g>')

svg_parts.append('</g>')

# Clean Legend Card (Top Right)
leg_x = 2950
leg_y = 50
leg_w = 780
leg_h = 680

svg_parts.append('<!-- CLEAN LEGEND CARD -->')
svg_parts.append(f'<g transform="translate({leg_x}, {leg_y})">')
svg_parts.append(f'  <rect width="{leg_w}" height="{leg_h}" rx="16" ry="16" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>')
svg_parts.append('  <text x="30" y="40" font-family="sans-serif" font-size="15" font-weight="bold" fill="#0F172A" letter-spacing="1">DELHI NCR METRO NETWORK</text>')
svg_parts.append('  <line x1="30" y1="54" x2="740" y2="54" stroke="#E2E8F0" stroke-width="1.5"/>')

legend_items = [
    ('#D32F2F', 'Red Line: Shaheed Sthal - Rithala'),
    ('#FBC02D', 'Yellow Line: Samaypur Badli - Millennium City Centre'),
    ('#1976D2', 'Blue Line Main: Dwarka Sec 21 - Noida Electronic City'),
    ('#1565C0', 'Blue Line Branch: Yamuna Bank - Vaishali'),
    ('#388E3C', 'Green Line: Brigadier Hoshiar Singh - Inderlok / Kirti Nagar'),
    ('#7B1FA2', 'Violet Line: Kashmere Gate - Raja Nahar Singh (Ballabhgarh)'),
    ('#EC407A', 'Pink Line: Majlis Park - Shiv Vihar (Ring Loop)'),
    ('#C2185B', 'Magenta Line: Janakpuri West - Botanical Garden Noida'),
    ('#78909C', 'Grey Line: Dwarka - Dhansa Bus Stand'),
    ('#F57C00', 'Airport Express: New Delhi - Yashobhoomi Dwarka Sec 25'),
    ('#0288D1', 'Rapid Metro: Gurugram Sikanderpur Loop - Sec 55-56'),
    ('#00BCD4', 'Aqua Line (NMRC): Noida Sector 51 - Depot Station Greater Noida'),
]

for idx, (lcolor, ltext) in enumerate(legend_items):
    item_y = 82 + idx * 36
    svg_parts.append(f'  <circle cx="45" cy="{item_y}" r="6.5" fill="{lcolor}"/>')
    svg_parts.append(f'  <text x="64" y="{item_y + 4}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">{ltext}</text>')

sym_y = 82 + len(legend_items) * 36 + 15
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

os.makedirs(os.path.dirname(OUT_SVG), exist_ok=True)
with open(OUT_SVG, 'w', encoding='utf-8') as f:
    f.write(svg_content)

print(f"Successfully generated smart collision-free Delhi SVG to {OUT_SVG} ({len(svg_content)} bytes)")
