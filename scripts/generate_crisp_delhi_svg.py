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

# Canvas Dimensions: Balanced 3600 x 2800 coordinate space
# Central Hub (Rajiv Chowk): (1500, 1150)
WIDTH = 3600
HEIGHT = 2800

coords = {}
label_rules = {} # sid -> {'angle': float, 'dx': float, 'dy': float, 'anchor': str}

# 1. Yellow Line: Vertical spine along X = 1500
yl_stations = lines_meta['yellow']['stationIds']
# Distribute from Y = 200 (Samaypur Badli) to Y = 2500 (MCC Gurugram)
y_start = 220
y_end = 2520
yl_step = (y_end - y_start) / (len(yl_stations) - 1)
for i, sid in enumerate(yl_stations):
    coords[sid] = (1500, y_start + i * yl_step)
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}

# Specific anchor hubs on Yellow Line
coords['del_kashmere_gate'] = (1500, 680)
coords['del_chandni_chowk'] = (1500, 820)
coords['del_chawri_bazar'] = (1500, 920)
coords['del_new_delhi'] = (1500, 1020)
coords['del_rajiv_chowk'] = (1500, 1150)
coords['del_patel_chowk'] = (1500, 1260)
coords['del_central_secretariat'] = (1500, 1370)
coords['del_udyog_bhawan'] = (1500, 1460)
coords['del_lok_kalyan_marg'] = (1500, 1550)
coords['del_jor_bagh'] = (1500, 1640)
coords['del_dilli_haat_ina'] = (1500, 1730)
coords['del_aiims'] = (1500, 1810)
coords['del_green_park'] = (1500, 1880)
coords['del_hauz_khas'] = (1500, 1960)
coords['del_malviya_nagar'] = (1500, 2040)
coords['del_saket'] = (1500, 2120)
coords['del_qutab_minar'] = (1500, 2200)
coords['del_chhattarpur'] = (1500, 2280)
coords['del_sultanpur'] = (1500, 2350)
coords['del_ghitorni'] = (1500, 2410)
coords['del_arjan_garh'] = (1500, 2470)
coords['del_guru_dronacharya'] = (1500, 2530)
coords['del_sikanderpur'] = (1500, 2600)
coords['del_mg_road'] = (1500, 2670)
coords['del_iffco_chowk'] = (1420, 2730)
coords['del_millennium_city_centre'] = (1320, 2730)

# Alternate labels for crowded Yellow Line center stations
label_rules['del_new_delhi'] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}
label_rules['del_rajiv_chowk'] = {'angle': 0, 'dx': 22, 'dy': -8, 'anchor': 'start'}
label_rules['del_patel_chowk'] = {'angle': 0, 'dx': -18, 'dy': -3, 'anchor': 'end'}
label_rules['del_central_secretariat'] = {'angle': 0, 'dx': -20, 'dy': -8, 'anchor': 'end'}
label_rules['del_aiims'] = {'angle': 0, 'dx': -18, 'dy': -3, 'anchor': 'end'}
label_rules['del_dilli_haat_ina'] = {'angle': 0, 'dx': 18, 'dy': -3, 'anchor': 'start'}

# 2. Red Line: Horizontal spine along Y = 680
rl_stations = lines_meta['red']['stationIds']
kg_idx = rl_stations.index('del_kashmere_gate')

# West of Kashmere Gate (Rithala to Tis Hazari)
for i in range(kg_idx):
    sid = rl_stations[i]
    x = 420 + (i / kg_idx) * (1500 - 420)
    coords[sid] = (x, 680)
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}

# East of Kashmere Gate (Shastri Park to Dilshad Garden, then Ghaziabad branch)
east_red = rl_stations[kg_idx+1:]
for j, sid in enumerate(east_red):
    if j < 8: # Shastri Park to Dilshad Garden
        x = 1500 + (j + 1) * 90
        coords[sid] = (x, 680)
        label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}
    else: # Ghaziabad extension angled down-right 45°
        step = j - 7
        x = 1500 + 8 * 90 + step * 70
        y = 680 + step * 40
        coords[sid] = (x, y)
        label_rules[sid] = {'angle': -30, 'dx': 14, 'dy': -4, 'anchor': 'start'}

coords['del_netaji_subhash_place'] = (920, 680)
coords['del_inderlok'] = (1150, 680)
coords['del_welcome'] = (1950, 680)
coords['del_kashmere_gate'] = (1500, 680)
label_rules['del_kashmere_gate'] = {'angle': 0, 'dx': 22, 'dy': -16, 'anchor': 'start'}

# 3. Blue Line Main (Dwarka Sec 21 to Noida Electronic City)
bl_stations = lines_meta['blue']['stationIds']

# Dwarka Section: X = 320..650, Y = 2200..1850
for idx in range(9):
    sid = bl_stations[idx]
    coords[sid] = (320 + idx * 45, 2250 - idx * 45)
    label_rules[sid] = {'angle': -45, 'dx': 10, 'dy': -10, 'anchor': 'start'}

# Uttam Nagar to Janakpuri West: Y = 1850..1550
for idx in range(9, 14):
    f = (idx - 9) / 4
    sid = bl_stations[idx]
    coords[sid] = (680 + f * 120, 1850 - f * 250)
    label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}

coords['del_janakpuri_west'] = (800, 1550)
label_rules['del_janakpuri_west'] = {'angle': 0, 'dx': -20, 'dy': -8, 'anchor': 'end'}

# Janakpuri West to Rajouri Garden: X = 800..980, Y = 1550..1330
for idx in range(14, 19):
    f = (idx - 13) / 5
    sid = bl_stations[idx]
    coords[sid] = (800 + f * 180, 1550 - f * 220)
    label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}

coords['del_rajouri_garden'] = (980, 1330)
label_rules['del_rajouri_garden'] = {'angle': 0, 'dx': -20, 'dy': -8, 'anchor': 'end'}

# Rajouri Garden to Kirti Nagar
coords['del_ramesh_nagar'] = (1060, 1270)
coords['del_moti_nagar'] = (1120, 1230)
coords['del_kirti_nagar'] = (1180, 1190)
label_rules['del_ramesh_nagar'] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}
label_rules['del_moti_nagar'] = {'angle': 0, 'dx': -16, 'dy': -2, 'anchor': 'end'}
label_rules['del_kirti_nagar'] = {'angle': 0, 'dx': -18, 'dy': -8, 'anchor': 'end'}

# Kirti Nagar to Rajiv Chowk (approaching horizontal)
coords['del_shadipur'] = (1240, 1165)
coords['del_patel_nagar'] = (1300, 1150)
coords['del_rajendra_place'] = (1360, 1150)
coords['del_karol_bagh'] = (1410, 1150)
coords['del_jhandewalan'] = (1445, 1150)
coords['del_rk_ashram_marg'] = (1475, 1150)

label_rules['del_shadipur'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_patel_nagar'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_rajendra_place'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_karol_bagh'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_jhandewalan'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_rk_ashram_marg'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}

# Central Horizontal Section: Rajiv Chowk to Yamuna Bank
coords['del_rajiv_chowk'] = (1500, 1150)
coords['del_barakhamba_road'] = (1620, 1150)
coords['del_mandi_house'] = (1740, 1150)
coords['del_supreme_court'] = (1850, 1150)
coords['del_indraprastha'] = (1940, 1150)
coords['del_yamuna_bank'] = (2040, 1150)

label_rules['del_barakhamba_road'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_mandi_house'] = {'angle': 0, 'dx': 18, 'dy': -10, 'anchor': 'start'}
label_rules['del_supreme_court'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_indraprastha'] = {'angle': -45, 'dx': 6, 'dy': -12, 'anchor': 'start'}
label_rules['del_yamuna_bank'] = {'angle': 0, 'dx': 18, 'dy': -8, 'anchor': 'start'}

# Yamuna Bank to Botanical Garden (descending 45° across the river)
coords['del_akshardham'] = (2120, 1220)
coords['del_mayur_vihar_1'] = (2200, 1290)
coords['del_mayur_vihar_ext'] = (2280, 1360)
coords['del_new_ashok_nagar'] = (2360, 1430)
coords['del_noida_sec_15'] = (2420, 1480)
coords['del_noida_sec_16'] = (2480, 1520)
coords['del_noida_sec_18'] = (2540, 1550)
coords['del_botanical_garden'] = (2600, 1550)

label_rules['del_akshardham'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_mayur_vihar_1'] = {'angle': 0, 'dx': 18, 'dy': -8, 'anchor': 'start'}
label_rules['del_mayur_vihar_ext'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_new_ashok_nagar'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_noida_sec_15'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_noida_sec_16'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_noida_sec_18'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_botanical_garden'] = {'angle': 0, 'dx': 20, 'dy': -10, 'anchor': 'start'}

# Noida Corridor: Botanical Garden to Noida Electronic City (Horizontal Y = 1550)
coords['del_golf_course'] = (2680, 1550)
coords['del_noida_city_centre'] = (2760, 1550)
coords['del_noida_sec_34'] = (2840, 1550)
coords['del_noida_sec_52'] = (2920, 1550)
coords['del_noida_sec_61'] = (3010, 1550)
coords['del_noida_sec_59'] = (3100, 1550)
coords['del_noida_sec_62'] = (3190, 1550)
coords['del_noida_electronic_city'] = (3300, 1550)

for sid in ['del_golf_course', 'del_noida_city_centre', 'del_noida_sec_34', 'del_noida_sec_52',
            'del_noida_sec_61', 'del_noida_sec_59', 'del_noida_sec_62', 'del_noida_electronic_city']:
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -14, 'anchor': 'start'}
label_rules['del_noida_sec_52'] = {'angle': 0, 'dx': 18, 'dy': -14, 'anchor': 'start'}

# 4. Blue Line Branch (Yamuna Bank to Vaishali)
coords['del_laxmi_nagar'] = (2120, 1070)
coords['del_nirman_vihar'] = (2200, 990)
coords['del_preet_vihar'] = (2280, 910)
coords['del_karkarduma'] = (2380, 850)
coords['del_anand_vihar_isbt'] = (2480, 850)
coords['del_kaushambi'] = (2580, 850)
coords['del_vaishali'] = (2680, 850)

for sid in ['del_laxmi_nagar', 'del_nirman_vihar', 'del_preet_vihar', 'del_kaushambi', 'del_vaishali']:
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -12, 'anchor': 'start'}
label_rules['del_karkarduma'] = {'angle': 0, 'dx': 18, 'dy': -8, 'anchor': 'start'}
label_rules['del_anand_vihar_isbt'] = {'angle': 0, 'dx': 18, 'dy': -8, 'anchor': 'start'}

# 5. Violet Line: Kashmere Gate to Raja Nahar Singh
coords['del_lal_quila'] = (1560, 750)
coords['del_jama_masjid'] = (1610, 810)
coords['del_delhi_gate'] = (1660, 880)
coords['del_ito'] = (1710, 970)
coords['del_mandi_house'] = (1740, 1150)
coords['del_janpath'] = (1620, 1270)
coords['del_central_secretariat'] = (1500, 1370)
coords['del_khan_market'] = (1600, 1460)
coords['del_jawaharlal_nehru_stadium'] = (1680, 1540)
coords['del_jangpura'] = (1760, 1610)
coords['del_lajpat_nagar'] = (1840, 1680)
coords['del_moolchand'] = (1880, 1750)
coords['del_kailash_colony'] = (1920, 1810)
coords['del_nehru_place'] = (1960, 1870)
coords['del_kalkaji_mandir'] = (2000, 1940)

label_rules['del_lal_quila'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_jama_masjid'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_delhi_gate'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_ito'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_janpath'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_khan_market'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_jawaharlal_nehru_stadium'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_jangpura'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_lajpat_nagar'] = {'angle': 0, 'dx': 20, 'dy': -8, 'anchor': 'start'}
label_rules['del_moolchand'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_kailash_colony'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_nehru_place'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}
label_rules['del_kalkaji_mandir'] = {'angle': 0, 'dx': 20, 'dy': -8, 'anchor': 'start'}

# Faridabad corridor south along X = 2000
vl_stations = lines_meta['violet']['stationIds']
km_idx = vl_stations.index('del_kalkaji_mandir')
for k, sid in enumerate(vl_stations[km_idx + 1:]):
    y = 1940 + (k + 1) * 48
    coords[sid] = (2000, y)
    label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

# 6. Pink Line Ring Loop (Orbital)
coords['del_majlis_park'] = (1360, 320)
coords['del_azadpur'] = (1220, 420)
coords['del_shalimar_bagh'] = (1070, 530)
coords['del_netaji_subhash_place'] = (920, 680)
coords['del_shakurpur'] = (870, 820)
coords['del_punjabi_bagh_west'] = (840, 960)
coords['del_esi_basaidarapur'] = (890, 1120)
coords['del_rajouri_garden'] = (980, 1330)
coords['del_maya_puri'] = (1030, 1460)
coords['del_naraina_vihar'] = (1080, 1550)
coords['del_delhi_cantt'] = (1140, 1630)
coords['del_durgabai_deshmukh_south_campus'] = (1210, 1700)
coords['del_sir_m_vishweshwaraiah_moti_bagh'] = (1280, 1730)
coords['del_bhikaji_cama_place'] = (1350, 1730)
coords['del_sarojini_nagar'] = (1420, 1730)
coords['del_dilli_haat_ina'] = (1500, 1730)
coords['del_south_extension'] = (1680, 1700)
coords['del_lajpat_nagar'] = (1840, 1680)
coords['del_vinobapuri'] = (1940, 1630)
coords['del_ashram'] = (2020, 1550)
coords['del_sarai_kale_khan_hazrat_nizamuddin'] = (2090, 1450)
coords['del_mayur_vihar_1'] = (2200, 1290)
coords['del_mayur_vihar_pocket_1'] = (2270, 1200)
coords['del_trilokpuri_sanjay_lake'] = (2330, 1120)
coords['del_east_vinod_nagar_mayur_vihar_2'] = (2390, 1050)
coords['del_mandawali_west_vinod_nagar'] = (2440, 980)
coords['del_ip_extension'] = (2480, 920)
coords['del_anand_vihar_isbt'] = (2480, 850)
coords['del_karkarduma'] = (2380, 850)
coords['del_karkarduma_court'] = (2300, 800)
coords['del_krishna_nagar'] = (2210, 750)
coords['del_east_azad_nagar'] = (2100, 710)
coords['del_welcome'] = (1950, 680)
coords['del_jaffrabad'] = (1950, 570)
coords['del_maujpur_babarpur'] = (1950, 470)
coords['del_gokulpuri'] = (2020, 390)
coords['del_johri_enclave'] = (2100, 320)
coords['del_shiv_vihar'] = (2190, 260)

for sid in lines_meta['pink']['stationIds']:
    if sid not in label_rules:
        x, y = coords[sid]
        if x < 1500:
            label_rules[sid] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
        else:
            label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

# 7. Magenta Line: Janakpuri West to Botanical Garden
coords['del_janakpuri_west'] = (800, 1550)
coords['del_dabri_mor_janakpuri_south'] = (780, 1680)
coords['del_dashrath_puri'] = (780, 1780)
coords['del_palam'] = (800, 1870)
coords['del_sadaar_bazar_cantonment'] = (850, 1950)
coords['del_terminal_1_igi_airport'] = (920, 2020)
coords['del_shankar_vihar'] = (1010, 2050)
coords['del_vasant_vihar'] = (1110, 2050)
coords['del_munirka'] = (1210, 2050)
coords['del_rk_puram'] = (1310, 2050)
coords['del_iit_delhi'] = (1410, 2020)
coords['del_hauz_khas'] = (1500, 1960)
coords['del_panchsheel_park'] = (1620, 1960)
coords['del_chirag_delhi'] = (1720, 1960)
coords['del_greater_kailash'] = (1820, 1960)
coords['del_nehru_enclave'] = (1910, 1960)
coords['del_kalkaji_mandir'] = (2000, 1940)
coords['del_okhla_nsic'] = (2100, 1890)
coords['del_sukhdev_vihar'] = (2190, 1830)
coords['del_jamia_millia_islamia'] = (2270, 1770)
coords['del_okhla_vihar'] = (2340, 1710)
coords['del_jasola_vihar_shaheen_bagh'] = (2410, 1650)
coords['del_kalindi_kunj'] = (2470, 1600)
coords['del_okhla_bird_sanctuary'] = (2530, 1560)
coords['del_botanical_garden'] = (2600, 1550)

for sid in lines_meta['magenta']['stationIds']:
    if sid not in label_rules:
        label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -10, 'anchor': 'start'}

# 8. Airport Express Line: New Delhi -> Yashobhoomi
coords['del_new_delhi'] = (1500, 1020)
coords['del_shivaji_stadium'] = (1380, 1180)
coords['del_dhaula_kuan'] = (1170, 1660)
coords['del_delhi_aerocity'] = (950, 2120)
coords['del_igi_airport_t3'] = (740, 2260)
coords['del_dwarka_sec_21'] = (320, 2250)
coords['del_yashobhoomi_dwarka_sec_25'] = (220, 2250)

label_rules['del_shivaji_stadium'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
label_rules['del_dhaula_kuan'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
label_rules['del_delhi_aerocity'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
label_rules['del_igi_airport_t3'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}
label_rules['del_dwarka_sec_21'] = {'angle': 0, 'dx': -20, 'dy': -8, 'anchor': 'end'}
label_rules['del_yashobhoomi_dwarka_sec_25'] = {'angle': 0, 'dx': -18, 'dy': -2, 'anchor': 'end'}

# 9. Grey Line: Dwarka to Dhansa Bus Stand
coords['del_dwarka'] = (545, 2025)
coords['del_nangli'] = (440, 2025)
coords['del_najafgarh'] = (330, 2025)
coords['del_dhansa_bus_stand'] = (220, 2025)
for sid in ['del_dwarka', 'del_nangli', 'del_najafgarh', 'del_dhansa_bus_stand']:
    label_rules[sid] = {'angle': -45, 'dx': 6, 'dy': -10, 'anchor': 'start'}

# 10. Rapid Metro Gurugram
coords['del_sikanderpur'] = (1500, 2600)
coords['del_phase_2'] = (1590, 2550)
coords['del_phase_3'] = (1670, 2550)
coords['del_moulsari_avenue'] = (1750, 2600)
coords['del_cyber_city'] = (1750, 2670)
coords['del_belvedere_towers'] = (1670, 2720)
coords['del_phase_1'] = (1590, 2700)
coords['del_sector_42_43'] = (1590, 2760)
coords['del_sector_53_54'] = (1590, 2820)
coords['del_sector_54_chowk'] = (1590, 2880)
coords['del_sector_55_56'] = (1590, 2940)

for sid in lines_meta['rapid_metro']['stationIds']:
    if sid not in label_rules:
        label_rules[sid] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

# 11. Green Line (PROPER BRANCHING - ZERO CRISS CROSS)
# Trunk from Brigadier Hoshiar Singh eastwards to Ashok Park Main along Y = 820
green_trunk = [
    'del_brigadier_hoshiar_singh', 'del_bahadurgarh_city', 'del_pandit_shree_ram_sharma',
    'del_tikri_border', 'del_tikri_kalan', 'del_ghevra_metro', 'del_mundka_industrial_area',
    'del_mundka', 'del_rajdhani_park', 'del_nangloi_railway_station', 'del_nangloi',
    'del_surajmal_stadium', 'del_udyog_nagar', 'del_peera_garhi', 'del_paschim_vihar_west',
    'del_paschim_vihar_east', 'del_madipur', 'del_shivaji_park', 'del_punjabi_bagh',
    'del_punjabi_bagh_west', 'del_ashok_park_main'
]

trunk_start_x = 100
trunk_end_x = 1050
t_step = (trunk_end_x - trunk_start_x) / (len(green_trunk) - 1)

for idx, sid in enumerate(green_trunk):
    coords[sid] = (trunk_start_x + idx * t_step, 820)
    label_rules[sid] = {'angle': -45, 'dx': 8, 'dy': -12, 'anchor': 'start'}

coords['del_ashok_park_main'] = (1050, 820)
coords['del_punjabi_bagh_west'] = (960, 820)
label_rules['del_ashok_park_main'] = {'angle': 0, 'dx': 18, 'dy': -12, 'anchor': 'start'}

# Fork 1: Ashok Park Main to Inderlok (up-right to Red Line)
coords['del_inderlok'] = (1150, 680)

# Fork 2: Ashok Park Main to Kirti Nagar (down-right to Blue Line)
coords['del_satguru_ram_singh_marg'] = (1110, 1000)
coords['del_kirti_nagar'] = (1180, 1190)
label_rules['del_satguru_ram_singh_marg'] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

# 12. Aqua Line (NMRC): Noida Sector 51 to Depot Station
# Sector 51 sits just below Sector 52 (2920, 1550) at (2920, 1680)
coords['del_noida_sec_51'] = (2920, 1680)
label_rules['del_noida_sec_51'] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}

aqua_stations = lines_meta['aqua_noida']['stationIds']
for a_idx, sid in enumerate(aqua_stations):
    if a_idx == 0:
        continue
    elif a_idx <= 14: # straight vertical along X = 2920
        coords[sid] = (2920, 1680 + a_idx * 50)
        label_rules[sid] = {'angle': 0, 'dx': 18, 'dy': -2, 'anchor': 'start'}
    else: # Knowledge Park II to Depot Station (angling right)
        off = a_idx - 14
        coords[sid] = (2920 + off * 60, 1680 + 14 * 50 + off * 40)
        label_rules[sid] = {'angle': -30, 'dx': 14, 'dy': -2, 'anchor': 'start'}

# Fill any missing coords
for s in stations:
    if s['id'] not in coords:
        coords[s['id']] = (1500, 1150)
    if s['id'] not in label_rules:
        label_rules[s['id']] = {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'}

# Generate Lines
def generate_path(station_ids):
    pts = [coords[sid] for sid in station_ids if sid in coords]
    if not pts:
        return ""
    d = [f"M {pts[0][0]:.1f} {pts[0][1]:.1f}"]
    for p in pts[1:]:
        d.append(f"L {p[0]:.1f} {p[1]:.1f}")
    return " ".join(d)

svg_parts = []
svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}" width="100%" height="100%">')

# Clean pure white background
svg_parts.append(f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#FFFFFF"/>')

# Yamuna River (Realistic graceful curved band)
svg_parts.append('<!-- Yamuna River -->')
svg_parts.append('<path d="M 2250 0 C 2200 400, 2150 700, 2000 1000 C 1900 1200, 1980 1480, 2180 1720 C 2350 1920, 2500 2200, 2560 2800" fill="none" stroke="#E0F2FE" stroke-width="48" stroke-linecap="round"/>')
svg_parts.append('<text x="2040" y="1050" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(58 2040 1050)">YAMUNA RIVER</text>')

# External Pathways
svg_parts.append('<!-- Transfers -->')
# Travelator: Dhaula Kuan to South Campus
dk = coords['del_dhaula_kuan']
sc = coords['del_durgabai_deshmukh_south_campus']
svg_parts.append(f'<line x1="{dk[0]}" y1="{dk[1]}" x2="{sc[0]}" y2="{sc[1]}" stroke="#94A3B8" stroke-width="3" stroke-dasharray="4,4"/>')
svg_parts.append(f'<text x="{(dk[0]+sc[0])/2 - 25}" y="{(dk[1]+sc[1])/2 - 6}" font-family="sans-serif" font-size="9" font-weight="bold" fill="#64748B">Travelator</text>')

# Sector 52 to Sector 51 (Noida Aqua link)
s52 = coords['del_noida_sec_52']
s51 = coords['del_noida_sec_51']
svg_parts.append(f'<line x1="{s52[0]}" y1="{s52[1]}" x2="{s51[0]}" y2="{s51[1]}" stroke="#00BCD4" stroke-width="3.5" stroke-dasharray="5,5"/>')
svg_parts.append(f'<text x="{s52[0] + 16}" y="{(s52[1]+s51[1])/2 + 4}" font-family="sans-serif" font-size="9.5" font-weight="bold" fill="#00838F">Exit - 300 m External Pathway</text>')

# Metro Line paths
svg_parts.append('<!-- LINES LAYER -->')
svg_parts.append('<g stroke-linecap="round" stroke-linejoin="round">')

line_configs = [
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

for lid, color, width, s_list in line_configs:
    d = generate_path(s_list)
    svg_parts.append(f'  <path id="route-{lid}" d="{d}" fill="none" stroke="{color}" stroke-width="{width}"/>')

# Green Line Trunk + 2 distinct branches (Clean Y-fork, NO zig-zag)
green_d = generate_path(green_trunk)
svg_parts.append(f'  <path id="route-green-trunk" d="{green_d}" fill="none" stroke="#388E3C" stroke-width="9"/>')

ap = coords['del_ashok_park_main']
il = coords['del_inderlok']
sr = coords['del_satguru_ram_singh_marg']
kn = coords['del_kirti_nagar']
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {il[0]} {il[1]}" fill="none" stroke="#388E3C" stroke-width="9"/>')
svg_parts.append(f'  <path d="M {ap[0]} {ap[1]} L {sr[0]} {sr[1]} L {kn[0]} {kn[1]}" fill="none" stroke="#388E3C" stroke-width="9"/>')

svg_parts.append('</g>')

# Station Nodes & Typography with White Halo (Zero collision with lines)
svg_parts.append('<!-- STATIONS & LABELS LAYER -->')
svg_parts.append('<g id="stations-layer">')

for s in stations:
    sid = s['id']
    x, y = coords[sid]
    is_ic = s.get('isInterchange', False)
    name_en = s['name'].replace('&', '&amp;')
    name_hi = s.get('hindiName', '').replace('&', '&amp;')
    
    rule = label_rules.get(sid, {'angle': 0, 'dx': 16, 'dy': -2, 'anchor': 'start'})
    angle = rule['angle']
    dx = rule['dx']
    dy = rule['dy']
    anchor = rule['anchor']

    # Draw Station Indicator
    if is_ic:
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="10" fill="#FFFFFF" stroke="#0F172A" stroke-width="3"/>')
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="4" fill="#0F172A"/>')
    else:
        svg_parts.append(f'  <circle cx="{x}" cy="{y}" r="4" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')

    # Draw Bilingual Typography with White Halo
    lx = x + dx
    ly = y + dy
    transform_attr = f' transform="rotate({angle} {lx} {ly})"' if angle != 0 else ''

    if is_ic:
        # Bold Interchange Label
        svg_parts.append(f'  <g{transform_attr}>')
        svg_parts.append(f'    <text x="{lx}" y="{ly}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="bold" fill="#334155">{name_hi}</text>')
        svg_parts.append(f'    <text x="{lx}" y="{ly + 14}" text-anchor="{anchor}" font-family="sans-serif" font-size="13.5" font-weight="900" fill="#020617">{name_en}</text>')
        svg_parts.append('  </g>')
    else:
        # Clean Normal Station Label
        svg_parts.append(f'  <g{transform_attr}>')
        svg_parts.append(f'    <text x="{lx}" y="{ly}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="600" fill="#475569">{name_hi}</text>')
        svg_parts.append(f'    <text x="{lx}" y="{ly + 12}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="bold" fill="#0F172A">{name_en}</text>')
        svg_parts.append('  </g>')

svg_parts.append('</g>')

# Clean Legend Card (Top Right)
leg_x = 2780
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

with open(OUT_SVG, 'w', encoding='utf-8') as f:
    f.write(svg_content)

print(f"Generated clean non-overlapping Delhi SVG to {OUT_SVG} ({len(svg_content)} bytes)")
