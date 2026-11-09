import json
import os
import sys
import urllib.request
import urllib.error

# Output directory for reference files
DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'data', 'production'))
os.makedirs(DATA_DIR, exist_ok=True)

print(f"Generating production dataset in: {DATA_DIR}")

# -------------------------------------------------------------
# 1. CITIES DATASET
# -------------------------------------------------------------
cities = [
    {
        "id": "delhi_ncr",
        "name": "Delhi NCR Metro",
        "stateOrCountry": "Delhi / Noida / Gurugram / Ghaziabad / Faridabad",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://www.dmrcsmartcard.com/",
        "centerLatitude": 28.6139,
        "centerLongitude": 77.2090,
        "operator": "Delhi Metro Rail Corporation (DMRC) / NMRC / Rapid Metro",
        "totalLines": 12,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "mumbai",
        "name": "Mumbai Metro",
        "stateOrCountry": "Maharashtra",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://www.reliancemumbaimetro.com/recharge.html",
        "centerLatitude": 19.0760,
        "centerLongitude": 72.8777,
        "operator": "MMRDA / MMMOCL / MMOPL / MMRC",
        "totalLines": 4,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "bengaluru",
        "name": "Bengaluru Namma Metro",
        "stateOrCountry": "Karnataka",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://english.bmrc.co.in/",
        "centerLatitude": 12.9716,
        "centerLongitude": 77.5946,
        "operator": "Bangalore Metro Rail Corporation Limited (BMRCL)",
        "totalLines": 3,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "hyderabad",
        "name": "Hyderabad Metro",
        "stateOrCountry": "Telangana",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://www.ltmetro.com/",
        "centerLatitude": 17.3850,
        "centerLongitude": 78.4867,
        "operator": "L&T Metro Rail (Hyderabad) Limited",
        "totalLines": 3,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "kolkata",
        "name": "Kolkata Metro",
        "stateOrCountry": "West Bengal",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://mtp.indianrailways.gov.in/",
        "centerLatitude": 22.5726,
        "centerLongitude": 88.3639,
        "operator": "Metro Railway Kolkata (Indian Railways)",
        "totalLines": 4,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "chennai",
        "name": "Chennai Metro",
        "stateOrCountry": "Tamil Nadu",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://chennaimetrorail.org/",
        "centerLatitude": 13.0827,
        "centerLongitude": 80.2707,
        "operator": "Chennai Metro Rail Limited (CMRL)",
        "totalLines": 2,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "pune",
        "name": "Pune Metro",
        "stateOrCountry": "Maharashtra",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://www.punemetrorail.org/",
        "centerLatitude": 18.5204,
        "centerLongitude": 73.8567,
        "operator": "Maha Metro (Pune)",
        "totalLines": 2,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "ahmedabad",
        "name": "Ahmedabad Metro",
        "stateOrCountry": "Gujarat",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://www.gujaratmetrorail.com/",
        "centerLatitude": 23.0225,
        "centerLongitude": 72.5714,
        "operator": "Gujarat Metro Rail Corporation (GMRC)",
        "totalLines": 2,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "kochi",
        "name": "Kochi Metro",
        "stateOrCountry": "Kerala",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://kochimetro.org/",
        "centerLatitude": 9.9312,
        "centerLongitude": 76.2673,
        "operator": "Kochi Metro Rail Limited (KMRL)",
        "totalLines": 1,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "jaipur",
        "name": "Jaipur Metro",
        "stateOrCountry": "Rajasthan",
        "currencySymbol": "₹",
        "country": "India",
        "isInternational": False,
        "rechargeUrl": "https://transport.rajasthan.gov.in/jmrc",
        "centerLatitude": 26.9124,
        "centerLongitude": 75.7873,
        "operator": "Jaipur Metro Rail Corporation (JMRC)",
        "totalLines": 1,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "dubai",
        "name": "Dubai Metro",
        "stateOrCountry": "United Arab Emirates",
        "currencySymbol": "AED",
        "country": "UAE",
        "isInternational": True,
        "rechargeUrl": "https://www.rta.ae/wps/portal/rta/ae/home/top-up-nol-card",
        "centerLatitude": 25.2048,
        "centerLongitude": 55.2708,
        "operator": "Roads and Transport Authority (RTA Dubai)",
        "totalLines": 2,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "singapore",
        "name": "Singapore MRT",
        "stateOrCountry": "Singapore",
        "currencySymbol": "S$",
        "country": "Singapore",
        "isInternational": True,
        "rechargeUrl": "https://www.simplygo.com.sg/",
        "centerLatitude": 1.3521,
        "centerLongitude": 103.8198,
        "operator": "SMRT / SBS Transit / LTA",
        "totalLines": 6,
        "verifiedDate": "2026-11-09"
    },
    {
        "id": "london",
        "name": "London Underground",
        "stateOrCountry": "United Kingdom",
        "currencySymbol": "£",
        "country": "UK",
        "isInternational": True,
        "rechargeUrl": "https://oyster.tfl.gov.uk/oyster/entry.do",
        "centerLatitude": 51.5074,
        "centerLongitude": -0.1278,
        "operator": "Transport for London (TfL)",
        "totalLines": 11,
        "verifiedDate": "2026-11-09"
    }
]

with open(os.path.join(DATA_DIR, 'cities_production.json'), 'w', encoding='utf-8') as f:
    json.dump(cities, f, indent=2, ensure_ascii=False)

# -------------------------------------------------------------
# 2. DELHI NCR METRO PRODUCTION DATASET
# -------------------------------------------------------------
delhi_lines = [
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
            "del_adarsh_nagar", "del_azadpur", "del_model_town", "del_guru_tegh_bahadur_nagar",
            "del_vishwa_vidyalaya", "del_vidhan_sabha", "del_civil_lines", "del_kashmere_gate",
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
        "name": "Blue Line (Dwarka - Noida Electronic City)",
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
        "name": "Blue Line Branch (Yamuna Bank - Vaishali)",
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
        "name": "Red Line (Rithala - Shaheed Sthal)",
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
        "id": "violet",
        "cityId": "delhi_ncr",
        "name": "Violet Line (Kashmere Gate - Raja Nahar Singh)",
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
            "del_nhpc_chowk", "del_mewala_maharajpur", "del_sector_28", "del_badkal_mor",
            "del_old_faridabad", "del_neelam_chowk_ajronda", "del_bata_chowk", "del_escorts_mujesar",
            "del_sant_surdas_sihi", "del_raja_nahar_singh"
        ]
    },
    {
        "id": "magenta",
        "cityId": "delhi_ncr",
        "name": "Magenta Line (Janakpuri West - Botanical Garden)",
        "code": "MG",
        "colorHex": "#D81B60",
        "firstTrain": "05:40 AM",
        "lastTrain": "11:20 PM",
        "frequencyMinutes": 4,
        "startStationName": "Janakpuri West",
        "endStationName": "Botanical Garden",
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
        "id": "pink",
        "cityId": "delhi_ncr",
        "name": "Pink Line (Majlis Park - Shiv Vihar Ring)",
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
        "id": "airport_express",
        "cityId": "delhi_ncr",
        "name": "Airport Express Line (Orange Line)",
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
            "del_noida_sec_81", "del_nse_z", "del_noida_sec_83", "del_noida_sec_137",
            "del_noida_sec_142", "del_noida_sec_143", "del_noida_sec_144", "del_noida_sec_145",
            "del_noida_sec_146", "del_noida_sec_147", "del_noida_sec_148", "del_knowledge_park_2",
            "del_pari_chowk", "del_alpha_1", "del_delta_1", "del_gnida_office", "del_depot_station"
        ]
    }
]

# Production Station Database Generator with full amenities, gates and geo coords
delhi_stations = [
    {
        "id": "del_rajiv_chowk",
        "cityId": "delhi_ncr",
        "name": "Rajiv Chowk (Connaught Place)",
        "hindiName": "राजीव चौक",
        "lineIds": ["yellow", "blue"],
        "isInterchange": True,
        "latitude": 28.6328,
        "longitude": 77.2197,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Radial Road 1, Block B, CP Inner Circle", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "PVR Plaza, Block C, Inner Circle", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Block D, Regal Cinema, Janpath", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Block E, Barakhamba Road Exit", "accessible": True},
            {"gateNumber": "Gate 5", "landmark": "Block F, Kasturba Gandhi Marg", "accessible": False},
            {"gateNumber": "Gate 6", "landmark": "Radial Road 6, Chelmsford Road", "accessible": True},
            {"gateNumber": "Gate 7", "landmark": "Radial Road 7, Middle Circle Exit", "accessible": True},
            {"gateNumber": "Gate 8", "landmark": "Block A, Odeon Cinema, Inner Circle", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1: Millennium City Centre Gurugram | Platform 2: Samaypur Badli",
            "blue": "Platform 3: Noida Electronic City / Vaishali | Platform 4: Dwarka Sector 21"
        }
    },
    {
        "id": "del_kashmere_gate",
        "cityId": "delhi_ncr",
        "name": "Kashmere Gate ISBT",
        "hindiName": "कश्मीरी गेट",
        "lineIds": ["red", "yellow", "violet"],
        "isInterchange": True,
        "latitude": 28.6675,
        "longitude": 77.2285,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "ISBT Interstate Bus Terminus Departure", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Mori Gate & Lala Hardev Sahai Market", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Lothian Road & GPO Kashmere Gate", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Sham Nath Marg & MCD Office", "accessible": True},
            {"gateNumber": "Gate 5", "landmark": "Yamuna Bazar & Ring Road Bypass", "accessible": False},
            {"gateNumber": "Gate 6", "landmark": "St. James Church & Ambedkar University", "accessible": True},
            {"gateNumber": "Gate 7", "landmark": "City Bus Terminus Maharana Pratap", "accessible": True}
        ],
        "platformDirections": {
            "red": "Platform 1: Shaheed Sthal (Ghaziabad) | Platform 2: Rithala",
            "yellow": "Platform 3: Millennium City Centre Gurugram | Platform 4: Samaypur Badli",
            "violet": "Platform 5: Raja Nahar Singh (Ballabhgarh)"
        }
    },
    {
        "id": "del_new_delhi",
        "cityId": "delhi_ncr",
        "name": "New Delhi Railway Station",
        "hindiName": "नई दिल्ली",
        "lineIds": ["yellow", "airport_express"],
        "isInterchange": True,
        "latitude": 28.6431,
        "longitude": 77.2223,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Ajmeri Gate Exit & Skywalk to Platform 16", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Bhavbhuti Marg & DTC Terminal", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Airport Express Dedicated Check-in Lounge", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1: Millennium City Centre Gurugram | Platform 2: Samaypur Badli",
            "airport_express": "Platform 1: Yashobhoomi Dwarka Sector 25 via IGI Airport T3"
        }
    },
    {
        "id": "del_central_secretariat",
        "cityId": "delhi_ncr",
        "name": "Central Secretariat",
        "hindiName": "केंद्रीय सचिवालय",
        "lineIds": ["yellow", "violet"],
        "isInterchange": True,
        "latitude": 28.6147,
        "longitude": 77.2119,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Krishi Bhawan & Rajpath", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Shastri Bhawan & Dr. Rajendra Prasad Road", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Rail Bhawan & Parliament Street", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Udyog Bhawan Crossing", "accessible": True},
            {"gateNumber": "Gate 5", "landmark": "National Archives & Janpath", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1: Millennium City Centre Gurugram | Platform 2: Samaypur Badli",
            "violet": "Platform 3: Raja Nahar Singh | Platform 4: Kashmere Gate"
        }
    },
    {
        "id": "del_hauz_khas",
        "cityId": "delhi_ncr",
        "name": "Hauz Khas",
        "hindiName": "हौज़ ख़ास",
        "lineIds": ["yellow", "magenta"],
        "isInterchange": True,
        "latitude": 28.5431,
        "longitude": 77.2065,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Aurobindo Marg & IIT Delhi Gate", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Hauz Khas Village & Deer Park", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "NIFT Delhi & Laxman Public School", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Sarvapriya Vihar & Kalu Sarai", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1: Millennium City Centre Gurugram | Platform 2: Samaypur Badli",
            "magenta": "Platform 3: Botanical Garden | Platform 4: Janakpuri West"
        }
    },
    {
        "id": "del_botanical_garden",
        "cityId": "delhi_ncr",
        "name": "Botanical Garden (Noida)",
        "hindiName": "बॉटनिकल गार्डन",
        "lineIds": ["blue", "magenta"],
        "isInterchange": True,
        "latitude": 28.5641,
        "longitude": 77.3342,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Captain Shashi Kant Marg & Amity Bus Stop", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Noida Golf Course & Sector 38", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Chhatrapati Shivaji Maharaj Marg & Atta Market", "accessible": True}
        ],
        "platformDirections": {
            "blue": "Platform 1: Noida Electronic City | Platform 2: Dwarka Sector 21",
            "magenta": "Platform 3 & 4: Janakpuri West via IGI Airport T1"
        }
    },
    {
        "id": "del_janakpuri_west",
        "cityId": "delhi_ncr",
        "name": "Janakpuri West",
        "hindiName": "जनकपुरी पश्चिम",
        "lineIds": ["blue", "magenta"],
        "isInterchange": True,
        "latitude": 28.6294,
        "longitude": 77.0778,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Janakpuri District Centre & Westend Mall", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Najafgarh Road & Shivaji College", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Unity One Mall & Janakpuri Flyover", "accessible": True}
        ],
        "platformDirections": {
            "blue": "Platform 1: Noida Electronic City / Vaishali | Platform 2: Dwarka Sector 21",
            "magenta": "Platform 3 & 4: Botanical Garden via Hauz Khas & T1 Airport"
        }
    },
    {
        "id": "del_dilli_haat_ina",
        "cityId": "delhi_ncr",
        "name": "Dilli Haat - INA",
        "hindiName": "दिल्ली हाट - आईएनए",
        "lineIds": ["yellow", "pink"],
        "isInterchange": True,
        "latitude": 28.5744,
        "longitude": 77.2098,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "INA Market & Vikas Sadan (DDA HQ)", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Dilli Haat Craft Market Entrance", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "AIIMS Trauma Centre & Safdarjung Hospital", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Kidwai Nagar East Housing Complex", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1: Millennium City Centre Gurugram | Platform 2: Samaypur Badli",
            "pink": "Platform 3: Shiv Vihar | Platform 4: Majlis Park"
        }
    },
    {
        "id": "del_lajpat_nagar",
        "cityId": "delhi_ncr",
        "name": "Lajpat Nagar",
        "hindiName": "लाजपत नगर",
        "lineIds": ["violet", "pink"],
        "isInterchange": True,
        "latitude": 28.5707,
        "longitude": 77.2374,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Central Market Lajpat Nagar 2", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Vinoba Puri & Lala Lajpat Rai Marg", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Defence Colony Flyover & Ring Road", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Metro Walkway & Amar Colony", "accessible": True}
        ],
        "platformDirections": {
            "violet": "Platform 1: Raja Nahar Singh | Platform 2: Kashmere Gate",
            "pink": "Platform 3: Shiv Vihar | Platform 4: Majlis Park"
        }
    },
    {
        "id": "del_dwarka_sec_21",
        "cityId": "delhi_ncr",
        "name": "Dwarka Sector 21",
        "hindiName": "द्वारका सेक्टर 21",
        "lineIds": ["blue", "airport_express"],
        "isInterchange": True,
        "latitude": 28.5522,
        "longitude": 77.0583,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Pacific D21 Mall Entrance", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Sector 21 DDA Flats & Dwarka Expressway", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Airport Line Concourse & Kiss-and-Ride", "accessible": True}
        ],
        "platformDirections": {
            "blue": "Platform 1 & 2: Noida Electronic City / Vaishali",
            "airport_express": "Platform 3: New Delhi Railway Station | Platform 4: Yashobhoomi Dwarka Sec 25"
        }
    },
    {
        "id": "del_anand_vihar_isbt",
        "cityId": "delhi_ncr",
        "name": "Anand Vihar ISBT & Railway Station",
        "hindiName": "आनंद विहार",
        "lineIds": ["blue_vaishali", "pink"],
        "isInterchange": True,
        "latitude": 28.6475,
        "longitude": 77.3156,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Swami Vivekananda ISBT Bus Concourse", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Anand Vihar Terminal Railway Station Foot Overbridge", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Kaushambi Border Road", "accessible": True}
        ],
        "platformDirections": {
            "blue_vaishali": "Platform 1: Vaishali | Platform 2: Yamuna Bank / Dwarka Sec 21",
            "pink": "Platform 3: Shiv Vihar | Platform 4: Majlis Park"
        }
    },
    {
        "id": "del_sikanderpur",
        "cityId": "delhi_ncr",
        "name": "Sikanderpur (Gurugram)",
        "hindiName": "सिकंदरपुर",
        "lineIds": ["yellow", "rapid_metro"],
        "isInterchange": True,
        "latitude": 28.4817,
        "longitude": 77.0928,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "MG Road & Grand Mall", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Rapid Metro 90m Footbridge Link", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Cyber City & DLF Phase 2", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1: Millennium City Centre Gurugram | Platform 2: Samaypur Badli",
            "rapid_metro": "Platform 1: Cyber City Loop | Platform 2: Sector 55-56"
        }
    },
    {
        "id": "del_noida_sec_52",
        "cityId": "delhi_ncr",
        "name": "Noida Sector 52 (NMRC Walkway)",
        "hindiName": "नोएडा सेक्टर 52",
        "lineIds": ["blue"],
        "isInterchange": True,
        "latitude": 28.5833,
        "longitude": 77.3712,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Capt. Shashikant Sharma Marg & Sec 51 Aqua Line E-Rickshaw Path", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Sector 52 Hoshiyarpur Village & Market", "accessible": True}
        ],
        "platformDirections": {
            "blue": "Platform 1: Noida Electronic City | Platform 2: Dwarka Sector 21"
        }
    },
    {
        "id": "del_noida_sec_51",
        "cityId": "delhi_ncr",
        "name": "Noida Sector 51 (Aqua Line)",
        "hindiName": "नोएडा सेक्टर 51",
        "lineIds": ["aqua_noida"],
        "isInterchange": True,
        "latitude": 28.5847,
        "longitude": 77.3739,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Dedicated Pathway to Blue Line Sector 52", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Kendriya Vihar & Sector 51 Housing", "accessible": True}
        ],
        "platformDirections": {
            "aqua_noida": "Platform 1: Depot Station Greater Noida via Pari Chowk"
        }
    },
    {
        "id": "del_millennium_city_centre",
        "cityId": "delhi_ncr",
        "name": "Millennium City Centre Gurugram (HUDA)",
        "hindiName": "मिलेनियम सिटी सेंटर गुरुग्राम",
        "lineIds": ["yellow"],
        "isInterchange": False,
        "latitude": 28.4593,
        "longitude": 77.0726,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Fortis Memorial Research Institute & Signature Tower", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Max Hospital & HUDA City Centre Ground", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "Unitech Cyber Park & Sector 29 Food Street", "accessible": True},
            {"gateNumber": "Gate 4", "landmark": "Appu Ghar Water Park & Kingdom of Dreams", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1 & 2: Samaypur Badli via Rajiv Chowk"
        }
    },
    {
        "id": "del_samaypur_badli",
        "cityId": "delhi_ncr",
        "name": "Samaypur Badli",
        "hindiName": "समयपुर बादली",
        "lineIds": ["yellow"],
        "isInterchange": False,
        "latitude": 28.7456,
        "longitude": 77.1350,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Badli Railway Station Footbridge", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Samaypur Industrial Area", "accessible": True}
        ],
        "platformDirections": {
            "yellow": "Platform 1 & 2: Millennium City Centre Gurugram"
        }
    },
    {
        "id": "del_noida_electronic_city",
        "cityId": "delhi_ncr",
        "name": "Noida Electronic City",
        "hindiName": "नोएडा इलेक्ट्रॉनिक सिटी",
        "lineIds": ["blue"],
        "isInterchange": False,
        "latitude": 28.6277,
        "longitude": 77.3734,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "NH-24 / Delhi-Meerut Expressway", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Sector 62 IT Park & Indirapuram Ghaziabad", "accessible": True}
        ],
        "platformDirections": {
            "blue": "Platform 1 & 2: Dwarka Sector 21"
        }
    },
    {
        "id": "del_shaheed_sthal",
        "cityId": "delhi_ncr",
        "name": "Shaheed Sthal (New Bus Adda Ghaziabad)",
        "hindiName": "शहीद स्थल",
        "lineIds": ["red"],
        "isInterchange": False,
        "latitude": 28.6710,
        "longitude": 77.4227,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Ghaziabad Old Bus Stand & GT Road", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Chaudhary Charan Singh Park", "accessible": True}
        ],
        "platformDirections": {
            "red": "Platform 1 & 2: Rithala via Kashmere Gate"
        }
    },
    {
        "id": "del_rithala",
        "cityId": "delhi_ncr",
        "name": "Rithala",
        "hindiName": "रिठाला",
        "lineIds": ["red"],
        "isInterchange": False,
        "latitude": 28.7208,
        "longitude": 77.1071,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Sector 5 Rohini & Metro Walk Mall", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Rithala Village & Japanese Park", "accessible": True}
        ],
        "platformDirections": {
            "red": "Platform 1 & 2: Shaheed Sthal (New Bus Adda)"
        }
    },
    {
        "id": "del_raja_nahar_singh",
        "cityId": "delhi_ncr",
        "name": "Raja Nahar Singh (Ballabhgarh)",
        "hindiName": "राजा नाहर सिंह",
        "lineIds": ["violet"],
        "isInterchange": False,
        "latitude": 28.3414,
        "longitude": 77.3244,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Ballabhgarh Railway Station & Bus Stand", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Mathura Road NH-19", "accessible": True}
        ],
        "platformDirections": {
            "violet": "Platform 1 & 2: Kashmere Gate"
        }
    },
    {
        "id": "del_yashobhoomi_dwarka_sec_25",
        "cityId": "delhi_ncr",
        "name": "Yashobhoomi Dwarka Sector 25",
        "hindiName": "यशोभूमि द्वारका सेक्टर 25",
        "lineIds": ["airport_express"],
        "isInterchange": False,
        "latitude": 28.5446,
        "longitude": 77.0392,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "India International Convention & Expo Centre (IICC)", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Dwarka Expressway Link & Sector 25", "accessible": True}
        ],
        "platformDirections": {
            "airport_express": "Platform 1 & 2: New Delhi Railway Station via IGI Airport T3"
        }
    }
]

with open(os.path.join(DATA_DIR, 'delhi_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": delhi_lines, "stations": delhi_stations}, f, indent=2, ensure_ascii=False)

# -------------------------------------------------------------
# 3. MUMBAI METRO PRODUCTION DATASET
# -------------------------------------------------------------
mumbai_lines = [
    {
        "id": "mum_line_1",
        "cityId": "mumbai",
        "name": "Line 1 (Blue Line: Versova - Andheri - Ghatkopar)",
        "code": "L1",
        "colorHex": "#1E88E5",
        "firstTrain": "05:30 AM",
        "lastTrain": "11:50 PM",
        "frequencyMinutes": 4,
        "startStationName": "Versova",
        "endStationName": "Ghatkopar",
        "stationIds": [
            "mum_versova", "mum_dn_nagar", "mum_azad_nagar", "mum_andheri",
            "mum_western_express_highway", "mum_chakala", "mum_airport_road", "mum_marol_naka",
            "mum_saki_naka", "mum_asalpha", "mum_jagruti_nagar", "mum_ghatkopar"
        ]
    },
    {
        "id": "mum_line_2a",
        "cityId": "mumbai",
        "name": "Line 2A (Yellow Line: Dahisar East - Andheri West)",
        "code": "L2A",
        "colorHex": "#FDD835",
        "firstTrain": "05:55 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 6,
        "startStationName": "Dahisar East",
        "endStationName": "Andheri West (DN Nagar)",
        "stationIds": [
            "mum_dahisar_east", "mum_anand_nagar", "mum_kanderpada", "mum_mandapeshwar",
            "mum_eksar", "mum_borivali_west", "mum_pahadi_eksar", "mum_kandivali_west",
            "mum_dahanukarwadi", "mum_valnai", "mum_malad_west", "mum_lower_malad",
            "mum_pahadi_goregaon", "mum_goregaon_west", "mum_oshiwara", "mum_lower_oshiwara",
            "mum_andheri_west"
        ]
    },
    {
        "id": "mum_line_7",
        "cityId": "mumbai",
        "name": "Line 7 (Red Line: Dahisar East - Gundavali)",
        "code": "L7",
        "colorHex": "#E53935",
        "firstTrain": "05:58 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 6,
        "startStationName": "Dahisar East",
        "endStationName": "Gundavali (Andheri East)",
        "stationIds": [
            "mum_dahisar_east", "mum_ovari_pada", "mum_national_park", "mum_devipada",
            "mum_magathane", "mum_poisar", "mum_akrli", "mum_kurar",
            "mum_dindoshi", "mum_aarey", "mum_goregaon_east", "mum_jogeshwari_east",
            "mum_mogra", "mum_gundavali"
        ]
    },
    {
        "id": "mum_line_3",
        "cityId": "mumbai",
        "name": "Line 3 (Aqua Line: Aarey JVLR - BKC Phase 1)",
        "code": "L3",
        "colorHex": "#00ACC1",
        "firstTrain": "05:55 AM",
        "lastTrain": "10:30 PM",
        "frequencyMinutes": 7,
        "startStationName": "Aarey JVLR",
        "endStationName": "Bandra Kurla Complex (BKC)",
        "stationIds": [
            "mum_aarey_jvlr", "mum_seepz", "mum_midc_andheri", "mum_marol_naka_l3",
            "mum_csmia_t2", "mum_sahar_road", "mum_csmia_t1", "mum_santacruz",
            "mum_vidyanagari", "mum_bkc"
        ]
    }
]

mumbai_stations = [
    {
        "id": "mum_andheri",
        "cityId": "mumbai",
        "name": "Andheri Metro (Western Railway Interchange)",
        "hindiName": "अंधेरी",
        "lineIds": ["mum_line_1"],
        "isInterchange": True,
        "latitude": 19.1197,
        "longitude": 72.8464,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Andheri Railway Station Skywalk Foot Overbridge", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "SV Road & Andheri Market", "accessible": True}
        ],
        "platformDirections": {
            "mum_line_1": "Platform 1: Ghatkopar | Platform 2: Versova"
        }
    },
    {
        "id": "mum_ghatkopar",
        "cityId": "mumbai",
        "name": "Ghatkopar Metro (Central Railway Interchange)",
        "hindiName": "घाटकोपर",
        "lineIds": ["mum_line_1"],
        "isInterchange": True,
        "latitude": 19.0860,
        "longitude": 72.9080,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Central Railway Suburban Platforms 1-4 Link", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "LBS Marg & Ghatkopar West", "accessible": True}
        ],
        "platformDirections": {
            "mum_line_1": "Platform 1 & 2: Versova via Andheri"
        }
    },
    {
        "id": "mum_marol_naka",
        "cityId": "mumbai",
        "name": "Marol Naka (Line 1 & Line 3 Interchange)",
        "hindiName": "मरोल नाका",
        "lineIds": ["mum_line_1", "mum_line_3"],
        "isInterchange": True,
        "latitude": 19.1118,
        "longitude": 72.8824,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Andheri-Kurla Road", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Line 3 Underground Inter-Concourse Passage", "accessible": True}
        ],
        "platformDirections": {
            "mum_line_1": "Platform 1: Ghatkopar | Platform 2: Versova",
            "mum_line_3": "Platform 3: BKC | Platform 4: Aarey JVLR"
        }
    },
    {
        "id": "mum_dahisar_east",
        "cityId": "mumbai",
        "name": "Dahisar East (Line 2A & Line 7 Interchange)",
        "hindiName": "दहिसर पूर्व",
        "lineIds": ["mum_line_2a", "mum_line_7"],
        "isInterchange": True,
        "latitude": 19.2559,
        "longitude": 72.8687,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Western Express Highway", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Link Road & Dahisar Check Naka", "accessible": True}
        ],
        "platformDirections": {
            "mum_line_2a": "Platform 1: Andheri West (DN Nagar)",
            "mum_line_7": "Platform 2: Gundavali (Andheri East)"
        }
    },
    {
        "id": "mum_bkc",
        "cityId": "mumbai",
        "name": "Bandra Kurla Complex (BKC)",
        "hindiName": "बांद्रा कुर्ला संकुल (बीकेसी)",
        "lineIds": ["mum_line_3"],
        "isInterchange": False,
        "latitude": 19.0657,
        "longitude": 72.8689,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "MMRDA Grounds & Jio World Centre", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "NSE National Stock Exchange & ICICI Tower", "accessible": True}
        ],
        "platformDirections": {
            "mum_line_3": "Platform 1 & 2: Aarey JVLR via CSMIA Airport T2"
        }
    }
]

with open(os.path.join(DATA_DIR, 'mumbai_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": mumbai_lines, "stations": mumbai_stations}, f, indent=2, ensure_ascii=False)

# -------------------------------------------------------------
# 4. BENGALURU NAMMA METRO PRODUCTION DATASET
# -------------------------------------------------------------
blr_lines = [
    {
        "id": "blr_purple",
        "cityId": "bengaluru",
        "name": "Purple Line (Challaghatta - Whitefield Kadugodi)",
        "code": "PL",
        "colorHex": "#7B1FA2",
        "firstTrain": "05:00 AM",
        "lastTrain": "11:05 PM",
        "frequencyMinutes": 5,
        "startStationName": "Challaghatta",
        "endStationName": "Whitefield (Kadugodi)",
        "stationIds": [
            "blr_challaghatta", "blr_kengeri", "blr_mysore_road", "blr_deepanjali_nagar",
            "blr_attiguppe", "blr_vijayanagar", "blr_hosahalli", "blr_majestic",
            "blr_kr_market", "blr_vidhana_soudha", "blr_cubbon_park", "blr_mg_road",
            "blr_trinity", "blr_halasuru", "blr_indiranagar", "blr_swami_vivekananda_road",
            "blr_baiyappanahalli", "blr_benniganahalli", "blr_kr_puram", "blr_singayyanapalya",
            "blr_garudacharpalya", "blr_hoodi", "blr_seetharampalya", "blr_kundalahalli",
            "blr_nallurhalli", "blr_sathya_sai_hospital", "blr_pattandur_agrahara", "blr_kadugodi_tree_park",
            "blr_hopefarm_channasandra", "blr_whitefield"
        ]
    },
    {
        "id": "blr_green",
        "cityId": "bengaluru",
        "name": "Green Line (Madavara BIEC - Silk Institute)",
        "code": "GL",
        "colorHex": "#388E3C",
        "firstTrain": "05:00 AM",
        "lastTrain": "11:05 PM",
        "frequencyMinutes": 6,
        "startStationName": "Madavara (BIEC)",
        "endStationName": "Silk Institute",
        "stationIds": [
            "blr_madavara", "blr_nagasandra", "blr_dasarahalli", "blr_jalahalli",
            "blr_peenya_industry", "blr_peenya", "blr_goraguntepalya", "blr_yeshwanthpur",
            "blr_sandal_soap_factory", "blr_mahalakshmi", "blr_rajajinagar", "blr_kuvempu_road",
            "blr_srirampura", "blr_sampige_road", "blr_majestic", "blr_chickpete",
            "blr_kr_market", "blr_national_college", "blr_lalbagh", "blr_south_end_circle",
            "blr_jayanagar", "blr_rashtreeya_vidyalaya_road", "blr_banashankari", "blr_jaya_prakash_nagar",
            "blr_yelachenahalli", "blr_konanakunte_cross", "blr_doddakallasandra", "blr_vajarahalli",
            "blr_thalaghattapura", "blr_silk_institute"
        ]
    }
]

blr_stations = [
    {
        "id": "blr_majestic",
        "cityId": "bengaluru",
        "name": "Nadaprabhu Kempegowda Majestic (Interchange)",
        "hindiName": "केम्पेगौड़ा मैजेस्टिक",
        "lineIds": ["blr_purple", "blr_green"],
        "isInterchange": True,
        "latitude": 12.9757,
        "longitude": 77.5728,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "KSR Bengaluru City Railway Station Footbridge", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "BMTC City Bus Stand", "accessible": True},
            {"gateNumber": "Gate 3", "landmark": "KSRTC Inter-city Kempegowda Bus Station", "accessible": True}
        ],
        "platformDirections": {
            "blr_purple": "Platform 1: Whitefield (Kadugodi) | Platform 2: Challaghatta",
            "blr_green": "Platform 3: Silk Institute | Platform 4: Madavara (BIEC)"
        }
    },
    {
        "id": "blr_whitefield",
        "cityId": "bengaluru",
        "name": "Whitefield (Kadugodi)",
        "hindiName": "व्हाइटफ़ील्ड",
        "lineIds": ["blr_purple"],
        "isInterchange": False,
        "latitude": 12.9964,
        "longitude": 77.7612,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Whitefield Railway Station Link", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Kadugodi Bus Stand", "accessible": True}
        ],
        "platformDirections": {
            "blr_purple": "Platform 1 & 2: Challaghatta via Majestic"
        }
    },
    {
        "id": "blr_mg_road",
        "cityId": "bengaluru",
        "name": "Mahatma Gandhi Road (MG Road)",
        "hindiName": "एम जी रोड",
        "lineIds": ["blr_purple"],
        "isInterchange": False,
        "latitude": 12.9755,
        "longitude": 77.6066,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Brigade Road & Church Street", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "MG Road Boulevard & 1 MG-Lido Mall", "accessible": True}
        ],
        "platformDirections": {
            "blr_purple": "Platform 1: Whitefield | Platform 2: Challaghatta"
        }
    }
]

with open(os.path.join(DATA_DIR, 'bengaluru_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": blr_lines, "stations": blr_stations}, f, indent=2, ensure_ascii=False)

# -------------------------------------------------------------
# 5. KOLKATA METRO PRODUCTION DATASET
# -------------------------------------------------------------
kolkata_lines = [
    {
        "id": "kol_blue",
        "cityId": "kolkata",
        "name": "Blue Line (Line 1: Dakshineswar - Kavi Subhash)",
        "code": "L1",
        "colorHex": "#1E88E5",
        "firstTrain": "06:55 AM",
        "lastTrain": "09:40 PM",
        "frequencyMinutes": 6,
        "startStationName": "Dakshineswar",
        "endStationName": "Kavi Subhash (New Garia)",
        "stationIds": [
            "kol_dakshineswar", "kol_baranagar", "kol_noapara", "kol_dum_dum",
            "kol_belgachia", "kol_shyambazar", "kol_shovabazar", "kol_girish_park",
            "kol_mahatma_gandhi_road", "kol_central", "kol_chandni_chowk", "kol_esplanade",
            "kol_park_street", "kol_maidan", "kol_netaji_bhavan", "kol_jatin_das_park",
            "kol_kalighat", "kol_rabindra_sarobar", "kol_mahanayak_uttam_kumar", "kol_netaji",
            "kol_masterda_surya_sen", "kol_gitanjali", "kol_kavi_nazrul", "kol_shahid_khudiram",
            "kol_kavi_subhash"
        ]
    },
    {
        "id": "kol_green",
        "cityId": "kolkata",
        "name": "Green Line (Line 2: Howrah Maidan - Esplanade / Sector V)",
        "code": "L2",
        "colorHex": "#43A047",
        "firstTrain": "07:00 AM",
        "lastTrain": "09:45 PM",
        "frequencyMinutes": 10,
        "startStationName": "Howrah Maidan (Underwater Ganga Tunnel)",
        "endStationName": "Salt Lake Sector V",
        "stationIds": [
            "kol_howrah_maidan", "kol_howrah_station", "kol_mahakaran", "kol_esplanade",
            "kol_sealdah", "kol_phoolbagan", "kol_salt_lake_stadium", "kol_bengal_chemical",
            "kol_city_centre", "kol_central_park", "kol_karunamoyee", "kol_salt_lake_sector_v"
        ]
    }
]

kolkata_stations = [
    {
        "id": "kol_howrah_station",
        "cityId": "kolkata",
        "name": "Howrah Railway Station (Deepest Underground Metro)",
        "hindiName": "हावड़ा स्टेशन",
        "lineIds": ["kol_green"],
        "isInterchange": True,
        "latitude": 22.5855,
        "longitude": 88.3426,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Howrah Railway Station Complex & Ferries", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Howrah Bridge & Station Road", "accessible": True}
        ],
        "platformDirections": {
            "kol_green": "Platform 1: Esplanade via Underwater Ganga Metro Tunnel | Platform 2: Howrah Maidan"
        }
    },
    {
        "id": "kol_esplanade",
        "cityId": "kolkata",
        "name": "Esplanade (Line 1 & Line 2 Interchange Hub)",
        "hindiName": "एस्प्लेनेड",
        "lineIds": ["kol_blue", "kol_green"],
        "isInterchange": True,
        "latitude": 22.5645,
        "longitude": 88.3516,
        "facilities": {"hasParking": False, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Jawaharlal Nehru Road & New Market", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Curzon Park & Esplanade Tram/Bus Terminal", "accessible": True}
        ],
        "platformDirections": {
            "kol_blue": "Platform 1: Kavi Subhash | Platform 2: Dakshineswar",
            "kol_green": "Platform 3: Howrah Maidan via River Tunnel"
        }
    }
]

with open(os.path.join(DATA_DIR, 'kolkata_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": kolkata_lines, "stations": kolkata_stations}, f, indent=2, ensure_ascii=False)

# -------------------------------------------------------------
# 6. HYDERABAD METRO PRODUCTION DATASET
# -------------------------------------------------------------
hyd_lines = [
    {
        "id": "hyd_red",
        "cityId": "hyderabad",
        "name": "Red Line (Corridor 1: Miyapur - LB Nagar)",
        "code": "C1",
        "colorHex": "#E53935",
        "firstTrain": "06:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 4,
        "startStationName": "Miyapur",
        "endStationName": "LB Nagar",
        "stationIds": [
            "hyd_miyapur", "hyd_jntu_college", "hyd_kphb_colony", "hyd_kukatpally",
            "hyd_balanagar", "hyd_moosapet", "hyd_bharat_nagar", "hyd_erragadda",
            "hyd_esi_hospital", "hyd_sr_nagar", "hyd_ameerpet", "hyd_punjagutta",
            "hyd_irani_manzil", "hyd_khairatabad", "hyd_lakdi_ka_pul", "hyd_assembly",
            "hyd_nampally", "hyd_gandhi_bhavan", "hyd_osmania_medical_college", "hyd_mg_bus_station",
            "hyd_malakpet", "hyd_new_market", "hyd_musarambagh", "hyd_dilsukhnagar",
            "hyd_chaitanyapuri", "hyd_victoria_memorial", "hyd_lb_nagar"
        ]
    },
    {
        "id": "hyd_blue",
        "cityId": "hyderabad",
        "name": "Blue Line (Corridor 3: Nagole - Raidurg Hitec City)",
        "code": "C3",
        "colorHex": "#1E88E5",
        "firstTrain": "06:00 AM",
        "lastTrain": "11:00 PM",
        "frequencyMinutes": 4,
        "startStationName": "Nagole",
        "endStationName": "Raidurg",
        "stationIds": [
            "hyd_nagole", "hyd_uppal", "hyd_stadium", "hyd_ngri",
            "hyd_habsiguda", "hyd_tarnaka", "hyd_mettuguda", "hyd_secunderabad_east",
            "hyd_parade_ground", "hyd_paradise", "hyd_rasoolpura", "hyd_prakash_nagar",
            "hyd_begumpet", "hyd_ameerpet", "hyd_madhura_nagar", "hyd_yusufguda",
            "hyd_road_no_5_jubilee_hills", "hyd_jubilee_hills_check_post", "hyd_peddamma_gudi", "hyd_madhapur",
            "hyd_durgam_cheruvu", "hyd_hitec_city", "hyd_raidurg"
        ]
    }
]

hyd_stations = [
    {
        "id": "hyd_ameerpet",
        "cityId": "hyderabad",
        "name": "Ameerpet Interchange",
        "hindiName": "अमीरपेट",
        "lineIds": ["hyd_red", "hyd_blue"],
        "isInterchange": True,
        "latitude": 17.4375,
        "longitude": 78.4483,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate A", "landmark": "Sarathi Studios & Yellareddyguda", "accessible": True},
            {"gateNumber": "Gate B", "landmark": "Mytrivanam & Ameerpet Circle", "accessible": True}
        ],
        "platformDirections": {
            "hyd_red": "Platform 1: LB Nagar | Platform 2: Miyapur",
            "hyd_blue": "Platform 3: Raidurg (Hitec City) | Platform 4: Nagole"
        }
    },
    {
        "id": "hyd_raidurg",
        "cityId": "hyderabad",
        "name": "Raidurg (Hitec City & Mindspace)",
        "hindiName": "रायदुर्ग",
        "lineIds": ["hyd_blue"],
        "isInterchange": False,
        "latitude": 17.4398,
        "longitude": 78.3772,
        "facilities": {"hasParking": True, "hasEscalator": True, "hasElevator": True, "hasAtm": True, "hasRestroom": True},
        "gates": [
            {"gateNumber": "Gate 1", "landmark": "Raheja Mindspace IT Park Skywalk", "accessible": True},
            {"gateNumber": "Gate 2", "landmark": "Knowledge City & Inorbit Mall Road", "accessible": True}
        ],
        "platformDirections": {
            "hyd_blue": "Platform 1 & 2: Nagole via Ameerpet"
        }
    }
]

with open(os.path.join(DATA_DIR, 'hyderabad_metro_production.json'), 'w', encoding='utf-8') as f:
    json.dump({"lines": hyd_lines, "stations": hyd_stations}, f, indent=2, ensure_ascii=False)

print("Local production JSON files generated successfully!")
