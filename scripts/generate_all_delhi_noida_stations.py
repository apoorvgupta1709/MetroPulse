import json
import os
import subprocess
import urllib.request
import urllib.error

# Output paths
DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'data', 'production'))
os.makedirs(DATA_DIR, exist_ok=True)
DELHI_JSON_PATH = os.path.join(DATA_DIR, 'delhi_metro_production.json')

print("Compiling COMPLETE exhaustive production dataset for Delhi NCR & Noida Metro...")

# -------------------------------------------------------------
# ALL 12 DELHI & NOIDA METRO LINES
# -------------------------------------------------------------
lines = [
    {
        "id": "yellow",
        "cityId": "delhi_ncr",
        "name": "Yellow Line",
        "code": "YL",
        "colorHex": "#FBC02D",
        "firstTrain": "05:30 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 3,
        "startStationName": "Samaypur Badli",
        "endStationName": "Millennium City Centre Gurugram",
        "stationIds": [
            "del_samaypur_badli", "del_rohini_sec_18_19", "del_haiderpur_badli_mor", "del_jahangirpuri",
            "del_adarsh_nagar", "del_azadpur", "del_model_town", "del_gtb_nagar",
            "del_vishwavidyalaya", "del_vidhan_sabha", "del_civil_lines", "del_kashmere_gate",
            "del_chandni_chowk", "del_chawri_bazar", "del_new_delhi", "del_rajiv_chowk",
            "del_patel_chowk", "del_central_secretariat", "del_udyog_bhawan", "del_lok_kalyan_marg",
            "del_jor_bagh", "del_dilli_haat_ina", "del_aiims", "del_green_park",
            "del_hauz_khas", "del_malviya_nagar", "del_saket", "del_qutab_minar",
            "del_chhattarpur", "del_sultanpur", "del_ghitorni", "del_arjan_garh",
            "del_guru_dronacharya", "del_sikanderpur", "del_mg_road", "del_iffco_chowk",
            "del_millennium_city_centre"
        ]
    },
    {
        "id": "blue",
        "cityId": "delhi_ncr",
        "name": "Blue Line Main (Dwarka Sec 21 - Noida Electronic City)",
        "code": "BL",
        "colorHex": "#1E88E5",
        "firstTrain": "05:30 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 3,
        "startStationName": "Dwarka Sector 21",
        "endStationName": "Noida Electronic City",
        "stationIds": [
            "del_dwarka_sec_21", "del_dwarka_sec_8", "del_dwarka_sec_9", "del_dwarka_sec_10",
            "del_dwarka_sec_11", "del_dwarka_sec_12", "del_dwarka_sec_13", "del_dwarka_sec_14",
            "del_dwarka", "del_dwarka_mor", "del_nawada", "del_uttam_nagar_west",
            "del_uttam_nagar_east", "del_janakpuri_west", "del_janakpuri_east", "del_tilak_nagar",
            "del_subhash_nagar", "del_tagore_garden", "del_rajouri_garden", "del_ramesh_nagar",
            "del_moti_nagar", "del_kirti_nagar", "del_shadipur", "del_patel_nagar",
            "del_rajendra_place", "del_karol_bagh", "del_jhandewalan", "del_rk_ashram_marg",
            "del_rajiv_chowk", "del_barakhamba_road", "del_mandi_house", "del_supreme_court",
            "del_indraprastha", "del_yamuna_bank", "del_akshardham", "del_mayur_vihar_1",
            "del_mayur_vihar_ext", "del_new_ashok_nagar", "del_noida_sec_15", "del_noida_sec_16",
            "del_noida_sec_18", "del_botanical_garden", "del_golf_course", "del_noida_city_centre",
            "del_noida_sec_34", "del_noida_sec_52", "del_noida_sec_61", "del_noida_sec_59",
            "del_noida_sec_62", "del_noida_electronic_city"
        ]
    },
    {
        "id": "blue_vaishali",
        "cityId": "delhi_ncr",
        "name": "Blue Line Branch (Yamuna Bank - Vaishali Ghaziabad)",
        "code": "BL-V",
        "colorHex": "#0D47A1",
        "firstTrain": "05:30 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 5,
        "startStationName": "Yamuna Bank",
        "endStationName": "Vaishali",
        "stationIds": [
            "del_yamuna_bank", "del_laxmi_nagar", "del_nirman_vihar", "del_preet_vihar",
            "del_karkarduma", "del_anand_vihar_isbt", "del_kaushambi", "del_vaishali"
        ]
    },
    {
        "id": "red",
        "cityId": "delhi_ncr",
        "name": "Red Line (Rithala - Shaheed Sthal Ghaziabad)",
        "code": "RD",
        "colorHex": "#E53935",
        "firstTrain": "05:30 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 4,
        "startStationName": "Rithala",
        "endStationName": "Shaheed Sthal (New Bus Adda)",
        "stationIds": [
            "del_rithala", "del_rohini_west", "del_rohini_east", "del_pitampura",
            "del_kohat_enclave", "del_netaji_subhash_place", "del_keshav_puram", "del_kanhaiya_nagar",
            "del_inderlok", "del_shastri_nagar", "del_pratap_nagar", "del_pulbangash",
            "del_tis_hazari", "del_kashmere_gate", "del_shastri_park", "del_seelampur",
            "del_welcome", "del_shahdara", "del_mansarovar_park", "del_jhilmil",
            "del_dilshad_garden", "del_shaheed_nagar", "del_raj_bagh", "del_major_mohit_sharma",
            "del_shyam_park", "del_mohan_nagar", "del_arthala", "del_hindon_river",
            "del_shaheed_sthal"
        ]
    },
    {
        "id": "green",
        "cityId": "delhi_ncr",
        "name": "Green Line (Inderlok/Kirti Nagar - Bahadurgarh City)",
        "code": "GR",
        "colorHex": "#43A047",
        "firstTrain": "06:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 6,
        "startStationName": "Inderlok / Kirti Nagar",
        "endStationName": "Brigadier Hoshiar Singh",
        "stationIds": [
            "del_inderlok", "del_kirti_nagar", "del_ashok_park_main", "del_punjabi_bagh",
            "del_punjabi_bagh_west", "del_shivaji_park", "del_madipur", "del_paschim_vihar_east",
            "del_paschim_vihar_west", "del_peera_garhi", "del_udyog_nagar", "del_surajmal_stadium",
            "del_nangloi", "del_nangloi_railway_station", "del_rajdhani_park", "del_mundka",
            "del_mundka_industrial_area", "del_ghevra_metro", "del_tikri_kalan", "del_tikri_border",
            "del_pandit_shree_ram_sharma", "del_bahadurgarh_city", "del_brigadier_hoshiar_singh"
        ]
    },
    {
        "id": "violet",
        "cityId": "delhi_ncr",
        "name": "Violet Line (Kashmere Gate - Raja Nahar Singh Ballabhgarh)",
        "code": "VT",
        "colorHex": "#8E24AA",
        "firstTrain": "06:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 4,
        "startStationName": "Kashmere Gate",
        "endStationName": "Raja Nahar Singh (Ballabhgarh)",
        "stationIds": [
            "del_kashmere_gate", "del_lal_quila", "del_jama_masjid", "del_delhi_gate",
            "del_ito", "del_mandi_house", "del_janpath", "del_central_secretariat",
            "del_khan_market", "del_jawaharlal_nehru_stadium", "del_jangpura", "del_lajpat_nagar",
            "del_moolchand", "del_kailash_colony", "del_nehru_place", "del_kalkaji_mandir",
            "del_govindpuri", "del_harkesh_nagar_okhla", "del_jasola_apollo", "del_sarita_vihar",
            "del_mohan_estate", "del_tughlakabad_station", "del_badarpur_border", "del_sarai",
            "del_nhpc_chowk", "del_mewala_maharajpur", "del_sector_28_faridabad", "del_badkal_mor",
            "del_old_faridabad", "del_neelam_chowk_ajronda", "del_bata_chowk", "del_escorts_mujesar",
            "del_sant_surdas_sihi", "del_raja_nahar_singh"
        ]
    },
    {
        "id": "pink",
        "cityId": "delhi_ncr",
        "name": "Pink Line (Majlis Park - Shiv Vihar Ring Loop)",
        "code": "PK",
        "colorHex": "#EC407A",
        "firstTrain": "06:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 4,
        "startStationName": "Majlis Park",
        "endStationName": "Shiv Vihar",
        "stationIds": [
            "del_majlis_park", "del_azadpur", "del_shalimar_bagh", "del_netaji_subhash_place",
            "del_shakurpur", "del_punjabi_bagh_west", "del_esi_basaidarapur", "del_rajouri_garden",
            "del_maya_puri", "del_naraina_vihar", "del_delhi_cantt", "del_durgabai_deshmukh_south_campus",
            "del_sir_m_vishweshwaraiah_moti_bagh", "del_bhikaji_cama_place", "del_sarojini_nagar", "del_dilli_haat_ina",
            "del_south_extension", "del_lajpat_nagar", "del_vinobapuri", "del_ashram",
            "del_sarai_kale_khan_hazrat_nizamuddin", "del_mayur_vihar_1", "del_mayur_vihar_pocket_1", "del_trilokpuri_sanjay_lake",
            "del_east_vinod_nagar_mayur_vihar_2", "del_mandawali_west_vinod_nagar", "del_ip_extension", "del_anand_vihar_isbt",
            "del_karkarduma", "del_karkarduma_court", "del_krishna_nagar", "del_east_azad_nagar",
            "del_welcome", "del_jaffrabad", "del_maujpur_babarpur", "del_gokulpuri",
            "del_johri_enclave", "del_shiv_vihar"
        ]
    },
    {
        "id": "magenta",
        "cityId": "delhi_ncr",
        "name": "Magenta Line (Janakpuri West - Botanical Garden Noida)",
        "code": "MG",
        "colorHex": "#D81B60",
        "firstTrain": "05:40 AM",
        "lastTrain": "11:20 PM",
        "frequencyMinutes": 4,
        "startStationName": "Janakpuri West",
        "endStationName": "Botanical Garden (Noida)",
        "stationIds": [
            "del_janakpuri_west", "del_dabri_mor_janakpuri_south", "del_dashrath_puri", "del_palam",
            "del_sadaar_bazar_cantonment", "del_terminal_1_igi_airport", "del_shankar_vihar", "del_vasant_vihar",
            "del_munirka", "del_rk_puram", "del_iit_delhi", "del_hauz_khas",
            "del_panchsheel_park", "del_chirag_delhi", "del_greater_kailash", "del_nehru_enclave",
            "del_kalkaji_mandir", "del_okhla_nsic", "del_sukhdev_vihar", "del_jamia_millia_islamia",
            "del_okhla_vihar", "del_jasola_vihar_shaheen_bagh", "del_kalindi_kunj", "del_okhla_bird_sanctuary",
            "del_botanical_garden"
        ]
    },
    {
        "id": "grey",
        "cityId": "delhi_ncr",
        "name": "Grey Line (Dwarka - Dhansa Bus Stand)",
        "code": "GY",
        "colorHex": "#78909C",
        "firstTrain": "06:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 8,
        "startStationName": "Dwarka",
        "endStationName": "Dhansa Bus Stand",
        "stationIds": ["del_dwarka", "del_nangli", "del_najafgarh", "del_dhansa_bus_stand"]
    },
    {
        "id": "airport_express",
        "cityId": "delhi_ncr",
        "name": "Airport Express Line (New Delhi - Yashobhoomi Dwarka Sec 25)",
        "code": "AE",
        "colorHex": "#FB8C00",
        "firstTrain": "04:45 AM",
        "lastTrain": "11:40 PM",
        "frequencyMinutes": 10,
        "startStationName": "New Delhi Railway Station",
        "endStationName": "Yashobhoomi Dwarka Sector 25",
        "stationIds": [
            "del_new_delhi", "del_shivaji_stadium", "del_dhaula_kuan", "del_delhi_aerocity",
            "del_igi_airport_t3", "del_dwarka_sec_21", "del_yashobhoomi_dwarka_sec_25"
        ]
    },
    {
        "id": "rapid_metro",
        "cityId": "delhi_ncr",
        "name": "Rapid Metro Gurugram",
        "code": "RM",
        "colorHex": "#00ACC1",
        "firstTrain": "06:05 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 5,
        "startStationName": "Sector 55-56 Gurugram",
        "endStationName": "Phase 3 Gurugram",
        "stationIds": [
            "del_rm_sec_55_56", "del_rm_sec_54_chowk", "del_rm_sec_53_54", "del_rm_sec_42_43",
            "del_rm_phase_1", "del_sikanderpur", "del_rm_phase_2", "del_rm_belvedere_towers",
            "del_rm_cyber_city", "del_rm_moulsari_avenue", "del_rm_phase_3"
        ]
    },
    {
        "id": "aqua_noida",
        "cityId": "delhi_ncr",
        "name": "Aqua Line (NMRC Noida - Greater Noida)",
        "code": "AQ",
        "colorHex": "#26C6DA",
        "firstTrain": "06:00 AM",
        "lastTrain": "10:00 PM",
        "frequencyMinutes": 10,
        "startStationName": "Noida Sector 51",
        "endStationName": "Depot Station (Greater Noida)",
        "stationIds": [
            "del_noida_sec_51", "del_noida_sec_50", "del_noida_sec_76", "del_noida_sec_101",
            "del_noida_sec_81", "del_nsez", "del_noida_sec_83", "del_noida_sec_137",
            "del_noida_sec_142", "del_noida_sec_143", "del_noida_sec_144", "del_noida_sec_145",
            "del_noida_sec_146", "del_noida_sec_147", "del_noida_sec_148", "del_knowledge_park_2",
            "del_pari_chowk", "del_alpha_1", "del_delta_1", "del_gnida_office", "del_depot_station"
        ]
    }
]

# Helper to build stations dictionary
stations_dict = {}

def add_station(s_id, name, hindi, lines_list, lat, lon, is_inter=False, gates=None):
    if s_id in stations_dict:
        # Merge lines if station is interchange
        existing = stations_dict[s_id]
        merged_lines = list(set(existing["lineIds"] + lines_list))
        existing["lineIds"] = merged_lines
        existing["isInterchange"] = len(merged_lines) > 1
        return

    default_gates = [
        {"gateNumber": "Gate 1", "landmark": "Main Road Concourse Entrance", "accessible": True},
        {"gateNumber": "Gate 2", "landmark": "Opposite Market & Bus Stop Link", "accessible": True}
    ]

    stations_dict[s_id] = {
        "id": s_id,
        "cityId": "delhi_ncr",
        "name": name,
        "hindiName": hindi,
        "lineIds": lines_list,
        "isInterchange": is_inter or len(lines_list) > 1,
        "latitude": round(lat, 5),
        "longitude": round(lon, 5),
        "facilities": {
            "hasParking": True,
            "hasEscalator": True,
            "hasElevator": True,
            "hasAtm": True,
            "hasRestroom": True
        },
        "gates": gates or default_gates,
        "platformDirections": {
            l: f"Platform 1 / 2 ({l.replace('_', ' ').capitalize()} Line)" for l in lines_list
        }
    }

# 1. YELLOW LINE (37 Stations)
add_station("del_samaypur_badli", "Samaypur Badli", "समयपुर बादली", ["yellow"], 28.7456, 77.1350)
add_station("del_rohini_sec_18_19", "Rohini Sector 18-19", "रोहिणी सेक्टर 18-19", ["yellow"], 28.7397, 77.1408)
add_station("del_haiderpur_badli_mor", "Haiderpur Badli Mor", "हैदरपुर बादली मोड़", ["yellow"], 28.7303, 77.1491)
add_station("del_jahangirpuri", "Jahangirpuri", "जहाँगीरपुरी", ["yellow"], 28.7259, 77.1627)
add_station("del_adarsh_nagar", "Adarsh Nagar", "आदर्श नगर", ["yellow"], 28.7155, 77.1706)
add_station("del_azadpur", "Azadpur", "आज़ादपुर", ["yellow", "pink"], 28.7068, 77.1804, is_inter=True)
add_station("del_model_town", "Model Town", "मॉडल टाउन", ["yellow"], 28.6989, 77.1936)
add_station("del_gtb_nagar", "Guru Tegh Bahadur Nagar (GTB)", "गुरु तेग बहादुर नगर", ["yellow"], 28.6978, 77.2066)
add_station("del_vishwavidyalaya", "Vishwavidyalaya (Delhi University)", "विश्वविद्यालय", ["yellow"], 28.6946, 77.2155)
add_station("del_vidhan_sabha", "Vidhan Sabha (Delhi Assembly)", "विधान सभा", ["yellow"], 28.6811, 77.2217)
add_station("del_civil_lines", "Civil Lines", "सिविल लाइन्स", ["yellow"], 28.6775, 77.2246)
add_station("del_kashmere_gate", "Kashmere Gate ISBT", "कश्मीरी गेट", ["yellow", "red", "violet"], 28.6675, 77.2285, is_inter=True)
add_station("del_chandni_chowk", "Chandni Chowk (Old Delhi Railway)", "चाँदनी चौक", ["yellow"], 28.6578, 77.2304)
add_station("del_chawri_bazar", "Chawri Bazar (Jama Masjid)", "चावड़ी बाज़ार", ["yellow"], 28.6493, 77.2263)
add_station("del_new_delhi", "New Delhi Railway Station", "नई दिल्ली", ["yellow", "airport_express"], 28.6431, 77.2223, is_inter=True)
add_station("del_rajiv_chowk", "Rajiv Chowk (Connaught Place)", "राजीव चौक", ["yellow", "blue"], 28.6328, 77.2197, is_inter=True)
add_station("del_patel_chowk", "Patel Chowk (Gurudwara Bangla Sahib)", "पटेल चौक", ["yellow"], 28.6231, 77.2136)
add_station("del_central_secretariat", "Central Secretariat", "केंद्रीय सचिवालय", ["yellow", "violet"], 28.6147, 77.2119, is_inter=True)
add_station("del_udyog_bhawan", "Udyog Bhawan (National Museum)", "उद्योग भवन", ["yellow"], 28.6111, 77.2122)
add_station("del_lok_kalyan_marg", "Lok Kalyan Marg (Race Course)", "लोक कल्याण मार्ग", ["yellow"], 28.5986, 77.2114)
add_station("del_jor_bagh", "Jor Bagh (Safdarjung Tomb)", "जोर बाग़", ["yellow"], 28.5881, 77.2125)
add_station("del_dilli_haat_ina", "Dilli Haat - INA", "दिल्ली हाट - आईएनए", ["yellow", "pink"], 28.5744, 77.2098, is_inter=True)
add_station("del_aiims", "AIIMS Hospital", "एम्स", ["yellow"], 28.5678, 77.2081)
add_station("del_green_park", "Green Park", "ग्रीन पार्क", ["yellow"], 28.5586, 77.2064)
add_station("del_hauz_khas", "Hauz Khas (Deer Park / IIT)", "हौज़ ख़ास", ["yellow", "magenta"], 28.5431, 77.2065, is_inter=True)
add_station("del_malviya_nagar", "Malviya Nagar (Select Citywalk Link)", "मालवीय नगर", ["yellow"], 28.5283, 77.2061)
add_station("del_saket", "Saket", "साकेत", ["yellow"], 28.5208, 77.2014)
add_station("del_qutab_minar", "Qutab Minar", "क़ुतुब मीनार", ["yellow"], 28.5128, 77.1858)
add_station("del_chhattarpur", "Chhattarpur (Chhattarpur Mandir)", "छत्तरपुर", ["yellow"], 28.5064, 77.1747)
add_station("del_sultanpur", "Sultanpur", "सुल्तानपुर", ["yellow"], 28.4986, 77.1614)
add_station("del_ghitorni", "Ghitorni", "घिटोरनी", ["yellow"], 28.4925, 77.1489)
add_station("del_arjan_garh", "Arjan Garh (Aya Nagar)", "अर्जन गढ़", ["yellow"], 28.4808, 77.1256)
add_station("del_guru_dronacharya", "Guru Dronacharya (Garden Estate)", "गुरु द्रोणाचार्य", ["yellow"], 28.4817, 77.1028)
add_station("del_sikanderpur", "Sikanderpur (Gurugram)", "सिकंदरपुर", ["yellow", "rapid_metro"], 28.4817, 77.0928, is_inter=True)
add_station("del_mg_road", "MG Road Gurugram (MGF Mall)", "एम जी रोड", ["yellow"], 28.4797, 77.0803)
add_station("del_iffco_chowk", "IFFCO Chowk", "इफ़्को चौक", ["yellow"], 28.4722, 77.0725)
add_station("del_millennium_city_centre", "Millennium City Centre Gurugram (HUDA)", "मिलेनियम सिटी सेंटर गुरुग्राम", ["yellow"], 28.4593, 77.0726)

# 2. BLUE LINE (Main 50 Stations + Vaishali Branch 8 Stations)
add_station("del_dwarka_sec_21", "Dwarka Sector 21", "द्वारका सेक्टर 21", ["blue", "airport_express"], 28.5522, 77.0583, is_inter=True)
add_station("del_dwarka_sec_8", "Dwarka Sector 8", "द्वारका सेक्टर 8", ["blue"], 28.5647, 77.0678)
add_station("del_dwarka_sec_9", "Dwarka Sector 9", "द्वारका सेक्टर 9", ["blue"], 28.5744, 77.0642)
add_station("del_dwarka_sec_10", "Dwarka Sector 10", "द्वारका सेक्टर 10", ["blue"], 28.5811, 77.0572)
add_station("del_dwarka_sec_11", "Dwarka Sector 11", "द्वारका सेक्टर 11", ["blue"], 28.5886, 77.0536)
add_station("del_dwarka_sec_12", "Dwarka Sector 12", "द्वारका सेक्टर 12", ["blue"], 28.5925, 77.0406)
add_station("del_dwarka_sec_13", "Dwarka Sector 13", "द्वारका सेक्टर 13", ["blue"], 28.6006, 77.0347)
add_station("del_dwarka_sec_14", "Dwarka Sector 14", "द्वारका सेक्टर 14", ["blue"], 28.6022, 77.0258)
add_station("del_dwarka", "Dwarka", "द्वारका", ["blue", "grey"], 28.6144, 77.0208, is_inter=True)
add_station("del_dwarka_mor", "Dwarka Mor (NSUT Link)", "द्वारका मोड़", ["blue"], 28.6194, 77.0336)
add_station("del_nawada", "Nawada", "नवादा", ["blue"], 28.6217, 77.0442)
add_station("del_uttam_nagar_west", "Uttam Nagar West", "उत्तम नगर पश्चिम", ["blue"], 28.6247, 77.0567)
add_station("del_uttam_nagar_east", "Uttam Nagar East", "उत्तम नगर पूर्व", ["blue"], 28.6258, 77.0658)
add_station("del_janakpuri_west", "Janakpuri West", "जनकपुरी पश्चिम", ["blue", "magenta"], 28.6294, 77.0778, is_inter=True)
add_station("del_janakpuri_east", "Janakpuri East", "जनकपुरी पूर्व", ["blue"], 28.6322, 77.0878)
add_station("del_tilak_nagar", "Tilak Nagar", "तिलक नगर", ["blue"], 28.6367, 77.0967)
add_station("del_subhash_nagar", "Subhash Nagar (Pacific Mall)", "सुभाष नगर", ["blue"], 28.6406, 77.1053)
add_station("del_tagore_garden", "Tagore Garden", "टैगोर गार्डन", ["blue"], 28.6442, 77.1128)
add_station("del_rajouri_garden", "Rajouri Garden", "राजौरी गार्डन", ["blue", "pink"], 28.6492, 77.1217, is_inter=True)
add_station("del_ramesh_nagar", "Ramesh Nagar", "रमेश नगर", ["blue"], 28.6533, 77.1306)
add_station("del_moti_nagar", "Moti Nagar", "मोती नगर", ["blue"], 28.6578, 77.1422)
add_station("del_kirti_nagar", "Kirti Nagar", "कीर्ति नगर", ["blue", "green"], 28.6558, 77.1517, is_inter=True)
add_station("del_shadipur", "Shadipur", "शादीपुर", ["blue"], 28.6517, 77.1583)
add_station("del_patel_nagar", "Patel Nagar", "पटेल नगर", ["blue"], 28.6472, 77.1683)
add_station("del_rajendra_place", "Rajendra Place", "राजेंद्र प्लेस", ["blue"], 28.6425, 77.1783)
add_station("del_karol_bagh", "Karol Bagh (Market)", "करोल बाग़", ["blue"], 28.6442, 77.1906)
add_station("del_jhandewalan", "Jhandewalan (Hanuman Mandir)", "झंडेवालान", ["blue"], 28.6442, 77.1997)
add_station("del_rk_ashram_marg", "Ramakrishna Ashram Marg", "रामकृष्ण आश्रम मार्ग", ["blue"], 28.6394, 77.2089)
add_station("del_barakhamba_road", "Barakhamba Road", "बाराखंभा रोड", ["blue"], 28.6308, 77.2269)
add_station("del_mandi_house", "Mandi House (National School of Drama)", "मंडी हाउस", ["blue", "violet"], 28.6258, 77.2344, is_inter=True)
add_station("del_supreme_court", "Supreme Court (Pragati Maidan)", "सुप्रीम कोर्ट", ["blue"], 28.6247, 77.2436)
add_station("del_indraprastha", "Indraprastha", "इंद्रप्रस्थ", ["blue"], 28.6208, 77.2514)
add_station("del_yamuna_bank", "Yamuna Bank", "यमुना बैंक", ["blue", "blue_vaishali"], 28.6236, 77.2683, is_inter=True)
add_station("del_akshardham", "Akshardham Temple", "अक्षरधाम", ["blue"], 28.6181, 77.2792)
add_station("del_mayur_vihar_1", "Mayur Vihar-I", "मयूर विहार-१", ["blue", "pink"], 28.6053, 77.2947, is_inter=True)
add_station("del_mayur_vihar_ext", "Mayur Vihar Extension", "मयूर विहार विस्तार", ["blue"], 28.5936, 77.3039)
add_station("del_new_ashok_nagar", "New Ashok Nagar", "न्यू अशोक नगर", ["blue"], 28.5892, 77.3117)

# ALL NOIDA BLUE LINE STATIONS (12 Stations in Noida!)
add_station("del_noida_sec_15", "Noida Sector 15", "नोएडा सेक्टर 15", ["blue"], 28.5853, 77.3136)
add_station("del_noida_sec_16", "Noida Sector 16", "नोएडा सेक्टर 16", ["blue"], 28.5786, 77.3178)
add_station("del_noida_sec_18", "Noida Sector 18 (Atta Market / Mall of India)", "नोएडा सेक्टर 18", ["blue"], 28.5708, 77.3261)
add_station("del_botanical_garden", "Botanical Garden (Noida)", "बॉटनिकल गार्डन", ["blue", "magenta"], 28.5641, 77.3342, is_inter=True)
add_station("del_golf_course", "Golf Course Noida", "गोल्फ कोर्स", ["blue"], 28.5667, 77.3456)
add_station("del_noida_city_centre", "Noida City Centre (Sector 32)", "नोएडा सिटी सेंटर", ["blue"], 28.5747, 77.3561)
add_station("del_noida_sec_34", "Noida Sector 34", "नोएडा सेक्टर 34", ["blue"], 28.5794, 77.3653)
add_station("del_noida_sec_52", "Noida Sector 52 (Interchange Walkway to Aqua Line Sec 51)", "नोएडा सेक्टर 52", ["blue"], 28.5833, 77.3712, is_inter=True)
add_station("del_noida_sec_61", "Noida Sector 61", "नोएडा सेक्टर 61", ["blue"], 28.5986, 77.3697)
add_station("del_noida_sec_59", "Noida Sector 59", "नोएडा सेक्टर 59", ["blue"], 28.6078, 77.3703)
add_station("del_noida_sec_62", "Noida Sector 62", "नोएडा सेक्टर 62", ["blue"], 28.6189, 77.3719)
add_station("del_noida_electronic_city", "Noida Electronic City (NH-24)", "नोएडा इलेक्ट्रॉनिक सिटी", ["blue"], 28.6277, 77.3734)

# BLUE LINE VAISHALI BRANCH (8 Stations)
add_station("del_laxmi_nagar", "Laxmi Nagar (V3S Mall)", "लक्ष्मी नगर", ["blue_vaishali"], 28.6308, 77.2775)
add_station("del_nirman_vihar", "Nirman Vihar (Scope Minar)", "निर्माण विहार", ["blue_vaishali"], 28.6367, 77.2869)
add_station("del_preet_vihar", "Preet Vihar", "प्रीत विहार", ["blue_vaishali"], 28.6419, 77.2953)
add_station("del_karkarduma", "Karkarduma", "कड़कड़डूमा", ["blue_vaishali", "pink"], 28.6486, 77.3047, is_inter=True)
add_station("del_anand_vihar_isbt", "Anand Vihar ISBT & Railway Station", "आनंद विहार", ["blue_vaishali", "pink"], 28.6475, 77.3156, is_inter=True)
add_station("del_kaushambi", "Kaushambi (Wave Cinema)", "कौशाम्बी", ["blue_vaishali"], 28.6453, 77.3242)
add_station("del_vaishali", "Vaishali (Ghaziabad)", "वैशाली", ["blue_vaishali"], 28.6497, 77.3397)

# ALL NOIDA AQUA LINE STATIONS (NMRC - 21 Stations in Noida & Greater Noida!)
add_station("del_noida_sec_51", "Noida Sector 51 (Aqua Line Terminal Link)", "नोएडा सेक्टर 51", ["aqua_noida"], 28.5847, 77.3739, is_inter=True)
add_station("del_noida_sec_50", "Noida Sector 50 (She-Is-Special)", "नोएडा सेक्टर 50", ["aqua_noida"], 28.5744, 77.3789)
add_station("del_noida_sec_76", "Noida Sector 76", "नोएडा सेक्टर 76", ["aqua_noida"], 28.5672, 77.3853)
add_station("del_noida_sec_101", "Noida Sector 101", "नोएडा सेक्टर 101", ["aqua_noida"], 28.5583, 77.3917)
add_station("del_noida_sec_81", "Noida Sector 81", "नोएडा सेक्टर 81", ["aqua_noida"], 28.5447, 77.4014)
add_station("del_nsez", "NSEZ (Noida Special Economic Zone)", "एनएसईजेड", ["aqua_noida"], 28.5303, 77.4097)
add_station("del_noida_sec_83", "Noida Sector 83", "नोएडा सेक्टर 83", ["aqua_noida"], 28.5147, 77.4183)
add_station("del_noida_sec_137", "Noida Sector 137 (Felix Hospital Link)", "नोएडा सेक्टर 137", ["aqua_noida"], 28.5039, 77.4114)
add_station("del_noida_sec_142", "Noida Sector 142 (Advant Navis Link)", "नोएडा सेक्टर 142", ["aqua_noida"], 28.4908, 77.4267)
add_station("del_noida_sec_143", "Noida Sector 143", "नोएडा सेक्टर 143", ["aqua_noida"], 28.4811, 77.4367)
add_station("del_noida_sec_144", "Noida Sector 144", "नोएडा सेक्टर 144", ["aqua_noida"], 28.4719, 77.4475)
add_station("del_noida_sec_145", "Noida Sector 145", "नोएडा सेक्टर 145", ["aqua_noida"], 28.4619, 77.4589)
add_station("del_noida_sec_146", "Noida Sector 146", "नोएडा सेक्टर 146", ["aqua_noida"], 28.4528, 77.4697)
add_station("del_noida_sec_147", "Noida Sector 147", "नोएडा सेक्टर 147", ["aqua_noida"], 28.4436, 77.4808)
add_station("del_noida_sec_148", "Noida Sector 148", "नोएडा सेक्टर 148", ["aqua_noida"], 28.4347, 77.4919)
add_station("del_knowledge_park_2", "Knowledge Park II (Greater Noida)", "नॉलेज पार्क २", ["aqua_noida"], 28.4567, 77.5028)
add_station("del_pari_chowk", "Pari Chowk (Greater Noida Bus Port)", "परी चौक", ["aqua_noida"], 28.4636, 77.5142)
add_station("del_alpha_1", "Alpha 1 (Commercial Belt)", "अल्फा १", ["aqua_noida"], 28.4719, 77.5217)
add_station("del_delta_1", "Delta 1", "डेल्टा १", ["aqua_noida"], 28.4808, 77.5303)
add_station("del_gnida_office", "GNIDA Office (Greater Noida Authority)", "ग्रेनो प्राधिकरण कार्यालय", ["aqua_noida"], 28.4897, 77.5389)
add_station("del_depot_station", "Depot Station (Greater Noida Terminal)", "डिपो स्टेशन", ["aqua_noida"], 28.4983, 77.5475)

# 3. RED LINE (29 Stations)
add_station("del_rithala", "Rithala", "रिठाला", ["red"], 28.7208, 77.1071)
add_station("del_rohini_west", "Rohini West", "रोहिणी पश्चिम", ["red"], 28.7144, 77.1147)
add_station("del_rohini_east", "Rohini East", "रोहिणी पूर्व", ["red"], 28.7083, 77.1231)
add_station("del_pitampura", "Pitampura", "पीतमपुरा", ["red"], 28.7031, 77.1328)
add_station("del_kohat_enclave", "Kohat Enclave", "कोहाट एन्क्लेव", ["red"], 28.6978, 77.1425)
add_station("del_netaji_subhash_place", "Netaji Subhash Place (NSP)", "नेताजी सुभाष प्लेस", ["red", "pink"], 28.6953, 77.1528, is_inter=True)
add_station("del_keshav_puram", "Keshav Puram", "केशव पुरम", ["red"], 28.6908, 77.1619)
add_station("del_kanhaiya_nagar", "Kanhaiya Nagar", "कन्हैया नगर", ["red"], 28.6828, 77.1653)
add_station("del_inderlok", "Inderlok", "इंद्रलोक", ["red", "green"], 28.6731, 77.1706, is_inter=True)
add_station("del_shastri_nagar", "Shastri Nagar", "शास्त्री नगर", ["red"], 28.6694, 77.1814)
add_station("del_pratap_nagar", "Pratap Nagar", "प्रताप नगर", ["red"], 28.6672, 77.1978)
add_station("del_pulbangash", "Pulbangash", "पुल बंगश", ["red"], 28.6661, 77.2081)
add_station("del_tis_hazari", "Tis Hazari (Courts)", "तीस हज़ारी", ["red"], 28.6678, 77.2181)
add_station("del_shastri_park", "Shastri Park", "शास्त्री पार्क", ["red"], 28.6689, 77.2503)
add_station("del_seelampur", "Seelampur", "सीलमपुर", ["red"], 28.6697, 77.2661)
add_station("del_welcome", "Welcome", "वेलकम", ["red", "pink"], 28.6719, 77.2778, is_inter=True)
add_station("del_shahdara", "Shahdara", "शाहदरा", ["red"], 28.6733, 77.2889)
add_station("del_mansarovar_park", "Mansarovar Park", "मानसरोवर पार्क", ["red"], 28.6806, 77.3006)
add_station("del_jhilmil", "Jhilmil", "झिलमिल", ["red"], 28.6819, 77.3117)
add_station("del_dilshad_garden", "Dilshad Garden", "दिलशाद गार्डन", ["red"], 28.6758, 77.3217)
add_station("del_shaheed_nagar", "Shaheed Nagar (Ghaziabad Border)", "शहीद नगर", ["red"], 28.6719, 77.3331)
add_station("del_raj_bagh", "Raj Bagh", "राज बाग़", ["red"], 28.6711, 77.3467)
add_station("del_major_mohit_sharma", "Major Mohit Sharma Rajendra Nagar", "मेजर मोहित शर्मा", ["red"], 28.6706, 77.3606)
add_station("del_shyam_park", "Shyam Park", "श्याम पार्क", ["red"], 28.6703, 77.3736)
add_station("del_mohan_nagar", "Mohan Nagar (World Square Mall)", "मोहन नगर", ["red"], 28.6711, 77.3858)
add_station("del_arthala", "Arthala", "अर्थला", ["red"], 28.6714, 77.3972)
add_station("del_hindon_river", "Hindon River", "हिंडन रिवर", ["red"], 28.6717, 77.4097)
add_station("del_shaheed_sthal", "Shaheed Sthal (New Bus Adda Ghaziabad)", "शहीद स्थल", ["red"], 28.6710, 77.4227)

# 4. GREEN LINE (23 Stations)
add_station("del_ashok_park_main", "Ashok Park Main", "अशोक पार्क मेन", ["green"], 28.6717, 77.1558)
add_station("del_punjabi_bagh", "Punjabi Bagh", "पंजाबी बाग़", ["green"], 28.6714, 77.1436)
add_station("del_punjabi_bagh_west", "Punjabi Bagh West", "पंजाबी बाग़ पश्चिम", ["green", "pink"], 28.6681, 77.1350, is_inter=True)
add_station("del_shivaji_park", "Shivaji Park", "शिवाजी पार्क", ["green"], 28.6697, 77.1264)
add_station("del_madipur", "Madipur", "मादीपुर", ["green"], 28.6711, 77.1169)
add_station("del_paschim_vihar_east", "Paschim Vihar East", "पश्चिम विहार पूर्व", ["green"], 28.6739, 77.1067)
add_station("del_paschim_vihar_west", "Paschim Vihar West", "पश्चिम विहार पश्चिम", ["green"], 28.6769, 77.0967)
add_station("del_peera_garhi", "Peera Garhi (Outer Ring Road)", "पीरागढ़ी", ["green"], 28.6797, 77.0856)
add_station("del_udyog_nagar", "Udyog Nagar", "उद्योग नगर", ["green"], 28.6811, 77.0739)
add_station("del_surajmal_stadium", "Maharaja Surajmal Stadium", "महाराजा सूरजमल स्टेडियम", ["green"], 28.6828, 77.0622)
add_station("del_nangloi", "Nangloi", "नांगलोई", ["green"], 28.6836, 77.0544)
add_station("del_nangloi_railway_station", "Nangloi Railway Station", "नांगलोई रेलवे स्टेशन", ["green"], 28.6833, 77.0425)
add_station("del_rajdhani_park", "Rajdhani Park", "राजधानी पार्क", ["green"], 28.6831, 77.0317)
add_station("del_mundka", "Mundka", "मुंडका", ["green"], 28.6828, 77.0208)
add_station("del_mundka_industrial_area", "Mundka Industrial Area", "मुंडका औद्योगिक क्षेत्र", ["green"], 28.6825, 77.0039)
add_station("del_ghevra_metro", "Ghevra", "घेवरा", ["green"], 28.6839, 76.9817)
add_station("del_tikri_kalan", "Tikri Kalan", "टिकरी कलाँ", ["green"], 28.6869, 76.9622)
add_station("del_tikri_border", "Tikri Border (Delhi-Haryana Border)", "टिकरी बॉर्डर", ["green"], 28.6917, 76.9439)
add_station("del_pandit_shree_ram_sharma", "Pandit Shree Ram Sharma", "पंडित श्री राम शर्मा", ["green"], 28.6928, 76.9317)
add_station("del_bahadurgarh_city", "Bahadurgarh City", "बहादुरगढ़ सिटी", ["green"], 28.6936, 76.9197)
add_station("del_brigadier_hoshiar_singh", "Brigadier Hoshiar Singh (City Park Bahadurgarh)", "ब्रिगेडियर होशियार सिंह", ["green"], 28.6947, 76.9067)

# 5. VIOLET LINE (34 Stations)
add_station("del_lal_quila", "Lal Quila (Red Fort)", "लाल किला", ["violet"], 28.6567, 77.2389)
add_station("del_jama_masjid", "Jama Masjid", "जामा मस्जिद", ["violet"], 28.6508, 77.2369)
add_station("del_delhi_gate", "Delhi Gate (Feroz Shah Kotla Stadium)", "दिल्ली गेट", ["violet"], 28.6417, 77.2406)
add_station("del_ito", "ITO (Police HQ)", "आईटीओ", ["violet"], 28.6303, 77.2408)
add_station("del_janpath", "Janpath", "जनपथ", ["violet"], 28.6208, 77.2189)
add_station("del_khan_market", "Khan Market", "ख़ान मार्केट", ["violet"], 28.6014, 77.2289)
add_station("del_jawaharlal_nehru_stadium", "Jawaharlal Nehru Stadium (JLN)", "जवाहरलाल नेहरू स्टेडियम", ["violet"], 28.5878, 77.2356)
add_station("del_jangpura", "Jangpura", "जंगपुरा", ["violet"], 28.5808, 77.2411)
add_station("del_moolchand", "Moolchand Hospital", "मूलचंद", ["violet"], 28.5653, 77.2342)
add_station("del_kailash_colony", "Kailash Colony", "कैलाश कॉलोनी", ["violet"], 28.5558, 77.2417)
add_station("del_nehru_place", "Nehru Place (IT Market)", "नेहरू प्लेस", ["violet"], 28.5517, 77.2514)
add_station("del_kalkaji_mandir", "Kalkaji Mandir", "कालकाजी मंदिर", ["violet", "magenta"], 28.5503, 77.2608, is_inter=True)
add_station("del_govindpuri", "Govindpuri", "गोविंदपुरी", ["violet"], 28.5447, 77.2647)
add_station("del_harkesh_nagar_okhla", "Harkesh Nagar Okhla", "हरकेश नगर ओखला", ["violet"], 28.5378, 77.2731)
add_station("del_jasola_apollo", "Jasola Apollo Hospital", "जसोला अपोलो", ["violet"], 28.5303, 77.2831)
add_station("del_sarita_vihar", "Sarita Vihar", "सरिता विहार", ["violet"], 28.5286, 77.2947)
add_station("del_mohan_estate", "Mohan Estate", "मोहन एस्टेट", ["violet"], 28.5175, 77.3047)
add_station("del_tughlakabad_station", "Tughlakabad Station", "तुग़लकाबाद स्टेशन", ["violet"], 28.5086, 77.3039)
add_station("del_badarpur_border", "Badarpur Border (Delhi-Faridabad)", "बदरपुर बॉर्डर", ["violet"], 28.4989, 77.3031)
add_station("del_sarai", "Sarai (Faridabad)", "सराय", ["violet"], 28.4819, 77.3075)
add_station("del_nhpc_chowk", "NHPC Chowk", "एनएचपीसी चौक", ["violet"], 28.4686, 77.3097)
add_station("del_mewala_maharajpur", "Mewala Maharajpur", "मेवला महाराजपुर", ["violet"], 28.4553, 77.3117)
add_station("del_sector_28_faridabad", "Sector 28 Faridabad", "सेक्टर 28", ["violet"], 28.4372, 77.3142)
add_station("del_badkal_mor", "Badkal Mor", "बड़खल मोड़", ["violet"], 28.4239, 77.3167)
add_station("del_old_faridabad", "Old Faridabad Railway Station", "ओल्ड फरीदाबाद", ["violet"], 28.4114, 77.3175)
add_station("del_neelam_chowk_ajronda", "Neelam Chowk Ajronda", "नीलम चौक अजरौंदा", ["violet"], 28.3978, 77.3183)
add_station("del_bata_chowk", "Bata Chowk", "बाटा चौक", ["violet"], 28.3844, 77.3197)
add_station("del_escorts_mujesar", "Escorts Mujesar", "एस्कॉर्ट्स मुजेसर", ["violet"], 28.3697, 77.3208)
add_station("del_sant_surdas_sihi", "Sant Surdas (Sihi)", "संत सूरदास", ["violet"], 28.3561, 77.3225)
add_station("del_raja_nahar_singh", "Raja Nahar Singh (Ballabhgarh)", "राजा नाहर सिंह", ["violet"], 28.3414, 77.3244)

# 6. MAGENTA LINE (25 Stations)
add_station("del_dabri_mor_janakpuri_south", "Dabri Mor - Janakpuri South", "डाबरी मोड़ - जनकपुरी दक्षिण", ["magenta"], 28.6186, 77.0872)
add_station("del_dashrath_puri", "Dashrath Puri", "दशरथ पुरी", ["magenta"], 28.6106, 77.0864)
add_station("del_palam", "Palam (Railway Station Link)", "पालम", ["magenta"], 28.5989, 77.0886)
add_station("del_sadaar_bazar_cantonment", "Sadar Bazar Cantonment", "सदर बाज़ार छावनी", ["magenta"], 28.5878, 77.1122)
add_station("del_terminal_1_igi_airport", "Terminal 1 IGI Domestic Airport", "टर्मिनल १ आईजीआई एयरपोर्ट", ["magenta"], 28.5672, 77.1217)
add_station("del_shankar_vihar", "Shankar Vihar", "शंकर विहार", ["magenta"], 28.5653, 77.1389)
add_station("del_vasant_vihar", "Vasant Vihar", "वसंत विहार", ["magenta"], 28.5606, 77.1611)
add_station("del_munirka", "Munirka (JNU North Gate Link)", "मुनीरका", ["magenta"], 28.5578, 77.1736)
add_station("del_rk_puram", "RK Puram Sector 1", "आर के पुरम", ["magenta"], 28.5528, 77.1853)
add_station("del_iit_delhi", "IIT Delhi Gate", "आईआईटी", ["magenta"], 28.5475, 77.1956)
add_station("del_panchsheel_park", "Panchsheel Park", "पंचशील पार्क", ["magenta"], 28.5414, 77.2189)
add_station("del_chirag_delhi", "Chirag Delhi", "चिराग दिल्ली", ["magenta"], 28.5397, 77.2289)
add_station("del_greater_kailash", "Greater Kailash (GK)", "ग्रेटर कैलाश", ["magenta"], 28.5417, 77.2411)
add_station("del_nehru_enclave", "Nehru Enclave", "नेहरू एन्क्लेव", ["magenta"], 28.5458, 77.2517)
add_station("del_okhla_nsic", "Okhla NSIC", "ओखला एनएसआईसी", ["magenta"], 28.5525, 77.2714)
add_station("del_sukhdev_vihar", "Sukhdev Vihar (Fortis Escorts Link)", "सुखदेव विहार", ["magenta"], 28.5608, 77.2797)
add_station("del_jamia_millia_islamia", "Jamia Millia Islamia University", "जामिया मिल्लिया इस्लामिया", ["magenta"], 28.5636, 77.2889)
add_station("del_okhla_vihar", "Okhla Vihar", "ओखला विहार", ["magenta"], 28.5594, 77.2975)
add_station("del_jasola_vihar_shaheen_bagh", "Jasola Vihar Shaheen Bagh", "जसोला विहार शाहीन बाग़", ["magenta"], 28.5489, 77.3047)
add_station("del_kalindi_kunj", "Kalindi Kunj (Yamuna Riverfront)", "कालिंदी कुंज", ["magenta"], 28.5422, 77.3117)
add_station("del_okhla_bird_sanctuary", "Okhla Bird Sanctuary (Noida)", "ओखला पक्षी अभयारण्य", ["magenta"], 28.5508, 77.3242)

# 7. PINK LINE (38 Stations)
add_station("del_majlis_park", "Majlis Park", "मजलिस पार्क", ["pink"], 28.7183, 77.1856)
add_station("del_shalimar_bagh", "Shalimar Bagh", "शालीमार बाग़", ["pink"], 28.7008, 77.1689)
add_station("del_shakurpur", "Shakurpur", "शकूरपुर", ["pink"], 28.6836, 77.1472)
add_station("del_esi_basaidarapur", "ESI Basaidarapur Hospital", "ईएसआई बसईदारापुर", ["pink"], 28.6608, 77.1286)
add_station("del_maya_puri", "Mayapuri", "मायापुरी", ["pink"], 28.6369, 77.1264)
add_station("del_naraina_vihar", "Naraina Vihar", "नारायणा विहार", ["pink"], 28.6267, 77.1389)
add_station("del_delhi_cantt", "Delhi Cantt", "दिल्ली कैंट", ["pink"], 28.6019, 77.1472)
add_station("del_durgabai_deshmukh_south_campus", "Durgabai Deshmukh South Campus (DU South)", "दुर्गाबाई देशमुख साउथ कैंपस", ["pink"], 28.5889, 77.1656)
add_station("del_sir_m_vishweshwaraiah_moti_bagh", "Sir M. Vishweshwaraiah Moti Bagh", "मोती बाग़", ["pink"], 28.5822, 77.1778)
add_station("del_bhikaji_cama_place", "Bhikaji Cama Place", "भीकाजी कामा प्लेस", ["pink"], 28.5714, 77.1906)
add_station("del_sarojini_nagar", "Sarojini Nagar Market", "सरोजिनी नगर", ["pink"], 28.5756, 77.2008)
add_station("del_south_extension", "South Extension (South Ex)", "साउथ एक्सटेंशन", ["pink"], 28.5717, 77.2217)
add_station("del_vinobapuri", "Vinobapuri", "विनोबापुरी", ["pink"], 28.5678, 77.2514)
add_station("del_ashram", "Ashram", "आश्रम", ["pink"], 28.5722, 77.2619)
add_station("del_sarai_kale_khan_hazrat_nizamuddin", "Sarai Kale Khan - Hazrat Nizamuddin Railway", "हज़रत निज़ामुद्दीन", ["pink"], 28.5889, 77.2575)
add_station("del_mayur_vihar_pocket_1", "Mayur Vihar Pocket-1", "मयूर विहार पॉकेट-१", ["pink"], 28.6053, 77.3014)
add_station("del_trilokpuri_sanjay_lake", "Trilokpuri - Sanjay Lake", "त्रिलोकपुरी - संजय झील", ["pink"], 28.6136, 77.3069)
add_station("del_east_vinod_nagar_mayur_vihar_2", "East Vinod Nagar - Mayur Vihar-II", "पूर्वी विनोद नगर", ["pink"], 28.6231, 77.3086)
add_station("del_mandawali_west_vinod_nagar", "Mandawali - West Vinod Nagar", "मंडावली", ["pink"], 28.6308, 77.3075)
add_station("del_ip_extension", "IP Extension", "आईपी एक्सटेंशन", ["pink"], 28.6367, 77.3056)
add_station("del_karkarduma_court", "Karkarduma Court", "कड़कड़डूमा कोर्ट", ["pink"], 28.6536, 77.2975)
add_station("del_krishna_nagar", "Krishna Nagar", "कृष्णा नगर", ["pink"], 28.6597, 77.2897)
add_station("del_east_azad_nagar", "East Azad Nagar", "ईस्ट आज़ाद नगर", ["pink"], 28.6653, 77.2836)
add_station("del_jaffrabad", "Jaffrabad", "जाफ़राबाद", ["pink"], 28.6811, 77.2725)
add_station("del_maujpur_babarpur", "Maujpur - Babarpur", "मौजपुर - बाबरपुर", ["pink"], 28.6886, 77.2731)
add_station("del_gokulpuri", "Gokulpuri", "गोकुलपुरी", ["pink"], 28.6975, 77.2789)
add_station("del_johri_enclave", "Johri Enclave", "जौहरी एन्क्लेव", ["pink"], 28.7061, 77.2867)
add_station("del_shiv_vihar", "Shiv Vihar", "शिव विहार", ["pink"], 28.7153, 77.2961)

# 8. AIRPORT EXPRESS & GREY LINE
add_station("del_shivaji_stadium", "Shivaji Stadium (CP Airport Check-in)", "शिवाजी स्टेडियम", ["airport_express"], 28.6289, 77.2131)
add_station("del_dhaula_kuan", "Dhaula Kuan (Skywalk to South Campus Pink Line)", "धौला कुआँ", ["airport_express"], 28.5925, 77.1611)
add_station("del_delhi_aerocity", "Delhi Aerocity (Hospitality District)", "दिल्ली एरोसिटी", ["airport_express"], 28.5489, 77.1206)
add_station("del_igi_airport_t3", "IGI Airport Terminal 3 (International & Domestic)", "आईजीआई एयरपोर्ट टर्मिनल ३", ["airport_express"], 28.5564, 77.0867)
add_station("del_yashobhoomi_dwarka_sec_25", "Yashobhoomi Dwarka Sector 25 (IICC)", "यशोभूमि द्वारका सेक्टर २५", ["airport_express"], 28.5446, 77.0392)

add_station("del_nangli", "Nangli", "नांगली", ["grey"], 28.6147, 77.0019)
add_station("del_najafgarh", "Najafgarh", "नजफ़गढ़", ["grey"], 28.6139, 76.9856)
add_station("del_dhansa_bus_stand", "Dhansa Bus Stand", "ढांसा बस स्टैंड", ["grey"], 28.6083, 76.9739)

# 9. RAPID METRO GURUGRAM (11 Stations)
add_station("del_rm_sec_55_56", "Sector 55-56 Gurugram", "सेक्टर 55-56", ["rapid_metro"], 28.4239, 77.1086)
add_station("del_rm_sec_54_chowk", "Sector 54 Chowk", "सेक्टर 54 चौक", ["rapid_metro"], 28.4386, 77.1053)
add_station("del_rm_sec_53_54", "Sector 53-54", "सेक्टर 53-54", ["rapid_metro"], 28.4528, 77.1022)
add_station("del_rm_sec_42_43", "Sector 42-43", "सेक्टर 42-43", ["rapid_metro"], 28.4647, 77.0989)
add_station("del_rm_phase_1", "DLF Phase 1", "डीएलएफ फेज़ 1", ["rapid_metro"], 28.4742, 77.0956)
add_station("del_rm_phase_2", "DLF Phase 2", "डीएलएफ फेज़ 2", ["rapid_metro"], 28.4878, 77.0903)
add_station("del_rm_belvedere_towers", "Belvedere Towers", "बेलवेडियर टावर्स", ["rapid_metro"], 28.4947, 77.0897)
add_station("del_rm_cyber_city", "Cyber City (DLF Gateway Tower)", "साइबर सिटी", ["rapid_metro"], 28.4986, 77.0886)
add_station("del_rm_moulsari_avenue", "Moulsari Avenue (Ambience Mall Link)", "मौलसरी एवेन्यू", ["rapid_metro"], 28.5042, 77.0967)
add_station("del_rm_phase_3", "DLF Phase 3", "डीएलएफ फेज़ 3", ["rapid_metro"], 28.4939, 77.1039)

all_stations = list(stations_dict.values())

print(f"Total Unique Delhi NCR & Noida Stations Compiled: {len(all_stations)}")
print(f"Total Lines: {len(lines)}")

# Save to local reference JSON
with open(DELHI_JSON_PATH, 'w', encoding='utf-8') as f:
    json.dump({"lines": lines, "stations": all_stations}, f, indent=2, ensure_ascii=False)

print(f"Saved local file: {DELHI_JSON_PATH}")

# -------------------------------------------------------------
# PUSH ALL 200+ STATIONS TO CLOUD FIRESTORE
# -------------------------------------------------------------
cfg_path = os.path.expanduser('~/.config/configstore/firebase-tools.json')
with open(cfg_path, 'r', encoding='utf-8') as f:
    cfg = json.load(f)
token = cfg.get('tokens', {}).get('access_token')

BASE_URL = 'https://firestore.googleapis.com/v1/projects/metropulse-transit-2026/databases/(default)/documents'

def to_firestore_value(val):
    if val is None:
        return {'nullValue': None}
    elif isinstance(val, bool):
        return {'booleanValue': val}
    elif isinstance(val, int):
        return {'integerValue': str(val)}
    elif isinstance(val, float):
        return {'doubleValue': val}
    elif isinstance(val, str):
        return {'stringValue': val}
    elif isinstance(val, list):
        return {'arrayValue': {'values': [to_firestore_value(v) for v in val]}}
    elif isinstance(val, dict):
        return {'mapValue': {'fields': {k: to_firestore_value(v) for k, v in val.items()}}}
    else:
        return {'stringValue': str(val)}

def set_doc(path, data, cur_token):
    url = f"{BASE_URL}/{path}"
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    body = json.dumps({'fields': fields}).encode('utf-8')
    req = urllib.request.Request(
        url,
        data=body,
        headers={'Authorization': f'Bearer {cur_token}', 'Content-Type': 'application/json'},
        method='PATCH'
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.getcode(), cur_token
    except urllib.error.HTTPError as e:
        if e.code == 401:
            print("Token expired. Refreshing...")
            subprocess.run(['firebase.cmd', 'projects:list'], capture_output=True, text=True, check=True)
            with open(cfg_path, 'r', encoding='utf-8') as f_in:
                new_token = json.load(f_in).get('tokens', {}).get('access_token')
            req2 = urllib.request.Request(
                url,
                data=body,
                headers={'Authorization': f'Bearer {new_token}', 'Content-Type': 'application/json'},
                method='PATCH'
            )
            with urllib.request.urlopen(req2) as resp2:
                return resp2.getcode(), new_token
        else:
            print(f"Error {path}: {e.code} {e.read().decode()[:150]}")
            return e.code, cur_token

print(f"\nPushing all {len(lines)} lines to Firestore...")
for l in lines:
    status, token = set_doc(f"lines/{l['id']}", l, token)

print(f"Pushing all {len(all_stations)} stations to Firestore...")
success_count = 0
for idx, s in enumerate(all_stations):
    status, token = set_doc(f"stations/{s['id']}", s, token)
    if status == 200:
        success_count += 1
    if (idx + 1) % 30 == 0 or idx == len(all_stations) - 1:
        print(f"  Progress: {idx + 1}/{len(all_stations)} stations pushed...")

print(f"\nDONE! Pushed {success_count}/{len(all_stations)} stations to Firestore!")
