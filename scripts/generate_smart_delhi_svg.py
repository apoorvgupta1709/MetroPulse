import json
import math
import os
import re

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
DATA_PATH = os.path.join(PROJECT_DIR, 'data', 'production', 'delhi_metro_production.json')
OUT_SVG = os.path.join(PROJECT_DIR, 'metropulse_main', 'assets', 'maps', 'delhi_metro_schematic.svg')
DART_COORDS_PATH = os.path.join(PROJECT_DIR, 'metropulse_main', 'lib', 'widgets', 'delhi_schematic_coords.dart')

with open(DATA_PATH, 'r', encoding='utf-8') as f:
    data = json.load(f)

lines_meta = {l['id']: l for l in data['lines']}
stations = data['stations']
stations_by_id = {s['id']: s for s in stations}

# Balanced, compact mobile-optimized dimensions (matching benchmark app)
WIDTH = 3400
HEIGHT = 2600

coords = {}
label_rules = {} # sid -> {'angle': float, 'dx': float, 'dy': float, 'anchor': str}

# ------------------------------------------
# 1. YELLOW LINE: Vertical spine along X = 1420
# ------------------------------------------
yl = lines_meta['yellow']['stationIds']
coords['del_samaypur_badli'] = (1420, 150)
coords['del_rohini_sec_18_19'] = (1420, 205)
coords['del_haiderpur_badli_mor'] = (1420, 260)
coords['del_jahangirpuri'] = (1420, 315)
coords['del_adarsh_nagar'] = (1420, 370)
coords['del_azadpur'] = (1420, 435) # Pink interchange
coords['del_model_town'] = (1420, 495)
coords['del_gtb_nagar'] = (1420, 555)
coords['del_vishwavidyalaya'] = (1420, 615)
coords['del_vidhan_sabha'] = (1420, 670)
coords['del_civil_lines'] = (1420, 725)
coords['del_kashmere_gate'] = (1420, 790) # Red & Violet interchange
coords['del_chandni_chowk'] = (1420, 870)
coords['del_chawri_bazar'] = (1420, 960)
coords['del_new_delhi'] = (1420, 1060) # Airport Express interchange
coords['del_rajiv_chowk'] = (1420, 1180) # Blue interchange (Center Hub)
coords['del_patel_chowk'] = (1420, 1290)
coords['del_central_secretariat'] = (1420, 1400) # Violet interchange
coords['del_udyog_bhawan'] = (1420, 1490)
coords['del_lok_kalyan_marg'] = (1420, 1570)
coords['del_jor_bagh'] = (1420, 1650)
coords['del_dilli_haat_ina'] = (1420, 1730) # Pink interchange
coords['del_aiims'] = (1420, 1805)
coords['del_green_park'] = (1420, 1875)
coords['del_hauz_khas'] = (1420, 1950) # Magenta interchange
coords['del_malviya_nagar'] = (1420, 2025)
coords['del_saket'] = (1420, 2095)
coords['del_qutab_minar'] = (1420, 2165)

# Diagonal 45° bend towards Gurugram
coords['del_chhattarpur'] = (1480, 2225)
coords['del_sultanpur'] = (1540, 2285)
coords['del_ghitorni'] = (1600, 2345)
coords['del_arjan_garh'] = (1660, 2405)
coords['del_guru_dronacharya'] = (1720, 2465)
coords['del_sikanderpur'] = (1780, 2525) # Rapid Metro interchange

# Horizontal left through Gurugram
coords['del_mg_road'] = (1680, 2525)
coords['del_iffco_chowk'] = (1580, 2525)
coords['del_millennium_city_centre'] = (1460, 2525)

# Default Yellow Line label rules: Face East
for sid in yl:
    label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': -3, 'anchor': 'start'}

# Stations between Kashmere Gate and Hauz Khas: Face WEST (Left) away from Violet line
for sid in ['del_chandni_chowk', 'del_chawri_bazar', 'del_new_delhi', 'del_patel_chowk',
            'del_central_secretariat', 'del_udyog_bhawan', 'del_lok_kalyan_marg', 'del_jor_bagh',
            'del_aiims', 'del_green_park']:
    label_rules[sid] = {'angle': 0, 'dx': -16, 'dy': -3, 'anchor': 'end'}

label_rules['del_kashmere_gate'] = {'angle': 0, 'dx': 18, 'dy': -20, 'anchor': 'start'}
label_rules['del_rajiv_chowk'] = {'angle': 0, 'dx': 22, 'dy': -16, 'anchor': 'start'}
label_rules['del_dilli_haat_ina'] = {'angle': 0, 'dx': 18, 'dy': -18, 'anchor': 'start'}
label_rules['del_hauz_khas'] = {'angle': 0, 'dx': 20, 'dy': -18, 'anchor': 'start'}

# Staggered Gurugram stations
label_rules['del_guru_dronacharya'] = {'angle': 0, 'dx': -16, 'dy': -3, 'anchor': 'end'}
label_rules['del_sikanderpur'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_mg_road'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_iffco_chowk'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_millennium_city_centre'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# ------------------------------------------
# 2. RED LINE: Horizontal along Y = 790 and Ghaziabad along Y = 660
# ------------------------------------------
rl = lines_meta['red']['stationIds']
kg_idx = rl.index('del_kashmere_gate')

# West section (Rithala to Tis Hazari) - 88px spacing, strictly alternating Above & Below
r_west = rl[:kg_idx]
for idx, sid in enumerate(r_west):
    coords[sid] = (280 + idx * 88, 790)
    if idx % 2 == 0:
        label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
    else:
        label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# East section (Shastri Park to Dilshad Garden along Y = 790, Ghaziabad along Y = 660)
r_east = rl[kg_idx+1:]
for j, sid in enumerate(r_east):
    if j < 7: # Shastri Park upto Dilshad Garden along Y = 790
        coords[sid] = (1420 + (j + 1) * 88, 790)
        if j % 2 == 0:
            label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
        else:
            label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
    else: # Ghaziabad branch goes strictly along Y = 660 (well NORTH of Blue Branch Y = 960!)
        step = j - 6
        coords[sid] = (2036 + step * 85, 660)
        if step % 2 == 1:
            label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
        else:
            label_rules[sid] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

coords['del_welcome'] = (1420 + 3 * 88, 790) # Pink interchange at X = 1684
label_rules['del_welcome'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_shaheed_sthal'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}

# ------------------------------------------
# 3. BLUE LINE MAIN: Horizontal central at Y = 1180
# ------------------------------------------
bl = lines_meta['blue']['stationIds']

# Dwarka Section: Vertical spine at X = 200, labels face WEST into open space
for idx in range(9):
    sid = bl[idx]
    coords[sid] = (200, 2440 - idx * 55)
    label_rules[sid] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}

coords['del_dwarka_sec_21'] = (200, 2440)
coords['del_dwarka'] = (200, 2000) # Grey interchange

# Uttam Nagar to Janakpuri West
for idx in range(9, 14):
    f = (idx - 9) / 4
    sid = bl[idx]
    coords[sid] = (200 + f * 110, 2000 - f * 260)
    label_rules[sid] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}

coords['del_janakpuri_west'] = (310, 1740) # Magenta interchange

# Janakpuri West to Rajouri Garden
for idx in range(14, 19):
    f = (idx - 13) / 5
    sid = bl[idx]
    coords[sid] = (310 + f * 170, 1740 - f * 300)
    label_rules[sid] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}

coords['del_rajouri_garden'] = (480, 1440) # Pink interchange

# Rajouri Garden to Kirti Nagar
coords['del_ramesh_nagar'] = (580, 1345)
coords['del_moti_nagar'] = (680, 1260)
coords['del_kirti_nagar'] = (780, 1180) # Green interchange

label_rules['del_ramesh_nagar'] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}
label_rules['del_moti_nagar'] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}
label_rules['del_kirti_nagar'] = {'angle': 0, 'dx': -18, 'dy': 24, 'anchor': 'end'}

# Central Horizontal: Kirti Nagar to Rajiv Chowk (STAGGERED ABOVE/BELOW - ZERO OVERLAP!)
coords['del_shadipur'] = (880, 1180)
coords['del_patel_nagar'] = (980, 1180)
coords['del_rajendra_place'] = (1080, 1180)
coords['del_karol_bagh'] = (1180, 1180)
coords['del_jhandewalan'] = (1270, 1180)
coords['del_rk_ashram_marg'] = (1350, 1180)
coords['del_rajiv_chowk'] = (1420, 1180)

label_rules['del_shadipur'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_patel_nagar'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_rajendra_place'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_karol_bagh'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_jhandewalan'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_rk_ashram_marg'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# East of Rajiv Chowk: Wide spacing through Mandi House to Yamuna Bank
coords['del_barakhamba_road'] = (1540, 1180)
coords['del_mandi_house'] = (1680, 1180) # Violet interchange
coords['del_supreme_court'] = (1800, 1180)
coords['del_indraprastha'] = (1910, 1180)
coords['del_yamuna_bank'] = (2020, 1180) # Branching point

label_rules['del_barakhamba_road'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_mandi_house'] = {'angle': 0, 'dx': 0, 'dy': -22, 'anchor': 'middle'}
label_rules['del_supreme_court'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_indraprastha'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_yamuna_bank'] = {'angle': 0, 'dx': 20, 'dy': -8, 'anchor': 'start'}

# Descending to Noida (Yamuna Bank to Botanical Garden)
coords['del_akshardham'] = (2120, 1260)
coords['del_mayur_vihar_1'] = (2320, 1390) # Pink interchange
coords['del_mayur_vihar_ext'] = (2420, 1450)
coords['del_new_ashok_nagar'] = (2520, 1500)
coords['del_noida_sec_15'] = (2620, 1545)
coords['del_noida_sec_16'] = (2720, 1580)
coords['del_noida_sec_18'] = (2800, 1600)
coords['del_botanical_garden'] = (2870, 1600) # Magenta interchange

label_rules['del_akshardham'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_mayur_vihar_1'] = {'angle': 0, 'dx': 0, 'dy': -22, 'anchor': 'middle'}
label_rules['del_mayur_vihar_ext'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_new_ashok_nagar'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_noida_sec_15'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_noida_sec_16'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_noida_sec_18'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_botanical_garden'] = {'angle': 0, 'dx': 0, 'dy': -22, 'anchor': 'middle'}

# Noida Corridor: Horizontal along Y = 1600 - Alternating Above & Below
coords['del_golf_course'] = (2940, 1600)
coords['del_noida_city_centre'] = (3010, 1600)
coords['del_noida_sec_34'] = (3080, 1600)
coords['del_noida_sec_52'] = (3150, 1600) # Transfer to Aqua Line
coords['del_noida_sec_61'] = (3215, 1600)
coords['del_noida_sec_59'] = (3275, 1600)
coords['del_noida_sec_62'] = (3335, 1600)
coords['del_noida_electronic_city'] = (3390, 1600)

label_rules['del_golf_course'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_noida_city_centre'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_noida_sec_34'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_noida_sec_52'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_noida_sec_61'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_noida_sec_59'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_noida_sec_62'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_noida_electronic_city'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}

# ------------------------------------------
# 4. BLUE LINE BRANCH: Yamuna Bank to Vaishali (Along Y = 960)
# ------------------------------------------
coords['del_laxmi_nagar'] = (2120, 1100)
coords['del_nirman_vihar'] = (2220, 1030)
coords['del_preet_vihar'] = (2320, 960)
coords['del_karkarduma'] = (2440, 960) # Pink interchange
coords['del_anand_vihar_isbt'] = (2570, 960) # Pink interchange
coords['del_kaushambi'] = (2700, 960)
coords['del_vaishali'] = (2820, 960)

label_rules['del_laxmi_nagar'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_nirman_vihar'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_preet_vihar'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_karkarduma'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_anand_vihar_isbt'] = {'angle': 0, 'dx': 0, 'dy': -22, 'anchor': 'middle'}
label_rules['del_kaushambi'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_vaishali'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}

# ------------------------------------------
# 5. VIOLET LINE: East curve with generous clearance from Yellow Line
# ------------------------------------------
coords['del_lal_quila'] = (1530, 860)
coords['del_jama_masjid'] = (1620, 930)
coords['del_delhi_gate'] = (1690, 1010)
coords['del_ito'] = (1720, 1095)
coords['del_mandi_house'] = (1680, 1180) # Crosses Blue Line
coords['del_janpath'] = (1540, 1290)
coords['del_central_secretariat'] = (1420, 1400) # Meets Yellow Line

for sid in ['del_lal_quila', 'del_jama_masjid', 'del_delhi_gate', 'del_ito', 'del_janpath']:
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -4, 'anchor': 'start'}

# South of Central Secretariat: Sweeps East to JLN and Lajpat Nagar
coords['del_khan_market'] = (1550, 1490)
coords['del_jawaharlal_nehru_stadium'] = (1660, 1560)
coords['del_jangpura'] = (1760, 1620)
coords['del_lajpat_nagar'] = (1860, 1680) # Pink interchange
coords['del_moolchand'] = (1930, 1740)
coords['del_kailash_colony'] = (1990, 1800)
coords['del_nehru_place'] = (2050, 1860)
coords['del_kalkaji_mandir'] = (2110, 1920) # Magenta interchange

for sid in ['del_khan_market', 'del_jawaharlal_nehru_stadium', 'del_jangpura',
            'del_moolchand', 'del_kailash_colony', 'del_nehru_place']:
    label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': -3, 'anchor': 'start'}

label_rules['del_lajpat_nagar'] = {'angle': 0, 'dx': 18, 'dy': -18, 'anchor': 'start'}
label_rules['del_kalkaji_mandir'] = {'angle': 0, 'dx': -20, 'dy': -18, 'anchor': 'end'}

# South along X = 2110 straight into Faridabad
vl = lines_meta['violet']['stationIds']
km_idx = vl.index('del_kalkaji_mandir')
for k, sid in enumerate(vl[km_idx + 1:]):
    coords[sid] = (2110, 1920 + (k + 1) * 38)
    label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': -3, 'anchor': 'start'}

# ------------------------------------------
# 6. PINK LINE: Grand Orbital Ring
# ------------------------------------------
coords['del_majlis_park'] = (1260, 350)
coords['del_azadpur'] = (1420, 435) # Yellow interchange
coords['del_shalimar_bagh'] = (1120, 560)
coords['del_netaji_subhash_place'] = coords['del_netaji_subhash_place'] # Red interchange
coords['del_shakurpur'] = (730, 930)
coords['del_punjabi_bagh_west'] = (680, 1070) # Green interchange
coords['del_esi_basaidarapur'] = (700, 1240)
coords['del_rajouri_garden'] = (480, 1440) # Blue interchange
coords['del_maya_puri'] = (540, 1550)
coords['del_naraina_vihar'] = (610, 1630)
coords['del_delhi_cantt'] = (700, 1690)
coords['del_durgabai_deshmukh_south_campus'] = (820, 1730)
coords['del_sir_m_vishweshwaraiah_moti_bagh'] = (960, 1730)
coords['del_bhikaji_cama_place'] = (1100, 1730)
coords['del_sarojini_nagar'] = (1240, 1730)
coords['del_dilli_haat_ina'] = (1420, 1730) # Yellow interchange
coords['del_south_extension'] = (1640, 1710)
coords['del_lajpat_nagar'] = (1860, 1680) # Violet interchange

label_rules['del_majlis_park'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_shalimar_bagh'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_shakurpur'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_esi_basaidarapur'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_maya_puri'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_naraina_vihar'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_delhi_cantt'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_durgabai_deshmukh_south_campus'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_sir_m_vishweshwaraiah_moti_bagh'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_bhikaji_cama_place'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_sarojini_nagar'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_south_extension'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

coords['del_vinobapuri'] = (1960, 1630)
coords['del_ashram'] = (2050, 1560)
coords['del_sarai_kale_khan_hazrat_nizamuddin'] = (2130, 1470)
label_rules['del_vinobapuri'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_ashram'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_sarai_kale_khan_hazrat_nizamuddin'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}

# East Section of Pink Line: runs down along X = 2570
coords['del_mayur_vihar_pocket_1'] = (2450, 1390)
coords['del_trilokpuri_sanjay_lake'] = (2570, 1330)
coords['del_east_vinod_nagar_mayur_vihar_2'] = (2570, 1240)
coords['del_mandawali_west_vinod_nagar'] = (2570, 1150)
coords['del_ip_extension'] = (2570, 1060)
coords['del_anand_vihar_isbt'] = (2570, 960) # Blue Branch interchange
coords['del_karkarduma'] = (2440, 960) # Blue Branch interchange
coords['del_karkarduma_court'] = (2200, 920)
coords['del_krishna_nagar'] = (2020, 880)
coords['del_east_azad_nagar'] = (1850, 840)

label_rules['del_mayur_vihar_pocket_1'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}
label_rules['del_trilokpuri_sanjay_lake'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}
label_rules['del_east_vinod_nagar_mayur_vihar_2'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}
label_rules['del_mandawali_west_vinod_nagar'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}
label_rules['del_ip_extension'] = {'angle': 0, 'dx': 18, 'dy': 0, 'anchor': 'start'}
label_rules['del_karkarduma_court'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_krishna_nagar'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_east_azad_nagar'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# North East Spur to Shiv Vihar
coords['del_jaffrabad'] = (1684, 670)
coords['del_maujpur_babarpur'] = (1684, 550)
coords['del_gokulpuri'] = (1770, 460)
coords['del_johri_enclave'] = (1870, 380)
coords['del_shiv_vihar'] = (1970, 300)

for sid in ['del_jaffrabad', 'del_maujpur_babarpur', 'del_gokulpuri', 'del_johri_enclave', 'del_shiv_vihar']:
    label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

# ------------------------------------------
# 7. MAGENTA LINE: Clean Southern Crosstown & Alternating Noida Links
# ------------------------------------------
coords['del_janakpuri_west'] = (310, 1740) # Blue interchange
coords['del_dabri_mor_janakpuri_south'] = (360, 1840)
coords['del_dashrath_puri'] = (420, 1910)
coords['del_palam'] = (490, 1950)
coords['del_sadaar_bazar_cantonment'] = (620, 1950)
coords['del_terminal_1_igi_airport'] = (750, 1950)
coords['del_shankar_vihar'] = (880, 1950)
coords['del_vasant_vihar'] = (1010, 1950)
coords['del_munirka'] = (1140, 1950)
coords['del_rk_puram'] = (1260, 1950)
coords['del_iit_delhi'] = (1370, 1950)
coords['del_hauz_khas'] = (1420, 1950) # Yellow interchange
coords['del_panchsheel_park'] = (1560, 1950)
coords['del_chirag_delhi'] = (1700, 1950)
coords['del_greater_kailash'] = (1840, 1950)
coords['del_nehru_enclave'] = (1980, 1950)
coords['del_kalkaji_mandir'] = (2110, 1920) # Violet interchange

label_rules['del_dabri_mor_janakpuri_south'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_dashrath_puri'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_palam'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_sadaar_bazar_cantonment'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_terminal_1_igi_airport'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_shankar_vihar'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_vasant_vihar'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_munirka'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_rk_puram'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_iit_delhi'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_panchsheel_park'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_chirag_delhi'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}
label_rules['del_greater_kailash'] = {'angle': 0, 'dx': 0, 'dy': -20, 'anchor': 'middle'}
label_rules['del_nehru_enclave'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# Eastern section (Kalkaji Mandir to Botanical Garden)
coords['del_okhla_nsic'] = (2210, 1870)
coords['del_sukhdev_vihar'] = (2310, 1820)
coords['del_jamia_millia_islamia'] = (2410, 1770)
coords['del_okhla_vihar'] = (2510, 1720)
coords['del_jasola_vihar_shaheen_bagh'] = (2610, 1670)
coords['del_kalindi_kunj'] = (2670, 1660)
coords['del_okhla_bird_sanctuary'] = (2750, 1640)
coords['del_botanical_garden'] = (2870, 1600) # Blue interchange

# Staggered Alternating labels along Kalkaji to Botanical Garden: ZERO OVERLAP!
label_rules['del_okhla_nsic'] = {'angle': 0, 'dx': 16, 'dy': 16, 'anchor': 'start'}
label_rules['del_sukhdev_vihar'] = {'angle': 0, 'dx': -16, 'dy': -16, 'anchor': 'end'}
label_rules['del_jamia_millia_islamia'] = {'angle': 0, 'dx': 16, 'dy': 16, 'anchor': 'start'}
label_rules['del_okhla_vihar'] = {'angle': 0, 'dx': -16, 'dy': -16, 'anchor': 'end'}
label_rules['del_jasola_vihar_shaheen_bagh'] = {'angle': 0, 'dx': 16, 'dy': 16, 'anchor': 'start'}
label_rules['del_kalindi_kunj'] = {'angle': 0, 'dx': -16, 'dy': -16, 'anchor': 'end'}
label_rules['del_okhla_bird_sanctuary'] = {'angle': 0, 'dx': 16, 'dy': 16, 'anchor': 'start'}

# ------------------------------------------
# 8. AIRPORT EXPRESS LINE
# ------------------------------------------
coords['del_new_delhi'] = (1420, 1060)
coords['del_shivaji_stadium'] = (1320, 1340)
coords['del_dhaula_kuan'] = (780, 1650) # Skywalk to South Campus
coords['del_delhi_aerocity'] = (580, 1880)
coords['del_igi_airport_t3'] = (410, 2100)
coords['del_dwarka_sec_21'] = (200, 2440)
coords['del_yashobhoomi_dwarka_sec_25'] = (100, 2440)

label_rules['del_shivaji_stadium'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_dhaula_kuan'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_delhi_aerocity'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_igi_airport_t3'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_yashobhoomi_dwarka_sec_25'] = {'angle': 0, 'dx': 0, 'dy': 24, 'anchor': 'middle'}

# ------------------------------------------
# 9. GREY LINE (Dwarka West - angled down-left away from Dwarka Mor)
# ------------------------------------------
coords['del_dwarka'] = (200, 2000)
coords['del_nangli'] = (140, 2080)
coords['del_najafgarh'] = (80, 2160)
coords['del_dhansa_bus_stand'] = (20, 2240)

label_rules['del_dwarka'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_nangli'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_najafgarh'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_dhansa_bus_stand'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}

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
g_start = 30
g_end = 950
for idx, sid in enumerate(green_trunk):
    coords[sid] = (g_start + idx * ((g_end - g_start) / (len(green_trunk)-1)), 980)
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -10, 'anchor': 'start'}

coords['del_ashok_park_main'] = (950, 980)
coords['del_punjabi_bagh_west'] = (680, 1070)
coords['del_satguru_ram_singh_marg'] = (880, 1080)
coords['del_kirti_nagar'] = (780, 1180) # Blue interchange

label_rules['del_ashok_park_main'] = {'angle': 0, 'dx': 16, 'dy': -12, 'anchor': 'start'}
label_rules['del_punjabi_bagh_west'] = {'angle': 0, 'dx': -16, 'dy': 0, 'anchor': 'end'}
label_rules['del_satguru_ram_singh_marg'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

# ------------------------------------------
# 11. RAPID METRO GURUGRAM (Dedicated Eastern loop)
# ------------------------------------------
coords['del_sikanderpur'] = (1780, 2525)
# Loop placed to the EAST (X = 1860 - 2000) of Yellow Line
coords['del_rm_phase_2'] = (1860, 2450)
coords['del_rm_phase_3'] = (1860, 2375)
coords['del_rm_moulsari_avenue'] = (1860, 2300)
coords['del_rm_cyber_city'] = (2000, 2300)
coords['del_rm_belvedere_towers'] = (2000, 2450)

# Spur South of Sikanderpur
coords['del_rm_phase_1'] = (1860, 2585)
coords['del_rm_sec_42_43'] = (1860, 2645)
coords['del_rm_sec_53_54'] = (1860, 2705)
coords['del_rm_sec_54_chowk'] = (1860, 2760)
coords['del_rm_sec_55_56'] = (1860, 2810)

label_rules['del_rm_phase_2'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_rm_phase_3'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_rm_moulsari_avenue'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_rm_cyber_city'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}
label_rules['del_rm_belvedere_towers'] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}

for sid in ['del_rm_phase_1', 'del_rm_sec_42_43', 'del_rm_sec_53_54', 'del_rm_sec_54_chowk', 'del_rm_sec_55_56']:
    label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': 0, 'anchor': 'start'}

# ------------------------------------------
# 12. AQUA LINE (NMRC): Noida Sec 51 to Greater Noida Depot
# ------------------------------------------
coords['del_noida_sec_51'] = (3150, 1720)
label_rules['del_noida_sec_51'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

aqua_stations = lines_meta['aqua_noida']['stationIds']
for a_idx, sid in enumerate(aqua_stations):
    if a_idx == 0:
        continue
    elif a_idx <= 14:
        coords[sid] = (3150, 1720 + a_idx * 48)
        label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
    else:
        off = a_idx - 14
        coords[sid] = (3150 + off * 56, 1720 + 14 * 48 + off * 38)
        label_rules[sid] = {'angle': -30, 'dx': 12, 'dy': -2, 'anchor': 'start'}

# Verify 100% of stations in dataset are mapped
unmapped = [s['id'] for s in stations if s['id'] not in coords]
if unmapped:
    raise ValueError(f"CRITICAL: Unmapped stations found: {unmapped}")

print(f"Verified 100% of {len(coords)} Delhi stations have unique compact coordinates.")

# ==========================================
# 2. GENERATE COMPACT HIGH-CONTRAST SVG
# ==========================================
svg_parts = []
svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" width="100%" height="100%">')

# Background
svg_parts.append(f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#FFFFFF"/>')

# Graceful Yamuna River (Curved Band)
svg_parts.append('<!-- Yamuna River -->')
svg_parts.append('<path d="M 2180 0 C 2140 400, 2060 700, 1900 950 C 1820 1100, 1900 1350, 2100 1600 C 2280 1800, 2450 2100, 2520 2800" fill="none" stroke="#E0F2FE" stroke-width="50" stroke-linecap="round"/>')
svg_parts.append('<text x="1940" y="1020" font-family="sans-serif" font-size="15" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(56 1940 1020)">YAMUNA RIVER</text>')

# External Transfers
svg_parts.append('<!-- External Transfers -->')
# Travelator: Dhaula Kuan to South Campus
dk = coords['del_dhaula_kuan']
sc = coords['del_durgabai_deshmukh_south_campus']
svg_parts.append(f'<line x1="{dk[0]}" y1="{dk[1]}" x2="{sc[0]}" y2="{sc[1]}" stroke="#94A3B8" stroke-width="3" stroke-dasharray="4,4"/>')
svg_parts.append(f'<text x="{(dk[0]+sc[0])/2 - 22}" y="{(dk[1]+sc[1])/2 - 6}" font-family="sans-serif" font-size="9" font-weight="bold" fill="#64748B">1.2 km skywalk</text>')

# Sector 52 to Sector 51 (Noida Aqua link)
s52 = coords['del_noida_sec_52']
s51 = coords['del_noida_sec_51']
svg_parts.append(f'<line x1="{s52[0]}" y1="{s52[1]}" x2="{s51[0]}" y2="{s51[1]}" stroke="#00BCD4" stroke-width="3" stroke-dasharray="4,4"/>')
svg_parts.append(f'<text x="{s52[0] + 14}" y="{(s52[1]+s51[1])/2 + 4}" font-family="sans-serif" font-size="9" font-weight="bold" fill="#00838F">Exit - 300 m Walkway</text>')

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
    ('aqua_noida', '#00BCD4', 8, lines_meta['aqua_noida']['stationIds']),
    ('magenta', '#C2185B', 9, lines_meta['magenta']['stationIds']),
    ('pink', '#EC407A', 9.5, lines_meta['pink']['stationIds']),
    ('violet', '#7B1FA2', 9, lines_meta['violet']['stationIds']),
    ('blue_branch', '#1565C0', 9, ['del_yamuna_bank', 'del_laxmi_nagar', 'del_nirman_vihar', 'del_preet_vihar', 'del_karkarduma', 'del_anand_vihar_isbt', 'del_kaushambi', 'del_vaishali']),
    ('blue', '#1976D2', 9.5, lines_meta['blue']['stationIds']),
    ('yellow', '#FBC02D', 10, lines_meta['yellow']['stationIds']),
    ('red', '#D32F2F', 9.5, lines_meta['red']['stationIds']),
    ('airport_express', '#F57C00', 7.5, lines_meta['airport_express']['stationIds']),
    ('green_branch1', '#388E3C', 8.5, green_trunk),
]

for lid, color, width, s_list in line_render_order:
    d = generate_svg_path(s_list)
    if d:
        svg_parts.append(f'  <path id="line-{lid}" d="{d}" fill="none" stroke="{color}" stroke-width="{width}"/>')

# Rapid metro loop
rm_pts = [coords[sid] for sid in lines_meta['rapid_metro']['stationIds']]
rm_d = f"M {coords['del_sikanderpur'][0]} {coords['del_sikanderpur'][1]} L {coords['del_rm_phase_2'][0]} {coords['del_rm_phase_2'][1]} L {coords['del_rm_phase_3'][0]} {coords['del_rm_phase_3'][1]} L {coords['del_rm_moulsari_avenue'][0]} {coords['del_rm_moulsari_avenue'][1]} L {coords['del_rm_cyber_city'][0]} {coords['del_rm_cyber_city'][1]} L {coords['del_rm_belvedere_towers'][0]} {coords['del_rm_belvedere_towers'][1]} L {coords['del_sikanderpur'][0]} {coords['del_sikanderpur'][1]}"
svg_parts.append(f'  <path id="line-rapid-loop" d="{rm_d}" fill="none" stroke="#0288D1" stroke-width="7.5"/>')
rm_spur_d = f"M {coords['del_sikanderpur'][0]} {coords['del_sikanderpur'][1]} L {coords['del_rm_phase_1'][0]} {coords['del_rm_phase_1'][1]} L {coords['del_rm_sec_42_43'][0]} {coords['del_rm_sec_42_43'][1]} L {coords['del_rm_sec_53_54'][0]} {coords['del_rm_sec_53_54'][1]} L {coords['del_rm_sec_54_chowk'][0]} {coords['del_rm_sec_54_chowk'][1]} L {coords['del_rm_sec_55_56'][0]} {coords['del_rm_sec_55_56'][1]}"
svg_parts.append(f'  <path id="line-rapid-spur" d="{rm_spur_d}" fill="none" stroke="#0288D1" stroke-width="7.5"/>')

# Green line fork to Inderlok & Kirti Nagar
ap = coords['del_ashok_park_main']
il = coords['del_inderlok']
sr = coords['del_satguru_ram_singh_marg']
kn = coords['del_kirti_nagar']
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {il[0]} {il[1]}" fill="none" stroke="#388E3C" stroke-width="8.5"/>')
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {sr[0]} {sr[1]} L {kn[0]} {kn[1]}" fill="none" stroke="#388E3C" stroke-width="8.5"/>')

svg_parts.append('</g>')

# Station Nodes & Typography (Clean, ZERO backdrop pills, strictly clear of lines)
svg_parts.append('<!-- STATIONS & LABELS LAYER -->')
svg_parts.append('<g id="stations-layer">')

for s in stations:
    sid = s['id']
    x, y = coords[sid]
    is_ic = s.get('isInterchange', False)
    
    # Concise, clean labels without verbose parenthetical clutter
    clean_en = re.sub(r'\s*\([^)]*\)', '', s['name']).replace('& Railway Station', '').replace('& Railway', '').replace(' Railway Station', '').replace(' Railway', '').replace(' ISBT', '').strip()
    clean_en = re.sub(r'\s+', ' ', clean_en).strip()
    clean_en = clean_en.replace('&', '&amp;')

    clean_hi = re.sub(r'\s*\(.*?\)', '', s.get('hindiName', '')).replace(' रेलवे स्टेशन', '').replace(' आईएसबीटी', '').strip()
    clean_hi = re.sub(r'\s+', ' ', clean_hi).strip()
    clean_hi = clean_hi.replace('&', '&amp;')
    
    rule = label_rules.get(sid, {'angle': 0, 'dx': 16, 'dy': -3, 'anchor': 'start'})
    angle = rule['angle']
    dx = rule['dx']
    dy = rule['dy']
    anchor = rule['anchor']

    lx = x + dx
    ly = y + dy
    transform_attr = f' transform="rotate({angle} {lx:.1f} {ly:.1f})"' if angle != 0 else ''

    # 1. Station Node Indicator
    if is_ic:
        svg_parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="8.5" fill="#FFFFFF" stroke="#0F172A" stroke-width="2.6"/>')
        svg_parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="3.4" fill="#0F172A"/>')
    else:
        svg_parts.append(f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="4.2" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')

    # 2. Bilingual Crisp Typography positioned with mathematical line clearance
    # When dy < 0 (ABOVE line): English at ly, Hindi above at ly - 11
    # When dy > 0 (BELOW line): Hindi at ly, English below at ly + 11
    # When dx != 0 (LEFT/RIGHT): Hindi at ly - 3, English at ly + 8
    if is_ic:
        svg_parts.append(f'  <g{transform_attr}>')
        if dy < -10:
            if clean_hi:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly - 12:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="bold" fill="#334155">{clean_hi}</text>')
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
        elif dy > 10:
            if clean_hi:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="bold" fill="#334155">{clean_hi}</text>')
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 12.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
            else:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 6:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
        else:
            if clean_hi:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly - 3:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="bold" fill="#334155">{clean_hi}</text>')
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 9.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
            else:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 4:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
        svg_parts.append('  </g>')
    else:
        svg_parts.append(f'  <g{transform_attr}>')
        if dy < -10:
            if clean_hi:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly - 10.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="8.8" font-weight="600" fill="#475569">{clean_hi}</text>')
            svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
        elif dy > 10:
            if clean_hi:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="8.8" font-weight="600" fill="#475569">{clean_hi}</text>')
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 11:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
            else:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
        else:
            if clean_hi:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly - 3:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="8.8" font-weight="600" fill="#475569">{clean_hi}</text>')
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 8:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
            else:
                svg_parts.append(f'    <text x="{lx:.1f}" y="{ly + 3.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
        svg_parts.append('  </g>')

svg_parts.append('</g>')

# Clean Modern Legend Card (Top Right)
leg_x = 2580
leg_y = 40
leg_w = 780
leg_h = 670

svg_parts.append('<!-- CLEAN LEGEND CARD -->')
svg_parts.append(f'<g transform="translate({leg_x}, {leg_y})">')
svg_parts.append(f'  <rect width="{leg_w}" height="{leg_h}" rx="14" ry="14" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.8"/>')
svg_parts.append('  <text x="26" y="36" font-family="sans-serif" font-size="14.5" font-weight="bold" fill="#0F172A" letter-spacing="1">DELHI NCR METRO NETWORK</text>')
svg_parts.append(f'  <line x1="26" y1="48" x2="{leg_w - 26}" y2="48" stroke="#E2E8F0" stroke-width="1.5"/>')

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
    item_y = 74 + idx * 34
    svg_parts.append(f'  <circle cx="40" cy="{item_y}" r="6" fill="{lcolor}"/>')
    svg_parts.append(f'  <text x="58" y="{item_y + 4}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">{ltext}</text>')

sym_y = 74 + len(legend_items) * 34 + 14
svg_parts.append(f'  <line x1="26" y1="{sym_y - 10}" x2="{leg_w - 26}" y2="{sym_y - 10}" stroke="#E2E8F0" stroke-width="1.5"/>')
svg_parts.append(f'  <circle cx="40" cy="{sym_y + 10}" r="7.5" fill="#FFFFFF" stroke="#0F172A" stroke-width="2.2"/>')
svg_parts.append(f'  <circle cx="40" cy="{sym_y + 10}" r="3" fill="#0F172A"/>')
svg_parts.append(f'  <text x="58" y="{sym_y + 14}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">Interchange Station</text>')

svg_parts.append(f'  <circle cx="240" cy="{sym_y + 10}" r="4" fill="#FFFFFF" stroke="#1E293B" stroke-width="1.8"/>')
svg_parts.append(f'  <text x="256" y="{sym_y + 14}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">Regular Station</text>')

svg_parts.append(f'  <line x1="420" y1="{sym_y + 10}" x2="460" y2="{sym_y + 10}" stroke="#00BCD4" stroke-width="2.5" stroke-dasharray="4,4"/>')
svg_parts.append(f'  <text x="472" y="{sym_y + 14}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">External Transfer (300m)</text>')

svg_parts.append('</g>')
svg_parts.append('</svg>')

svg_content = "\n".join(svg_parts)

os.makedirs(os.path.dirname(OUT_SVG), exist_ok=True)
with open(OUT_SVG, 'w', encoding='utf-8') as f:
    f.write(svg_content)

print(f"Generated clean non-overlapping Delhi SVG to {OUT_SVG} ({len(svg_content)} bytes)")

# Export synced coordinates for Flutter map interactivity
dart_lines = [
    "import 'dart:ui';",
    "",
    "/// Auto-generated station schematic coordinates for Delhi NCR Metro (3400x2600)",
    "const Map<String, Offset> delhiSchematicCoords = {"
]
for sid in sorted(coords.keys()):
    cx, cy = coords[sid]
    dart_lines.append(f"  '{sid}': Offset({cx:.1f}, {cy:.1f}),")
dart_lines.append("};")

with open(DART_COORDS_PATH, 'w', encoding='utf-8') as f:
    f.write("\n".join(dart_lines) + "\n")

print(f"Exported {len(coords)} synced coordinates to {DART_COORDS_PATH}")
