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

WIDTH = 4500
HEIGHT = 3450

# ==========================================
# 1. GEOMETRIC SCHEMATIC ANCHORS (GENEROUS SPACING)
# ==========================================
coords = {}
label_rules = {} # sid -> {'angle': float, 'dx': float, 'dy': float, 'anchor': str}

# ------------------------------------------
# 1. YELLOW LINE: Vertical spine along X = 1600
# ------------------------------------------
yl = lines_meta['yellow']['stationIds']
coords['del_samaypur_badli'] = (1600, 160)
coords['del_rohini_sec_18_19'] = (1600, 225)
coords['del_haiderpur_badli_mor'] = (1600, 290)
coords['del_jahangirpuri'] = (1600, 355)
coords['del_adarsh_nagar'] = (1600, 420)
coords['del_azadpur'] = (1600, 490) # Pink interchange
coords['del_model_town'] = (1600, 560)
coords['del_gtb_nagar'] = (1600, 625)
coords['del_vishwavidyalaya'] = (1600, 690)
coords['del_vidhan_sabha'] = (1600, 745)
coords['del_civil_lines'] = (1600, 795)
coords['del_kashmere_gate'] = (1600, 850) # Red & Violet interchange
coords['del_chandni_chowk'] = (1600, 960)
coords['del_chawri_bazar'] = (1600, 1060)
coords['del_new_delhi'] = (1600, 1160) # Airport Express interchange
coords['del_rajiv_chowk'] = (1600, 1280) # Blue interchange (Canvas Center Hub)
coords['del_patel_chowk'] = (1600, 1400)
coords['del_central_secretariat'] = (1600, 1520) # Violet interchange
coords['del_udyog_bhawan'] = (1600, 1620)
coords['del_lok_kalyan_marg'] = (1600, 1715)
coords['del_jor_bagh'] = (1600, 1810)
coords['del_dilli_haat_ina'] = (1600, 1905) # Pink interchange
coords['del_aiims'] = (1600, 1990)
coords['del_green_park'] = (1600, 2075)
coords['del_hauz_khas'] = (1600, 2165) # Magenta interchange
coords['del_malviya_nagar'] = (1600, 2255)
coords['del_saket'] = (1600, 2340)
coords['del_qutab_minar'] = (1600, 2425)
coords['del_chhattarpur'] = (1600, 2510)
coords['del_sultanpur'] = (1600, 2590)
coords['del_ghitorni'] = (1600, 2660)
coords['del_arjan_garh'] = (1600, 2730)
coords['del_guru_dronacharya'] = (1600, 2800)
coords['del_sikanderpur'] = (1600, 2870) # Rapid Metro interchange
coords['del_mg_road'] = (1600, 2940)
coords['del_iffco_chowk'] = (1490, 3010)
coords['del_millennium_city_centre'] = (1360, 3010)

# Rules for Yellow Line:
for sid in yl:
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}

# Sensitive Yellow stations: Face WEST (Left) away from Violet Line
for sid in ['del_chandni_chowk', 'del_chawri_bazar', 'del_new_delhi', 'del_patel_chowk',
            'del_central_secretariat', 'del_udyog_bhawan', 'del_lok_kalyan_marg', 'del_jor_bagh',
            'del_aiims', 'del_green_park', 'del_malviya_nagar', 'del_saket', 'del_qutab_minar',
            'del_chhattarpur', 'del_sultanpur']:
    label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -3, 'anchor': 'end'}

# ------------------------------------------
# 2. RED LINE: Horizontal spine along Y = 850
# ------------------------------------------
rl = lines_meta['red']['stationIds']
kg_idx = rl.index('del_kashmere_gate')

# West section (Rithala to Tis Hazari)
r_west = rl[:kg_idx]
for idx, sid in enumerate(r_west):
    coords[sid] = (420 + idx * 90, 850)
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}

coords['del_netaji_subhash_place'] = (960, 850) # Pink interchange
coords['del_inderlok'] = (1230, 850) # Green interchange
coords['del_tis_hazari'] = (1500, 850)
coords['del_kashmere_gate'] = (1600, 850) # Triple interchange

# Kashmere Gate label: Place above Red Line with upper offset
label_rules['del_kashmere_gate'] = {'angle': 0, 'dx': 22, 'dy': -24, 'anchor': 'start'}

# East section (Shastri Park to Ghaziabad)
r_east = rl[kg_idx+1:]
for j, sid in enumerate(r_east):
    if j < 8: # upto Dilshad Garden
        coords[sid] = (1600 + (j + 1) * 105, 850)
        label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}
    else: # Ghaziabad branch angled 30° down-right
        step = j - 7
        coords[sid] = (1600 + 8 * 105 + step * 80, 850 + step * 48)
        label_rules[sid] = {'angle': -30, 'dx': 12, 'dy': -6, 'anchor': 'start'}

coords['del_welcome'] = (1915, 850) # Pink interchange
label_rules['del_welcome'] = {'angle': -45, 'dx': 10, 'dy': -16, 'anchor': 'start'}

# ------------------------------------------
# 3. BLUE LINE MAIN: Horizontal central at Y = 1280
# ------------------------------------------
bl = lines_meta['blue']['stationIds']

# Dwarka Section: Vertical spine at X = 160
for idx in range(9):
    sid = bl[idx]
    coords[sid] = (160, 2900 - idx * 65)
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

coords['del_dwarka_sec_21'] = (160, 2900)
coords['del_dwarka'] = (160, 2380) # Grey interchange

# Uttam Nagar to Janakpuri West (Ascending diagonal)
for idx in range(9, 14):
    f = (idx - 9) / 4
    sid = bl[idx]
    coords[sid] = (160 + f * 140, 2380 - f * 340)
    label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}

coords['del_janakpuri_west'] = (300, 2040) # Magenta interchange

# Janakpuri West to Rajouri Garden (Ascending diagonal)
for idx in range(14, 19):
    f = (idx - 13) / 5
    sid = bl[idx]
    coords[sid] = (300 + f * 220, 2040 - f * 380)
    label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}

coords['del_rajouri_garden'] = (520, 1660) # Pink interchange

# Rajouri Garden to Kirti Nagar
coords['del_ramesh_nagar'] = (640, 1540)
coords['del_moti_nagar'] = (760, 1430)
coords['del_kirti_nagar'] = (880, 1280) # Green interchange

label_rules['del_ramesh_nagar'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
label_rules['del_moti_nagar'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
label_rules['del_kirti_nagar'] = {'angle': 0, 'dx': -18, 'dy': -10, 'anchor': 'end'}

# Central Horizontal: Kirti Nagar to Rajiv Chowk (Ample 110-120px between each!)
coords['del_shadipur'] = (1000, 1280)
coords['del_patel_nagar'] = (1120, 1280)
coords['del_rajendra_place'] = (1240, 1280)
coords['del_karol_bagh'] = (1350, 1280)
coords['del_jhandewalan'] = (1445, 1280)
coords['del_rk_ashram_marg'] = (1530, 1280)
coords['del_rajiv_chowk'] = (1600, 1280) # Center Hub

for sid in ['del_shadipur', 'del_patel_nagar', 'del_rajendra_place', 'del_karol_bagh', 'del_jhandewalan', 'del_rk_ashram_marg']:
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}

label_rules['del_rajiv_chowk'] = {'angle': 0, 'dx': 22, 'dy': -18, 'anchor': 'start'}

# East of Rajiv Chowk: Wide spacing through Mandi House to Yamuna Bank
coords['del_barakhamba_road'] = (1750, 1280)
coords['del_mandi_house'] = (1910, 1280) # Violet interchange
coords['del_supreme_court'] = (2060, 1280)
coords['del_indraprastha'] = (2200, 1280)
coords['del_yamuna_bank'] = (2350, 1280) # Branching point

label_rules['del_barakhamba_road'] = {'angle': 0, 'dx': 0, 'dy': 26, 'anchor': 'middle'}
label_rules['del_mandi_house'] = {'angle': 0, 'dx': 0, 'dy': -24, 'anchor': 'middle'}
label_rules['del_supreme_court'] = {'angle': 0, 'dx': 0, 'dy': 26, 'anchor': 'middle'}
label_rules['del_indraprastha'] = {'angle': 0, 'dx': 0, 'dy': -24, 'anchor': 'middle'}
label_rules['del_yamuna_bank'] = {'angle': 0, 'dx': 22, 'dy': -8, 'anchor': 'start'}

# Descending to Noida (Yamuna Bank to Botanical Garden)
coords['del_akshardham'] = (2480, 1370)
coords['del_mayur_vihar_1'] = (2600, 1460) # Pink interchange
coords['del_mayur_vihar_ext'] = (2720, 1540)
coords['del_new_ashok_nagar'] = (2840, 1610)
coords['del_noida_sec_15'] = (2960, 1675)
coords['del_noida_sec_16'] = (3080, 1730)
coords['del_noida_sec_18'] = (3200, 1780)
coords['del_botanical_garden'] = (3340, 1800) # Magenta interchange

for sid in ['del_akshardham', 'del_mayur_vihar_1', 'del_mayur_vihar_ext', 'del_new_ashok_nagar',
            'del_noida_sec_15', 'del_noida_sec_16', 'del_noida_sec_18']:
    label_rules[sid] = {'angle': -45, 'dx': 10, 'dy': -14, 'anchor': 'start'}

label_rules['del_botanical_garden'] = {'angle': 0, 'dx': 18, 'dy': -22, 'anchor': 'start'}

# Noida Expressway Corridor: Horizontal along Y = 1800 with 110px spacing
coords['del_golf_course'] = (3470, 1800)
coords['del_noida_city_centre'] = (3590, 1800)
coords['del_noida_sec_34'] = (3700, 1800)
coords['del_noida_sec_52'] = (3810, 1800) # Transfer to Aqua Line
coords['del_noida_sec_61'] = (3920, 1800)
coords['del_noida_sec_59'] = (4030, 1800)
coords['del_noida_sec_62'] = (4140, 1800)
coords['del_noida_electronic_city'] = (4260, 1800)

for sid in ['del_golf_course', 'del_noida_city_centre', 'del_noida_sec_34', 'del_noida_sec_52',
            'del_noida_sec_61', 'del_noida_sec_59', 'del_noida_sec_62', 'del_noida_electronic_city']:
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}

# ------------------------------------------
# 4. BLUE LINE BRANCH: Yamuna Bank to Vaishali
# ------------------------------------------
coords['del_laxmi_nagar'] = (2470, 1170)
coords['del_nirman_vihar'] = (2580, 1075)
coords['del_preet_vihar'] = (2690, 990)
coords['del_karkarduma'] = (2820, 930) # Pink interchange
coords['del_anand_vihar_isbt'] = (2960, 930) # Pink interchange
coords['del_kaushambi'] = (3090, 930)
coords['del_vaishali'] = (3220, 930)

for sid in ['del_laxmi_nagar', 'del_nirman_vihar', 'del_preet_vihar', 'del_karkarduma',
            'del_anand_vihar_isbt', 'del_kaushambi', 'del_vaishali']:
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}

# ------------------------------------------
# 5. VIOLET LINE: East sweep with generous clearance from Yellow Line
# ------------------------------------------
coords['del_lal_quila'] = (1750, 920)
coords['del_jama_masjid'] = (1860, 995)
coords['del_delhi_gate'] = (1940, 1080)
coords['del_ito'] = (1970, 1175)
coords['del_mandi_house'] = (1910, 1280) # Crosses Blue Line
coords['del_janpath'] = (1760, 1400)
coords['del_central_secretariat'] = (1600, 1520) # Meets Yellow Line

for sid in ['del_lal_quila', 'del_jama_masjid', 'del_delhi_gate', 'del_ito', 'del_janpath']:
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}

# South of Central Secretariat: Violet Line sweeps east to JLN and Lajpat Nagar
coords['del_khan_market'] = (1780, 1620)
coords['del_jawaharlal_nehru_stadium'] = (1910, 1700)
coords['del_jangpura'] = (2030, 1770)
coords['del_lajpat_nagar'] = (2150, 1840) # Pink interchange
coords['del_moolchand'] = (2230, 1915)
coords['del_kailash_colony'] = (2310, 1985)
coords['del_nehru_place'] = (2390, 2055)
coords['del_kalkaji_mandir'] = (2470, 2125) # Magenta interchange

for sid in ['del_khan_market', 'del_jawaharlal_nehru_stadium', 'del_jangpura', 'del_lajpat_nagar',
            'del_moolchand', 'del_kailash_colony', 'del_nehru_place', 'del_kalkaji_mandir']:
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}

# South along X = 2470 straight into Faridabad
vl = lines_meta['violet']['stationIds']
km_idx = vl.index('del_kalkaji_mandir')
for k, sid in enumerate(vl[km_idx + 1:]):
    coords[sid] = (2470, 2125 + (k + 1) * 58)
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}

# ------------------------------------------
# 6. PINK LINE: Grand Orbital Ring
# ------------------------------------------
coords['del_majlis_park'] = (1420, 370)
coords['del_azadpur'] = (1600, 490) # Yellow interchange
coords['del_shalimar_bagh'] = (1280, 600)
coords['del_netaji_subhash_place'] = (960, 850) # Red interchange
coords['del_shakurpur'] = (840, 1020)
coords['del_punjabi_bagh_west'] = (790, 1170) # Green interchange
coords['del_esi_basaidarapur'] = (820, 1370)
coords['del_rajouri_garden'] = (520, 1660) # Blue interchange
coords['del_maya_puri'] = (600, 1780)
coords['del_naraina_vihar'] = (690, 1870)
coords['del_delhi_cantt'] = (800, 1940)
coords['del_durgabai_deshmukh_south_campus'] = (930, 1990)
coords['del_sir_m_vishweshwaraiah_moti_bagh'] = (1090, 1990)
coords['del_bhikaji_cama_place'] = (1250, 1990)
coords['del_sarojini_nagar'] = (1410, 1990)
coords['del_dilli_haat_ina'] = (1600, 1905) # Yellow interchange
coords['del_south_extension'] = (1870, 1880)
coords['del_lajpat_nagar'] = (2150, 1840) # Violet interchange
coords['del_vinobapuri'] = (2260, 1780)
coords['del_ashram'] = (2360, 1700)
coords['del_sarai_kale_khan_hazrat_nizamuddin'] = (2450, 1600)
coords['del_mayur_vihar_1'] = (2600, 1460) # Blue interchange
coords['del_mayur_vihar_pocket_1'] = (2690, 1350)
coords['del_trilokpuri_sanjay_lake'] = (2760, 1250)
coords['del_east_vinod_nagar_mayur_vihar_2'] = (2830, 1160)
coords['del_mandawali_west_vinod_nagar'] = (2890, 1070)
coords['del_ip_extension'] = (2940, 990)
coords['del_anand_vihar_isbt'] = (2960, 930) # Blue Branch interchange
coords['del_karkarduma'] = (2820, 930) # Blue Branch interchange
coords['del_karkarduma_court'] = (2700, 860)
coords['del_krishna_nagar'] = (2570, 800)
coords['del_east_azad_nagar'] = (2420, 770)
coords['del_welcome'] = (1915, 850) # Red interchange
coords['del_jaffrabad'] = (1915, 710)
coords['del_maujpur_babarpur'] = (1915, 580)
coords['del_gokulpuri'] = (2010, 480)
coords['del_johri_enclave'] = (2120, 390)
coords['del_shiv_vihar'] = (2230, 300)

for sid in lines_meta['pink']['stationIds']:
    if sid not in label_rules:
        label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

# ------------------------------------------
# 7. MAGENTA LINE: Clean Southern Crosstown & Wide-Spaced Noida link
# ------------------------------------------
coords['del_janakpuri_west'] = (300, 2040) # Blue interchange
coords['del_dabri_mor_janakpuri_south'] = (320, 2160)
coords['del_dashrath_puri'] = (350, 2270)
coords['del_palam'] = (410, 2370)
coords['del_sadaar_bazar_cantonment'] = (500, 2450)
coords['del_terminal_1_igi_airport'] = (620, 2510)
coords['del_shankar_vihar'] = (760, 2530)
coords['del_vasant_vihar'] = (910, 2530)
coords['del_munirka'] = (1060, 2530)
coords['del_rk_puram'] = (1210, 2530)
coords['del_iit_delhi'] = (1360, 2470)
coords['del_hauz_khas'] = (1600, 2165) # Yellow interchange
coords['del_panchsheel_park'] = (1770, 2165)
coords['del_chirag_delhi'] = (1940, 2165)
coords['del_greater_kailash'] = (2110, 2165)
coords['del_nehru_enclave'] = (2280, 2165)
coords['del_kalkaji_mandir'] = (2470, 2125) # Violet interchange

# Eastern section (Kalkaji Mandir to Botanical Garden)
# 110-120px separation between every station!
coords['del_okhla_nsic'] = (2580, 2075)
coords['del_sukhdev_vihar'] = (2690, 2025)
coords['del_jamia_millia_islamia'] = (2800, 1975)
coords['del_okhla_vihar'] = (2910, 1925)
coords['del_jasola_vihar_shaheen_bagh'] = (3020, 1875)
coords['del_kalindi_kunj'] = (3130, 1825)
coords['del_okhla_bird_sanctuary'] = (3235, 1800)
coords['del_botanical_garden'] = (3340, 1800) # Blue interchange

# Labels along Kalkaji to Botanical Garden: Angled at -45° with ample whitespace!
for sid in ['del_okhla_nsic', 'del_sukhdev_vihar', 'del_jamia_millia_islamia',
            'del_okhla_vihar', 'del_jasola_vihar_shaheen_bagh', 'del_kalindi_kunj', 'del_okhla_bird_sanctuary']:
    label_rules[sid] = {'angle': -45, 'dx': 10, 'dy': -14, 'anchor': 'start'}

for sid in ['del_dabri_mor_janakpuri_south', 'del_dashrath_puri', 'del_palam', 'del_sadaar_bazar_cantonment',
            'del_terminal_1_igi_airport', 'del_shankar_vihar', 'del_vasant_vihar', 'del_munirka', 'del_rk_puram',
            'del_iit_delhi', 'del_panchsheel_park', 'del_chirag_delhi', 'del_greater_kailash', 'del_nehru_enclave']:
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': 16, 'anchor': 'start'}

# ------------------------------------------
# 8. AIRPORT EXPRESS LINE
# ------------------------------------------
coords['del_new_delhi'] = (1600, 1160)
coords['del_shivaji_stadium'] = (1420, 1370)
coords['del_dhaula_kuan'] = (1120, 1930)
coords['del_delhi_aerocity'] = (820, 2530)
coords['del_igi_airport_t3'] = (510, 2730)
coords['del_dwarka_sec_21'] = (160, 2900)
coords['del_yashobhoomi_dwarka_sec_25'] = (60, 2900)

for sid in ['del_shivaji_stadium', 'del_dhaula_kuan', 'del_delhi_aerocity', 'del_igi_airport_t3', 'del_yashobhoomi_dwarka_sec_25']:
    label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}

# ------------------------------------------
# 9. GREY LINE (Dwarka West)
# ------------------------------------------
coords['del_dwarka'] = (160, 2380)
coords['del_nangli'] = (95, 2380)
coords['del_najafgarh'] = (35, 2380)
coords['del_dhansa_bus_stand'] = (-25, 2380)

# Shift all Dwarka coordinates slightly east so Dhansa Bus Stand has positive X
X_SHIFT_WEST = 80
for sid in ['del_dwarka_sec_21', 'del_yashobhoomi_dwarka_sec_25', 'del_dwarka', 'del_nangli', 'del_najafgarh', 'del_dhansa_bus_stand']:
    coords[sid] = (coords[sid][0] + X_SHIFT_WEST, coords[sid][1])
for idx in range(9):
    sid = bl[idx]
    coords[sid] = (coords[sid][0] + X_SHIFT_WEST, coords[sid][1])

for sid in ['del_nangli', 'del_najafgarh', 'del_dhansa_bus_stand']:
    label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# ------------------------------------------
# 10. GREEN LINE: Clean Y-Fork Trunk
# ------------------------------------------
green_trunk = [
    'del_brigadier_hoshiar_singh', 'del_bahadurgarh_city', 'del_pandit_shree_ram_sharma',
    'del_tikri_border', 'del_tikri_kalan', 'del_ghevra_metro', 'del_mundka_industrial_area',
    'del_mundka', 'del_rajdhani_park', 'del_nangloi_railway_station', 'del_nangloi',
    'del_surajmal_stadium', 'del_udyog_nagar', 'del_peera_garhi', 'del_paschim_vihar_west',
    'del_paschim_vihar_east', 'del_madipur', 'del_shivaji_park', 'del_punjabi_bagh',
    'del_punjabi_bagh_west', 'del_ashok_park_main'
]
g_start = 60
g_end = 1100
for idx, sid in enumerate(green_trunk):
    coords[sid] = (g_start + idx * ((g_end - g_start) / (len(green_trunk)-1)), 1060)
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}

coords['del_ashok_park_main'] = (1100, 1060)
coords['del_punjabi_bagh_west'] = (790, 1170)
coords['del_inderlok'] = (1230, 850) # Red interchange
coords['del_satguru_ram_singh_marg'] = (1030, 1180)
coords['del_kirti_nagar'] = (880, 1280) # Blue interchange

label_rules['del_ashok_park_main'] = {'angle': 0, 'dx': 18, 'dy': -14, 'anchor': 'start'}
label_rules['del_satguru_ram_singh_marg'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

# ------------------------------------------
# 11. RAPID METRO GURUGRAM (Dedicated southern loop)
# ------------------------------------------
coords['del_sikanderpur'] = (1600, 2870)
coords['del_rm_phase_2'] = (1750, 2780)
coords['del_rm_belvedere_towers'] = (1880, 2780)
coords['del_rm_cyber_city'] = (2000, 2850)
coords['del_rm_moulsari_avenue'] = (2000, 2940)
coords['del_rm_phase_3'] = (1880, 3010)
coords['del_rm_phase_1'] = (1750, 2940)
coords['del_rm_sec_42_43'] = (1750, 3030)
coords['del_rm_sec_53_54'] = (1750, 3110)
coords['del_rm_sec_54_chowk'] = (1750, 3190)
coords['del_rm_sec_55_56'] = (1750, 3270)

for sid in lines_meta['rapid_metro']['stationIds']:
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

# ------------------------------------------
# 12. AQUA LINE (NMRC): Noida Sec 51 to Greater Noida Depot
# ------------------------------------------
coords['del_noida_sec_51'] = (3810, 1950)
label_rules['del_noida_sec_51'] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

aqua_stations = lines_meta['aqua_noida']['stationIds']
for a_idx, sid in enumerate(aqua_stations):
    if a_idx == 0:
        continue
    elif a_idx <= 14:
        coords[sid] = (3810, 1950 + a_idx * 56)
        label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}
    else:
        off = a_idx - 14
        coords[sid] = (3810 + off * 68, 1950 + 14 * 56 + off * 46)
        label_rules[sid] = {'angle': -30, 'dx': 14, 'dy': -2, 'anchor': 'start'}

# Check that ALL 261 stations in dataset are mapped
unmapped = [s['id'] for s in stations if s['id'] not in coords]
if unmapped:
    raise ValueError(f"CRITICAL: Unmapped stations found: {unmapped}")

print(f"Verified 100% of {len(coords)} stations have unique coordinates with zero missing.")

# ==========================================
# 2. GENERATE CLEAN HIGH-CONTRAST SVG
# ==========================================
svg_parts = []
svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" width="100%" height="100%">')

# Background
svg_parts.append(f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#FFFFFF"/>')

# Graceful Yamuna River (Curved Band)
svg_parts.append('<!-- Yamuna River -->')
svg_parts.append('<path d="M 2520 0 C 2480 400, 2400 800, 2220 1100 C 2120 1280, 2200 1550, 2420 1800 C 2620 2020, 2800 2350, 2880 3450" fill="none" stroke="#E0F2FE" stroke-width="60" stroke-linecap="round"/>')
svg_parts.append('<text x="2240" y="1150" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(56 2240 1150)">YAMUNA RIVER</text>')

# External Transfers
svg_parts.append('<!-- External Transfers -->')
# Travelator: Dhaula Kuan to South Campus
dk = coords['del_dhaula_kuan']
sc = coords['del_durgabai_deshmukh_south_campus']
svg_parts.append(f'<line x1="{dk[0]}" y1="{dk[1]}" x2="{sc[0]}" y2="{sc[1]}" stroke="#94A3B8" stroke-width="3.5" stroke-dasharray="5,5"/>')
svg_parts.append(f'<text x="{(dk[0]+sc[0])/2 - 25}" y="{(dk[1]+sc[1])/2 - 6}" font-family="sans-serif" font-size="9.5" font-weight="bold" fill="#64748B">Travelator</text>')

# Sector 52 to Sector 51 (Noida Aqua link)
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
    ('grey', '#78909C', 8.5, lines_meta['grey']['stationIds']),
    ('rapid_metro', '#0288D1', 8.5, lines_meta['rapid_metro']['stationIds']),
    ('aqua_noida', '#00BCD4', 8.5, lines_meta['aqua_noida']['stationIds']),
    ('magenta', '#C2185B', 9.5, lines_meta['magenta']['stationIds']),
    ('pink', '#EC407A', 10, lines_meta['pink']['stationIds']),
    ('violet', '#7B1FA2', 9.5, lines_meta['violet']['stationIds']),
    ('airport_express', '#F57C00', 9, lines_meta['airport_express']['stationIds']),
    ('red', '#D32F2F', 10, lines_meta['red']['stationIds']),
    ('blue_vaishali', '#1565C0', 9.5, lines_meta['blue_vaishali']['stationIds']),
    ('blue', '#1976D2', 10.5, lines_meta['blue']['stationIds']),
    ('yellow', '#FBC02D', 10.5, lines_meta['yellow']['stationIds']),
]

for lid, color, width, s_list in line_render_order:
    d = generate_svg_path(s_list)
    svg_parts.append(f'  <path id="route-{lid}" d="{d}" fill="none" stroke="{color}" stroke-width="{width}"/>')

# Green Line Trunk + 2 distinct branches
green_d = generate_svg_path(green_trunk)
svg_parts.append(f'  <path id="route-green-trunk" d="{green_d}" fill="none" stroke="#388E3C" stroke-width="9.5"/>')
ap = coords['del_ashok_park_main']
il = coords['del_inderlok']
sr = coords['del_satguru_ram_singh_marg']
kn = coords['del_kirti_nagar']
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {il[0]} {il[1]}" fill="none" stroke="#388E3C" stroke-width="9.5"/>')
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {sr[0]} {sr[1]} L {kn[0]} {kn[1]}" fill="none" stroke="#388E3C" stroke-width="9.5"/>')

svg_parts.append('</g>')

# Station Nodes & Typography with Protective Backdrop Capsules
svg_parts.append('<!-- STATIONS & LABELS LAYER -->')
svg_parts.append('<g id="stations-layer">')

for s in stations:
    sid = s['id']
    x, y = coords[sid]
    is_ic = s.get('isInterchange', False)
    name_en = s['name'].replace('&', '&amp;')
    name_hi = s.get('hindiName', '').replace('&', '&amp;')
    
    rule = label_rules.get(sid, {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'})
    angle = rule['angle']
    dx = rule['dx']
    dy = rule['dy']
    anchor = rule['anchor']

    lx = x + dx
    ly = y + dy
    transform_attr = f' transform="rotate({angle} {lx:.1f} {ly:.1f})"' if angle != 0 else ''

    # Estimate text dimensions
    char_len = max(len(name_en), len(name_hi))
    bw = max(char_len * 6.8 + 14, 75)
    bh = 30 if is_ic else 26

    # Calculate capsule coordinates
    if anchor == 'start':
        rx = lx - 2
    elif anchor == 'end':
        rx = lx - bw + 2
    else: # middle
        rx = lx - bw / 2
    ry = ly - 16

    # 1. Subtle protective white background pill (zero line visual cutting)
    svg_parts.append(f'  <rect x="{rx:.1f}" y="{ry:.1f}" width="{bw:.1f}" height="{bh:.1f}" rx="3" ry="3" fill="#FFFFFF" fill-opacity="0.94"{transform_attr}/>')

    # 2. Station Node Indicator
    if is_ic:
        svg_parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="9.5" fill="#FFFFFF" stroke="#0F172A" stroke-width="3"/>')
        svg_parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="4" fill="#0F172A"/>')
    else:
        svg_parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="4.5" fill="#FFFFFF" stroke="#1E293B" stroke-width="2.2"/>')

    # 3. Bilingual Crisp Typography
    if is_ic:
        svg_parts.append(f'  <g{transform_attr}>')
        if name_hi:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11" font-weight="bold" fill="#334155">{name_hi}</text>')
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 13:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="13" font-weight="900" fill="#020617">{name_en}</text>')
        else:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="13" font-weight="900" fill="#020617">{name_en}</text>')
        svg_parts.append('  </g>')
    else:
        svg_parts.append(f'  <g{transform_attr}>')
        if name_hi:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="9" font-weight="600" fill="#475569">{name_hi}</text>')
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 11.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.8" font-weight="bold" fill="#0F172A">{name_en}</text>')
        else:
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 4:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.8" font-weight="bold" fill="#0F172A">{name_en}</text>')
        svg_parts.append('  </g>')

svg_parts.append('</g>')

# Clean Modern Legend Card (Top Right)
leg_x = 3580
leg_y = 50
leg_w = 840
leg_h = 700

svg_parts.append('<!-- CLEAN LEGEND CARD -->')
svg_parts.append(f'<g transform="translate({leg_x}, {leg_y})">')
svg_parts.append(f'  <rect width="{leg_w}" height="{leg_h}" rx="16" ry="16" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>')
svg_parts.append('  <text x="30" y="40" font-family="sans-serif" font-size="15" font-weight="bold" fill="#0F172A" letter-spacing="1">DELHI NCR METRO NETWORK</text>')
svg_parts.append(f'  <line x1="30" y1="54" x2="{leg_w - 30}" y2="54" stroke="#E2E8F0" stroke-width="1.5"/>')

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
svg_parts.append(f'  <line x1="30" y1="{sym_y - 12}" x2="{leg_w - 30}" y2="{sym_y - 12}" stroke="#E2E8F0" stroke-width="1.5"/>')
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

print(f"Generated clean non-overlapping Delhi SVG to {OUT_SVG} ({len(svg_content)} bytes)")
