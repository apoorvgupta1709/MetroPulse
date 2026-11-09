import os
import math
import re

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUT_DIR = os.path.join(PROJECT_DIR, 'metropulse_main', 'assets', 'maps')
os.makedirs(OUT_DIR, exist_ok=True)

# Common compact schematic canvas
CANVAS_WIDTH = 3400
CANVAS_HEIGHT = 2600

# City configurations with realistic lines, stations, waterways, and schematic positions
cities_config = {
    'mumbai': {
        'title': 'MUMBAI METRO NETWORK',
        'waterway': '<path d="M 400 0 C 450 600, 400 1200, 350 1800 C 300 2200, 200 2400, 150 2600" fill="none" stroke="#E0F2FE" stroke-width="45"/><text x="240" y="1100" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(88 240 1100)">ARABIAN SEA</text>',
        'lines': [
            {
                'id': 'blue',
                'name': 'Line 1: Versova - Ghatkopar',
                'color': '#0284C7',
                'stations': [
                    ('mum_versova', 'Versova', 'वर्सोवा', 600, 1300),
                    ('mum_dn_nagar', 'D.N. Nagar', 'डी.एन. नगर', 880, 1300),
                    ('mum_azad_nagar', 'Azad Nagar', 'आझाद नगर', 1150, 1300),
                    ('mum_andheri', 'Andheri Metro', 'अंधेरी मेट्रो', 1450, 1300),
                    ('mum_western_express', 'Western Express Highway', 'पश्चिम द्रुतगती महामार्ग', 1780, 1300),
                    ('mum_jb_nagar', 'Chakala (J.B. Nagar)', 'चाकला (जे.बी. नगर)', 2080, 1300),
                    ('mum_airport_road', 'Airport Road', 'विमानतळ रस्ता', 2350, 1300),
                    ('mum_marol_naka', 'Marol Naka', 'मरोळ नाका', 2600, 1300),
                    ('mum_saki_naka', 'Saki Naka', 'साकी नाका', 2780, 1450),
                    ('mum_asalpha', 'Asalpha', 'असल्फा', 2780, 1620),
                    ('mum_jagrutinagar', 'Jagruti Nagar', 'जागृती नगर', 2780, 1780),
                    ('mum_ghatkopar', 'Ghatkopar', 'घाटकोपर', 2780, 1950),
                ]
            },
            {
                'id': 'yellow',
                'name': 'Line 2A: Dahisar E - Andheri W (D.N. Nagar)',
                'color': '#F59E0B',
                'stations': [
                    ('mum_dahisar_e', 'Dahisar (East)', 'दहिसर (पूर्व)', 880, 380),
                    ('mum_anand_nagar', 'Anand Nagar', 'आनंद नगर', 880, 560),
                    ('mum_kandivali_w', 'Kandivali (West)', 'कांदिवली (पश्चिम)', 880, 780),
                    ('mum_malad_w', 'Malad (West)', 'मालाड (पश्चिम)', 880, 1000),
                    ('mum_dn_nagar', 'D.N. Nagar', 'डी.एन. नगर', 880, 1300),
                ]
            },
            {
                'id': 'red',
                'name': 'Line 7: Dahisar E - Gundavali (WEH)',
                'color': '#DC2626',
                'stations': [
                    ('mum_dahisar_e', 'Dahisar (East)', 'दहिसर (पूर्व)', 880, 380),
                    ('mum_borivali_e', 'Borivali (East)', 'बोरिवली (पूर्व)', 1780, 550),
                    ('mum_kandivali_e', 'Kandivali (East)', 'कांदिवली (पूर्व)', 1780, 750),
                    ('mum_goregaon_e', 'Goregaon (East)', 'गोरेगाव (पूर्व)', 1780, 950),
                    ('mum_gundavali', 'Gundavali', 'गुंदवली', 1780, 1150),
                    ('mum_western_express', 'Western Express Highway', 'पश्चिम द्रुतगती महामार्ग', 1780, 1300),
                ]
            },
            {
                'id': 'aqua',
                'name': 'Line 3: Aqua Line (Aarey - BKC - Cuffe Parade)',
                'color': '#06B6D4',
                'stations': [
                    ('mum_aarey', 'Aarey JVLR', 'आरे जेव्हीएलआर', 2600, 800),
                    ('mum_marol_naka', 'Marol Naka', 'मरोळ नाका', 2600, 1300),
                    ('mum_csmia_t2', 'CSMIA Terminal 2', 'सीएसएमआयए टी२', 2600, 1600),
                    ('mum_bkc', 'BKC (Bandra Kurla Complex)', 'बीकेसी', 2350, 1950),
                    ('mum_worli', 'Worli', 'वरळी', 2050, 2200),
                    ('mum_cuffe_parade', 'Cuffe Parade', 'कफ परेड', 1750, 2450),
                ]
            }
        ]
    },
    'bengaluru': {
        'title': 'BENGALURU NAMMA METRO',
        'waterway': None,
        'lines': [
            {
                'id': 'purple',
                'name': 'Purple Line: Challaghatta - Whitefield (Kadugodi)',
                'color': '#7C3AED',
                'stations': [
                    ('blr_challaghatta', 'Challaghatta', 'ಚಲ್ಲಘಟ್ಟ', 380, 1300),
                    ('blr_kengeri', 'Kengeri', 'ಕೆಂಗೇರಿ', 620, 1300),
                    ('blr_mysuru_road', 'Mysuru Road', 'ಮೈಸೂರು ರಸ್ತೆ', 900, 1300),
                    ('blr_vijayanagar', 'Vijayanagar', 'ವಿಜಯನಗರ', 1200, 1300),
                    ('blr_majestic', 'Nadaprabhu Kempegowda (Majestic)', 'ಮೆಜೆಸ್ಟಿಕ್', 1550, 1300),
                    ('blr_vidhana_soudha', 'Vidhana Soudha', 'ವಿಧಾನ ಸೌಧ', 1820, 1300),
                    ('blr_mg_road', 'M.G. Road', 'ಎಂ.ಜಿ. ರಸ್ತೆ', 2080, 1300),
                    ('blr_indiranagar', 'Indiranagar', 'ಇಂದಿರಾನಗರ', 2320, 1300),
                    ('blr_baiyappanahalli', 'Baiyappanahalli', 'ಬೈಯಪ್ಪನಹಳ್ಳಿ', 2560, 1300),
                    ('blr_kr_puram', 'K.R. Pura', 'ಕೆ.ಆರ್. ಪುರ', 2800, 1300),
                    ('blr_whitefield', 'Whitefield (Kadugodi)', 'ವೈಟ್‌ಫೀಲ್ಡ್', 3050, 1300),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line: Madavara (BIEC) - Silk Institute',
                'color': '#16A34A',
                'stations': [
                    ('blr_madavara', 'Madavara (BIEC)', 'ಮಾದವಾರ', 1550, 320),
                    ('blr_nagasandra', 'Nagasandra', 'ನಾಗಸಂದ್ರ', 1550, 520),
                    ('blr_peenya', 'Peenya', 'ಪೀಣ್ಯ', 1550, 720),
                    ('blr_yeshwantpur', 'Yeshwantpur', 'ಯಶವಂತಪುರ', 1550, 920),
                    ('blr_mantri_square', 'Mantri Square Sampige Road', 'ಮಂತ್ರಿ ಸ್ಕ್ವೇರ್', 1550, 1100),
                    ('blr_majestic', 'Nadaprabhu Kempegowda (Majestic)', 'ಮೆಜೆಸ್ಟಿಕ್', 1550, 1300),
                    ('blr_chickpete', 'Chickpete', 'ಚಿಕ್ಕಪೇಟೆ', 1550, 1490),
                    ('blr_kr_market', 'Krishna Rajendra Market', 'ಕೆ.ಆರ್. ಮಾರ್ಕೆಟ್', 1550, 1660),
                    ('blr_national_college', 'National College', 'ನ್ಯಾಷನಲ್ ಕಾಲೇಜ್', 1550, 1830),
                    ('blr_lalbagh', 'Lalbagh', 'ಲಾಲ್‌ಬಾಗ್', 1550, 1990),
                    ('blr_jayanagar', 'Jayanagar', 'ಜಯನಗರ', 1550, 2150),
                    ('blr_banashankari', 'Banashankari', 'ಬನಶಂಕರಿ', 1550, 2300),
                    ('blr_silk_institute', 'Silk Institute', 'ರೇಷ್ಮೆ ಸಂಸ್ಥೆ', 1550, 2450),
                ]
            },
            {
                'id': 'yellow',
                'name': 'Yellow Line: R.V. Road - Bommasandra (Electronic City)',
                'color': '#EAB308',
                'stations': [
                    ('blr_national_college', 'National College', 'ನ್ಯಾಷನಲ್ ಕಾಲೇಜ್', 1550, 1830),
                    ('blr_jayadeva', 'Jayadeva Hospital', 'ಜಯದೇವ', 1900, 1950),
                    ('blr_bmtc_silk_board', 'Central Silk Board', 'ಸಿಲ್ಕ್ ಬೋರ್ಡ್', 2220, 2100),
                    ('blr_electronic_city', 'Electronic City', 'ಎಲೆಕ್ಟ್ರಾನಿಕ್ ಸಿಟಿ', 2540, 2250),
                    ('blr_bommasandra', 'Bommasandra', 'ಬೊಮ್ಮಸಂದ್ರ', 2850, 2400),
                ]
            }
        ]
    },
    'kolkata': {
        'title': 'KOLKATA METRO NETWORK',
        'waterway': '<path d="M 1250 0 C 1300 600, 1250 1200, 1300 1800 C 1350 2200, 1400 2400, 1450 2600" fill="none" stroke="#E0F2FE" stroke-width="48"/><text x="1340" y="1000" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(85 1340 1000)">HOOGHLY (GANGA) RIVER</text>',
        'lines': [
            {
                'id': 'blue',
                'name': 'Blue Line (Line 1): Dakshineswar - Kavi Subhash',
                'color': '#0284C7',
                'stations': [
                    ('kol_dakshineswar', 'Dakshineswar', 'দক্ষিণেশ্বর', 1600, 320),
                    ('kol_baranagar', 'Baranagar', 'বরাহনগর', 1600, 500),
                    ('kol_dum_dum', 'Dum Dum', 'দমদম', 1600, 690),
                    ('kol_shyambazar', 'Shyambazar', 'শ্যামবাজার', 1600, 890),
                    ('kol_shobhabazar', 'Shobhabazar Sutanuti', 'শোভাবাজার', 1600, 1070),
                    ('kol_esplanade', 'Esplanade Hub', 'এসপ্ল্যানেড', 1600, 1300),
                    ('kol_park_street', 'Park Street', 'পার্ক স্ট্রিট', 1600, 1490),
                    ('kol_rabindra_sadan', 'Rabindra Sadan', 'রবীন্দ্র সদন', 1600, 1670),
                    ('kol_kalighat', 'Kalighat', 'কালীঘাট', 1600, 1870),
                    ('kol_tollygunge', 'Mahanayak Uttam Kumar (Tollygunge)', 'টালিগঞ্জ', 1600, 2100),
                    ('kol_kavi_subhash', 'Kavi Subhash (New Garia)', 'কবি সুভাষ', 1600, 2380),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line (Line 2): Howrah Maidan - Sector V (Underwater Ganga)',
                'color': '#16A34A',
                'stations': [
                    ('kol_howrah_maidan', 'Howrah Maidan', 'হাওড়া ময়দান', 620, 1300),
                    ('kol_howrah_rly', 'Howrah Railway Station', 'হাওড়া স্টেশন', 920, 1300),
                    ('kol_esplanade', 'Esplanade Hub', 'এসপ্ল্যানেড', 1600, 1300),
                    ('kol_sealdah', 'Sealdah Rly Station', 'শিয়ালদহ', 2020, 1300),
                    ('kol_phoolbagan', 'Phoolbagan', 'फूलবাগান', 2320, 1300),
                    ('kol_salt_lake_stadium', 'Salt Lake Stadium', 'সল্টলেক স্টেডিয়াম', 2600, 1300),
                    ('kol_sector_v', 'Salt Lake Sector V', 'সল্টলেক সেক্টর ৫', 2900, 1300),
                ]
            }
        ]
    },
    'hyderabad': {
        'title': 'HYDERABAD METRO RAIL',
        'waterway': '<path d="M 600 2000 C 1200 1900, 1800 1900, 2600 1950 L 3200 2000" fill="none" stroke="#E0F2FE" stroke-width="36"/><text x="1400" y="1960" font-family="sans-serif" font-size="14" font-weight="800" fill="#7DD3FC" letter-spacing="6">MUSI RIVER</text>',
        'lines': [
            {
                'id': 'red',
                'name': 'Red Line: Miyapur - L.B. Nagar',
                'color': '#DC2626',
                'stations': [
                    ('hyd_miyapur', 'Miyapur', 'మియాపూర్', 550, 650),
                    ('hyd_kphb', 'KPHB Colony', 'కేపీహెచ్‌బీ కాలనీ', 800, 850),
                    ('hyd_kukatpally', 'Kukatpally', 'కూకట్‌పల్లి', 1050, 1050),
                    ('hyd_ameerpet', 'Ameerpet Interchange', 'అమీర్‌పేట్', 1400, 1300),
                    ('hyd_punjagutta', 'Punjagutta', 'పంజాగుట్ట', 1600, 1450),
                    ('hyd_khairatabad', 'Khairatabad', 'ఖైరతాబాద్', 1780, 1600),
                    ('hyd_nampally', 'Nampally Railway Stn', 'నాంపల్లి', 1880, 1750),
                    ('hyd_mgbs', 'MGBS (Imlibun)', 'ఎంజీబీఎస్', 2200, 1900),
                    ('hyd_malakpet', 'Malakpet', 'మలక్‌పేట్', 2450, 2050),
                    ('hyd_dilsukhnagar', 'Dilsukhnagar', 'దిల్‌సుఖ్‌నగర్', 2700, 2200),
                    ('hyd_lb_nagar', 'L.B. Nagar', 'ఎల్.బీ. నగర్', 2950, 2350),
                ]
            },
            {
                'id': 'blue',
                'name': 'Blue Line: Nagole - Raidurg (HITEC City)',
                'color': '#2563EB',
                'stations': [
                    ('hyd_raidurg', 'Raidurg (Mindspace)', 'రాయదుర్గం', 500, 1850),
                    ('hyd_hitec_city', 'HITEC City', 'హైటెక్ సిటీ', 750, 1700),
                    ('hyd_durgam_cheruvu', 'Durgam Cheruvu', 'దుర్గం చెరువు', 950, 1550),
                    ('hyd_madhapur', 'Madhapur', 'మాదాపూర్', 1150, 1420),
                    ('hyd_ameerpet', 'Ameerpet Interchange', 'అమీర్‌పేట్', 1400, 1300),
                    ('hyd_begumpet', 'Begumpet', 'బేగంపేట్', 1700, 1200),
                    ('hyd_parade_ground', 'Parade Ground', 'పరేడ్ గ్రౌండ్', 2000, 1100),
                    ('hyd_secunderabad_east', 'Secunderabad East', 'సికింద్రాబాద్ ఈస్ట్', 2250, 1100),
                    ('hyd_habsiguda', 'Habsiguda', 'హబ్సిగూడ', 2600, 1100),
                    ('hyd_nagole', 'Nagole', 'నాగోల్', 2900, 1100),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line: JBS Parade Ground - MGBS',
                'color': '#16A34A',
                'stations': [
                    ('hyd_parade_ground', 'Parade Ground', 'పరేడ్ గ్రౌండ్', 2000, 1100),
                    ('hyd_secunderabad_west', 'Secunderabad West', 'సికింద్రాబాద్ వెస్ట్', 2000, 1300),
                    ('hyd_rtc_x_roads', 'RTC X Roads', 'ఆర్టీసీ క్రాస్ రోడ్స్', 2000, 1500),
                    ('hyd_chikkadpally', 'Chikkadpally', 'చిక్కడపల్లి', 2000, 1700),
                    ('hyd_mgbs', 'MGBS (Imlibun)', 'ఎంజీబీఎస్', 2200, 1900),
                ]
            }
        ]
    },
    'chennai': {
        'title': 'CHENNAI METRO RAIL (CMRL)',
        'waterway': '<path d="M 2600 0 C 2650 800, 2600 1600, 2650 2600" fill="none" stroke="#E0F2FE" stroke-width="45"/><text x="2720" y="1100" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(90 2720 1100)">BAY OF BENGAL</text>',
        'lines': [
            {
                'id': 'blue',
                'name': 'Blue Line: Wimco Nagar - Chennai International Airport',
                'color': '#0284C7',
                'stations': [
                    ('che_wimco_nagar', 'Wimco Nagar Depot', 'விம்கோ நகர்', 2200, 350),
                    ('che_tollgate', 'Tollgate', 'டோல்கேட்', 2200, 580),
                    ('che_washermanpet', 'Washermanpet', 'வண்ணாரப்பேட்டை', 2200, 810),
                    ('che_high_court', 'High Court', 'உயர் நீதிமன்றம்', 2200, 1040),
                    ('che_central', 'Puratchi Thalaivar Dr. M.G.R Central', 'சென்ட்ரல்', 1900, 1300),
                    ('che_thousand_lights', 'Thousand Lights', 'ஆயிரம் விளக்கு', 1700, 1550),
                    ('che_teynampet', 'Teynampet', 'தேனாம்பேட்டை', 1500, 1750),
                    ('che_nandanam', 'Nandanam', 'நந்தனம்', 1350, 1920),
                    ('che_saidapet', 'Saidapet', 'சைதாப்பேட்டை', 1200, 2060),
                    ('che_alandur', 'Alandur Interchange', 'ஆலந்தூர்', 1050, 2200),
                    ('che_airport', 'Chennai International Airport', 'விமான நிலையம்', 800, 2400),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line: Chennai Central - St. Thomas Mount',
                'color': '#16A34A',
                'stations': [
                    ('che_central', 'Puratchi Thalaivar Dr. M.G.R Central', 'சென்ட்ரல்', 1900, 1300),
                    ('che_egmore', 'Egmore Railway Station', 'எழும்பூர்', 1650, 1300),
                    ('che_kilpauk', 'Kilpauk Medical College', 'கீழ்ப்பாக்கம்', 1400, 1300),
                    ('che_shenoy_nagar', 'Shenoy Nagar', 'ஷெனாய் நகர்', 1150, 1300),
                    ('che_anna_nagar', 'Anna Nagar Tower', 'அண்ணா நகர்', 900, 1400),
                    ('che_koyambedu', 'Koyambedu CMBT', 'கோயம்பேடு', 850, 1650),
                    ('che_vadapalani', 'Vadapalani', 'வடபழனி', 850, 1900),
                    ('che_ashok_nagar', 'Ashok Nagar', 'அசோக் நகர்', 950, 2050),
                    ('che_alandur', 'Alandur Interchange', 'ஆலந்தூர்', 1050, 2200),
                    ('che_st_thomas_mount', 'St. Thomas Mount', 'பரங்கிமலை', 1150, 2350),
                ]
            }
        ]
    },
    'pune': {
        'title': 'PUNE METRO NETWORK',
        'waterway': '<path d="M 800 1700 C 1200 1800, 1700 1900, 2400 1950 L 3200 1950" fill="none" stroke="#E0F2FE" stroke-width="40"/><text x="1400" y="1840" font-family="sans-serif" font-size="15" font-weight="800" fill="#7DD3FC" letter-spacing="6">MULA-MUTHA RIVER</text>',
        'lines': [
            {
                'id': 'purple',
                'name': 'Purple Line: PCMC - Swargate',
                'color': '#7C3AED',
                'stations': [
                    ('pun_pcmc', 'PCMC', 'पिंपरी-चिंचवड', 1600, 350),
                    ('pun_sant_tukaram_nagar', 'Sant Tukaram Nagar', 'संत तुकाराम नगर', 1600, 580),
                    ('pun_bhosari', 'Bhosari (Nashik Phata)', 'भोसरी', 1600, 810),
                    ('pun_kasarwadi', 'Kasarwadi', 'कासारवाडी', 1600, 1020),
                    ('pun_phugewadi', 'Phugewadi', 'फुगेवाडी', 1600, 1230),
                    ('pun_dapodi', 'Dapodi', 'दापोडी', 1600, 1440),
                    ('pun_bopodi', 'Bopodi', 'बोपोडी', 1600, 1650),
                    ('pun_shivaji_nagar', 'Shivajinagar', 'शिवाजीनगर', 1600, 1850),
                    ('pun_civil_court', 'Civil Court Central Interchange', 'सिव्हिल कोर्ट', 1600, 2050),
                    ('pun_swargate', 'Swargate', 'स्वारगेट', 1600, 2350),
                ]
            },
            {
                'id': 'aqua',
                'name': 'Aqua Line: Vanaz - Ramwadi',
                'color': '#06B6D4',
                'stations': [
                    ('pun_vanaz', 'Vanaz', 'वणझ', 600, 2050),
                    ('pun_anand_nagar', 'Anand Nagar', 'आनंद नगर', 850, 2050),
                    ('pun_ideal_colony', 'Ideal Colony', 'आयडियल कॉलनी', 1100, 2050),
                    ('pun_nal_stop', 'Nal Stop', 'नल स्टॉप', 1350, 2050),
                    ('pun_civil_court', 'Civil Court Central Interchange', 'सिव्हिल कोर्ट', 1600, 2050),
                    ('pun_pune_railway_station', 'Pune Railway Station', 'पुणे रेल्वे स्टेशन', 1900, 2050),
                    ('pun_ruby_hall_clinic', 'Ruby Hall Clinic', 'रुबी हॉल क्लिनिक', 2150, 2050),
                    ('pun_bund_garden', 'Bund Garden', 'बंड गार्डन', 2400, 2050),
                    ('pun_kalyani_nagar', 'Kalyani Nagar', 'कल्याणी नगर', 2650, 2050),
                    ('pun_ramwadi', 'Ramwadi', 'रामवाडी', 2900, 2050),
                ]
            }
        ]
    },
    'ahmedabad': {
        'title': 'AHMEDABAD METRO NETWORK',
        'waterway': '<path d="M 1400 0 C 1450 800, 1350 1600, 1450 2600" fill="none" stroke="#E0F2FE" stroke-width="48"/><text x="1420" y="1100" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(88 1420 1100)">SABARMATI RIVER</text>',
        'lines': [
            {
                'id': 'red',
                'name': 'North-South Line: Motera Stadium - APMC',
                'color': '#DC2626',
                'stations': [
                    ('ahm_motera_stadium', 'Motera Stadium', 'મોટેરા સ્ટેડિયમ', 1600, 380),
                    ('ahm_sabarmati', 'Sabarmati Railway Station', 'સાબરમતી', 1600, 680),
                    ('ahm_ranip', 'Ranip', 'રાણીપ', 1600, 980),
                    ('ahm_old_high_court', 'Old High Court Interchange', 'ઓલ્ડ હાઈકોર્ટ', 1600, 1300),
                    ('ahm_paldi', 'Paldi', 'પાલડી', 1600, 1600),
                    ('ahm_vasna', 'Vasna', 'વાસણા', 1600, 1900),
                    ('ahm_apmc', 'APMC', 'એપીએમસી', 1600, 2250),
                ]
            },
            {
                'id': 'blue',
                'name': 'East-West Line: Thaltej Gam - Vastral Gam',
                'color': '#2563EB',
                'stations': [
                    ('ahm_thaltej_gam', 'Thaltej Gam', 'થલતેજ ગામ', 600, 1300),
                    ('ahm_doordarshan', 'Doordarshan Kendra', 'દૂરદર્શન કેન્દ્ર', 900, 1300),
                    ('ahm_gujarat_university', 'Gujarat University', 'ગુજરાત યુનિવર્સિટી', 1200, 1300),
                    ('ahm_old_high_court', 'Old High Court Interchange', 'ઓલ્ડ હાઈકોર્ટ', 1600, 1300),
                    ('ahm_kalupur', 'Kalupur Railway Station', 'કાલુપુર', 2000, 1300),
                    ('ahm_kankaria_east', 'Kankaria East', 'કાંકરિયા પૂર્વ', 2400, 1300),
                    ('ahm_vastral_gam', 'Vastral Gam', 'વસ્ત્રાલ ગામ', 2800, 1300),
                ]
            }
        ]
    },
    'kochi': {
        'title': 'KOCHI METRO (KMRL)',
        'waterway': '<path d="M 1000 0 C 1100 800, 950 1600, 1100 2600" fill="none" stroke="#E0F2FE" stroke-width="45"/><text x="1050" y="1200" font-family="sans-serif" font-size="15" font-weight="800" fill="#7DD3FC" letter-spacing="6" transform="rotate(86 1050 1200)">VEMBANAD BACKWATERS</text>',
        'lines': [
            {
                'id': 'cyan',
                'name': 'Line 1: Aluva - Thripunithura',
                'color': '#06B6D4',
                'stations': [
                    ('koc_aluva', 'Aluva Terminal', 'ആലുവ', 1550, 320),
                    ('koc_kalamassery', 'Kalamassery', 'കളമശ്ശേരി', 1550, 560),
                    ('koc_cusat', 'CUSAT', 'കുസാറ്റ്', 1550, 800),
                    ('koc_edapally', 'Edapally', 'ഇടപ്പള്ളി', 1550, 1050),
                    ('koc_palarivattom', 'Palarivattom', 'പാലാരിവട്ടം', 1550, 1300),
                    ('koc_mg_road', 'M.G. Road', 'എം.ജി. റോഡ്', 1550, 1560),
                    ('koc_maharajas', 'Maharajas College', 'മഹാരാജಾസ്', 1550, 1800),
                    ('koc_vyttila', 'Vyttila Mobility Hub', 'വൈറ്റില', 1550, 2060),
                    ('koc_thripunithura', 'Thripunithura Terminal', 'തൃപ്പൂണിത്തുറ', 1550, 2350),
                ]
            }
        ]
    },
    'jaipur': {
        'title': 'JAIPUR METRO (JMRC)',
        'waterway': None,
        'lines': [
            {
                'id': 'pink',
                'name': 'Pink Line: Mansarovar - Badi Chaupar',
                'color': '#EC407A',
                'stations': [
                    ('jai_mansarovar', 'Mansarovar Terminal', 'मानसरोवर', 450, 1300),
                    ('jai_new_atish_market', 'New Aatish Market', 'न्यू आतिश मार्केट', 750, 1300),
                    ('jai_vivek_vihar', 'Vivek Vihar', 'विवेक विहार', 1050, 1300),
                    ('jai_shyam_nagar', 'Shyam Nagar', 'श्याम नगर', 1350, 1300),
                    ('jai_civil_lines', 'Civil Lines', 'सिविल लाइन्स', 1650, 1300),
                    ('jai_railway_station', 'Railway Station', 'रेलवे स्टेशन', 1950, 1300),
                    ('jai_sindhi_camp', 'Sindhi Camp ISBT Hub', 'सिंधी कैंप', 2220, 1300),
                    ('jai_chandpole', 'Chandpole Gate', 'चांदपोल', 2480, 1300),
                    ('jai_chhoti_chaupar', 'Chhoti Chaupar', 'छोटी चौपड़', 2720, 1300),
                    ('jai_badi_chaupar', 'Badi Chaupar (Hawa Mahal)', 'बड़ी चौपड़', 2950, 1300),
                ]
            }
        ]
    },
    'dubai': {
        'title': 'DUBAI METRO (RTA)',
        'waterway': '<path d="M 600 600 C 1100 800, 1600 950, 2400 1200 L 2900 1350" fill="none" stroke="#E0F2FE" stroke-width="44"/><text x="1450" y="870" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(14 1450 870)">DUBAI CREEK (KHOR DUBAI)</text>',
        'lines': [
            {
                'id': 'red',
                'name': 'Red Line: Centrepoint - Expo 2020 / UAE Exchange',
                'color': '#DC2626',
                'stations': [
                    ('dxb_centrepoint', 'Centrepoint (Rashidiya)', 'سنتربوينت', 2850, 500),
                    ('dxb_airport_t3', 'Dubai Airport Terminal 3', 'المطار مبنى 3', 2550, 650),
                    ('dxb_airport_t1', 'Dubai Airport Terminal 1', 'المطار مبنى 1', 2300, 780),
                    ('dxb_deira_city_centre', 'Deira City Centre', 'ديرة سيتي سنتر', 2050, 920),
                    ('dxb_union', 'Union Station Hub', 'الاتحاد', 1800, 1050),
                    ('dxb_burjuman', 'BurJuman Interchange', 'برجمان', 1550, 1180),
                    ('dxb_adcb', 'ADCB (Al Karama)', 'بنك أبوظبي التجاري', 1350, 1280),
                    ('dxb_world_trade_centre', 'World Trade Centre', 'المركز التجاري العالمي', 1150, 1400),
                    ('dxb_burj_khalifa', 'Burj Khalifa / Dubai Mall', 'برج خليفة / دبي مول', 950, 1550),
                    ('dxb_business_bay', 'Business Bay', 'الخليج التجاري', 800, 1720),
                    ('dxb_mall_of_emirates', 'Mall of the Emirates', 'مول الإمارات', 650, 1920),
                    ('dxb_dmcc', 'DMCC (Jumeirah Lakes Towers)', 'أبراج بحيرات جميرا', 520, 2150),
                    ('dxb_expo_2020', 'Expo 2020 Terminal', 'إكسبو 2020', 420, 2380),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line: Etisalat - Creek',
                'color': '#16A34A',
                'stations': [
                    ('dxb_etisalat', 'Etisalat Terminal', 'اتصالات', 1800, 400),
                    ('dxb_al_nahda', 'Al Nahda', 'النهدة', 1800, 620),
                    ('dxb_stadium', 'Stadium', 'الاستاد', 1800, 840),
                    ('dxb_union', 'Union Station Hub', 'الاتحاد', 1800, 1050),
                    ('dxb_al_ras', 'Al Ras (Gold Souq)', 'الراس', 1680, 1110),
                    ('dxb_burjuman', 'BurJuman Interchange', 'برجمان', 1550, 1180),
                    ('dxb_oud_metha', 'Oud Metha', 'عود ميثاء', 1550, 1420),
                    ('dxb_healthcare_city', 'Dubai Healthcare City', 'مدينة دبي الطبية', 1550, 1660),
                    ('dxb_creek', 'Creek Terminal', 'الخور', 1550, 1900),
                ]
            }
        ]
    },
    'singapore': {
        'title': 'SINGAPORE MRT SYSTEM',
        'waterway': '<path d="M 1200 1600 C 1500 1700, 1900 1750, 2400 1650 L 2900 1600" fill="none" stroke="#E0F2FE" stroke-width="40"/><text x="1950" y="1740" font-family="sans-serif" font-size="15" font-weight="800" fill="#7DD3FC" letter-spacing="6">MARINA BAY & SINGAPORE RIVER</text>',
        'lines': [
            {
                'id': 'red',
                'name': 'North-South Line (NSL): Jurong East - Marina South Pier',
                'color': '#DC2626',
                'stations': [
                    ('sg_woodlands', 'Woodlands', '兀兰', 1600, 350),
                    ('sg_yishun', 'Yishun', '义顺', 1600, 560),
                    ('sg_ang_mo_kio', 'Ang Mo Kio', '宏茂桥', 1600, 770),
                    ('sg_bishan', 'Bishan Interchange', '碧山', 1600, 980),
                    ('sg_orchard', 'Orchard Road', '乌节', 1600, 1200),
                    ('sg_dhoby_ghaut', 'Dhoby Ghaut Hub', '多美歌', 1600, 1380),
                    ('sg_city_hall', 'City Hall Interchange', '政府大厦', 1600, 1540),
                    ('sg_raffles_place', 'Raffles Place Central', '莱佛士坊', 1600, 1720),
                    ('sg_marina_bay', 'Marina Bay', '滨海湾', 1600, 1940),
                    ('sg_marina_south_pier', 'Marina South Pier', '滨海南码头', 1600, 2180),
                ]
            },
            {
                'id': 'green',
                'name': 'East-West Line (EWL): Tuas Link - Changi Airport',
                'color': '#16A34A',
                'stations': [
                    ('sg_jurong_east', 'Jurong East Hub', '裕廊东', 600, 1630),
                    ('sg_buona_vista', 'Buona Vista', '波那维斯达', 950, 1630),
                    ('sg_outram_park', 'Outram Park', '欧南园', 1300, 1630),
                    ('sg_raffles_place', 'Raffles Place Central', '莱佛士坊', 1600, 1720),
                    ('sg_city_hall', 'City Hall Interchange', '政府大厦', 1600, 1540),
                    ('sg_bugis', 'Bugis Junction', '武吉士', 1900, 1420),
                    ('sg_paya_lebar', 'Paya Lebar Interchange', '巴耶利峇', 2250, 1350),
                    ('sg_tanah_merah', 'Tanah Merah', '丹那美拉', 2600, 1350),
                    ('sg_changi_airport', 'Changi Airport Terminal', '樟宜机场', 2950, 1350),
                ]
            },
            {
                'id': 'blue',
                'name': 'Downtown Line (DTL): Bukit Panjang - Expo',
                'color': '#0284C7',
                'stations': [
                    ('sg_botanic_gardens', 'Botanic Gardens', '植物园', 1250, 1100),
                    ('sg_newton', 'Newton Circus', '纽顿', 1400, 1240),
                    ('sg_bugis', 'Bugis Junction', '武吉士', 1900, 1420),
                    ('sg_bayfront', 'Bayfront (Marina Bay Sands)', '海湾舫', 2050, 1720),
                    ('sg_chinatown', 'Chinatown', '牛车水', 1450, 1850),
                ]
            }
        ]
    },
    'london': {
        'title': 'LONDON UNDERGROUND (TfL)',
        'waterway': '<path d="M 400 1550 C 900 1450, 1400 1700, 1900 1600 C 2400 1500, 2900 1650, 3300 1550" fill="none" stroke="#E0F2FE" stroke-width="48"/><text x="1800" y="1660" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(88 1800 1660)">RIVER THAMES</text>',
        'lines': [
            {
                'id': 'central',
                'name': 'Central Line: West Ruislip - Epping',
                'color': '#DC2626',
                'stations': [
                    ('lon_white_city', 'White City', 'BBC Media Village', 600, 1300),
                    ('lon_notting_hill', 'Notting Hill Gate', 'Portobello Road', 950, 1300),
                    ('lon_marble_arch', 'Marble Arch (Hyde Park)', 'Oxford St West', 1300, 1300),
                    ('lon_oxford_circus', 'Oxford Circus Interchange', 'Regent Street', 1600, 1300),
                    ('lon_tottenham_court', 'Tottenham Court Road', 'Soho & West End', 1880, 1300),
                    ('lon_holborn', 'Holborn', 'British Museum', 2120, 1300),
                    ('lon_bank', 'Bank - Monument Hub', 'City Financial District', 2400, 1300),
                    ('lon_liverpool_st', 'Liverpool Street', 'Spitalfields & East End', 2650, 1300),
                    ('lon_stratford', 'Stratford International', 'Olympic Park', 2950, 1300),
                ]
            },
            {
                'id': 'piccadilly',
                'name': 'Piccadilly Line: Heathrow - Cockfosters',
                'color': '#1E3A8A',
                'stations': [
                    ('lon_heathrow', 'Heathrow Airport (T1-5)', 'International Terminals', 550, 2100),
                    ('lon_south_ken', 'South Kensington', 'V&A & Natural History', 950, 1850),
                    ('lon_green_park', 'Green Park', 'Buckingham Palace', 1400, 1550),
                    ('lon_piccadilly_circus', 'Piccadilly Circus', 'West End Theatres', 1600, 1450),
                    ('lon_holborn', 'Holborn', 'British Museum', 2120, 1300),
                    ('lon_king_cross', 'King\'s Cross St. Pancras', 'Eurostar Hub / Platform 9¾', 2120, 950),
                    ('lon_finsbury_park', 'Finsbury Park', 'Arsenal Emirates', 2120, 680),
                    ('lon_cockfosters', 'Cockfosters Terminal', 'North London', 2120, 420),
                ]
            },
            {
                'id': 'victoria',
                'name': 'Victoria Line: Brixton - Walthamstow Central',
                'color': '#0284C7',
                'stations': [
                    ('lon_brixton', 'Brixton Terminal', 'South London', 1400, 2350),
                    ('lon_victoria', 'Victoria Station', 'Gatwick Express Hub', 1400, 1850),
                    ('lon_green_park', 'Green Park', 'Buckingham Palace', 1400, 1550),
                    ('lon_oxford_circus', 'Oxford Circus Interchange', 'Regent Street', 1600, 1300),
                    ('lon_king_cross', 'King\'s Cross St. Pancras', 'Eurostar Hub / Platform 9¾', 2120, 950),
                    ('lon_walthamstow', 'Walthamstow Central', 'East London', 2600, 650),
                ]
            },
            {
                'id': 'northern',
                'name': 'Northern Line: Edgware - Morden',
                'color': '#1E293B',
                'stations': [
                    ('lon_camden_town', 'Camden Town', 'Camden Market', 1880, 650),
                    ('lon_king_cross', 'King\'s Cross St. Pancras', 'Eurostar Hub / Platform 9¾', 2120, 950),
                    ('lon_bank', 'Bank - Monument Hub', 'City Financial District', 2400, 1300),
                    ('lon_london_bridge', 'London Bridge Hub', 'The Shard & Borough Market', 2400, 1720),
                    ('lon_waterloo', 'Waterloo Station', 'South Bank & London Eye', 1900, 1720),
                    ('lon_morden', 'Morden Terminal', 'South Terminus', 1900, 2250),
                ]
            }
        ]
    }
}

all_station_coords = {}

for city_id, cfg in cities_config.items():
    w = CANVAS_WIDTH
    h = CANVAS_HEIGHT
    svg = []
    svg.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="100%" height="100%">')
    svg.append(f'<rect width="{w}" height="{h}" fill="#FFFFFF"/>')

    if cfg.get('waterway'):
        svg.append(f'<!-- Water Body -->\n{cfg["waterway"]}')

    # Process all lines and map stations
    station_map = {}
    lines_geometry = []

    for line in cfg['lines']:
        pts = []
        for s in line['stations']:
            sid, name, reg_name, x, y = s
            pts.append((x, y))
            all_station_coords[sid] = (x, y)
            if sid not in station_map:
                station_map[sid] = {
                    'name': name,
                    'reg': reg_name,
                    'x': x,
                    'y': y,
                    'lines': [line['color']],
                    'count': 1,
                    'is_h': False
                }
            else:
                station_map[sid]['count'] += 1
                station_map[sid]['lines'].append(line['color'])

        lines_geometry.append((line, pts))

    # Detect horizontal vs vertical orientation for staggering
    for line, pts in lines_geometry:
        for idx in range(len(pts)):
            sid = line['stations'][idx][0]
            if idx > 0 and idx < len(pts) - 1:
                p_prev = pts[idx - 1]
                p_next = pts[idx + 1]
                dx = abs(p_next[0] - p_prev[0])
                dy = abs(p_next[1] - p_prev[1])
                if dx > dy * 1.2:
                    station_map[sid]['is_h'] = True

    # 1. DRAW METRO TRACKS
    svg.append('<!-- LINES -->\n<g stroke-linecap="round" stroke-linejoin="round">')
    for line, pts in lines_geometry:
        d = f"M {pts[0][0]} {pts[0][1]} " + " ".join([f"L {p[0]} {p[1]}" for p in pts[1:]])
        svg.append(f'  <path d="{d}" fill="none" stroke="{line["color"]}" stroke-width="9.5"/>')
    svg.append('</g>')

    # 2. DRAW STATIONS AND CRISP LABELS (ZERO WHITE BLUR CAPSULES)
    svg.append('<!-- STATIONS & LABELS -->\n<g id="stations-layer">')

    # Assign alternating labels for horizontal tracks
    sorted_sids = sorted(station_map.keys(), key=lambda s: (station_map[s]['y'], station_map[s]['x']))

    for idx, sid in enumerate(sorted_sids):
        sinfo = station_map[sid]
        x = sinfo['x']
        y = sinfo['y']
        is_ic = sinfo['count'] > 1 or 'Interchange' in sinfo['name'] or 'Hub' in sinfo['name'] or 'Central' in sinfo['name'] or 'Terminal' in sinfo['name']

        # Determine clean concise names without parenthetical clutter
        clean_en = re.sub(r'\s*\([^)]*\)', '', sinfo['name']).strip().replace('&', '&amp;')
        clean_reg = re.sub(r'\s*\([^)]*\)', '', sinfo['reg']).strip().replace('&', '&amp;')

        is_horizontal = sinfo.get('is_h', False)
        if is_horizontal:
            # Alternating above and below track with mathematical line clearance
            if idx % 2 == 0:
                lx = x
                ly = y - 20
                anchor = 'middle'
                is_above = True
            else:
                lx = x
                ly = y + 24
                anchor = 'middle'
                is_above = False
        else:
            # Vertical or angled track
            is_above = None
            if x > 2400:
                lx = x - 16
                ly = y
                anchor = 'end'
            else:
                lx = x + 16
                ly = y
                anchor = 'start'

        # A. Station Node Dot
        if is_ic:
            svg.append(f'  <circle cx="{x}" cy="{y}" r="8.5" fill="#FFFFFF" stroke="#0F172A" stroke-width="2.6"/>')
            svg.append(f'  <circle cx="{x}" cy="{y}" r="3.4" fill="#0F172A"/>')
        else:
            svg.append(f'  <circle cx="{x}" cy="{y}" r="4.2" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')

        # B. Bilingual / Vernacular Crisp Typography (No blur pills, perfect line clearance)
        if is_ic:
            svg.append('  <g>')
            if is_above is True:
                if clean_reg:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly - 11.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="bold" fill="#334155">{clean_reg}</text>')
                svg.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
            elif is_above is False:
                if clean_reg:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="bold" fill="#334155">{clean_reg}</text>')
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 12:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
                else:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
            else:
                if clean_reg:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly - 3:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10" font-weight="bold" fill="#334155">{clean_reg}</text>')
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 9.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
                else:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 4:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="11.5" font-weight="900" fill="#020617">{clean_en}</text>')
            svg.append('  </g>')
        else:
            svg.append('  <g>')
            if is_above is True:
                if clean_reg:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly - 10:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="8.8" font-weight="600" fill="#475569">{clean_reg}</text>')
                svg.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
            elif is_above is False:
                if clean_reg:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="8.8" font-weight="600" fill="#475569">{clean_reg}</text>')
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 11:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
                else:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
            else:
                if clean_reg:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly - 3:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="8.8" font-weight="600" fill="#475569">{clean_reg}</text>')
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 8:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
                else:
                    svg.append(f'    <text x="{lx:.1f}" y="{ly + 3.5:.1f}" text-anchor="{anchor}" font-family="sans-serif" font-size="10.2" font-weight="bold" fill="#0F172A">{clean_en}</text>')
            svg.append('  </g>')

    svg.append('</g>')

    # 3. MODERN LEGEND CARD (TOP RIGHT)
    leg_x = w - 760
    leg_y = 50
    leg_w = 700
    leg_h = 90 + len(cfg['lines']) * 36 + 45
    svg.append(f'<!-- MODERN LEGEND CARD -->')
    svg.append(f'<g transform="translate({leg_x}, {leg_y})">')
    svg.append(f'  <rect width="{leg_w}" height="{leg_h}" rx="14" ry="14" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.8"/>')
    svg.append(f'  <text x="24" y="36" font-family="sans-serif" font-size="14.5" font-weight="bold" fill="#0F172A" letter-spacing="1">{cfg["title"]}</text>')
    svg.append(f'  <line x1="24" y1="48" x2="{leg_w - 24}" y2="48" stroke="#E2E8F0" stroke-width="1.5"/>')
    for idx, line in enumerate(cfg['lines']):
        iy = 74 + idx * 34
        svg.append(f'  <circle cx="38" cy="{iy}" r="6" fill="{line["color"]}"/>')
        svg.append(f'  <text x="56" y="{iy + 4}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">{line["name"]}</text>')

    sym_y = 74 + len(cfg['lines']) * 34 + 14
    svg.append(f'  <line x1="24" y1="{sym_y - 10}" x2="{leg_w - 24}" y2="{sym_y - 10}" stroke="#E2E8F0" stroke-width="1.5"/>')
    svg.append(f'  <circle cx="38" cy="{sym_y + 10}" r="7.5" fill="#FFFFFF" stroke="#0F172A" stroke-width="2.2"/>')
    svg.append(f'  <circle cx="38" cy="{sym_y + 10}" r="3" fill="#0F172A"/>')
    svg.append(f'  <text x="56" y="{sym_y + 14}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">Interchange Station</text>')
    svg.append(f'  <circle cx="230" cy="{sym_y + 10}" r="4" fill="#FFFFFF" stroke="#1E293B" stroke-width="1.8"/>')
    svg.append(f'  <text x="246" y="{sym_y + 14}" font-family="sans-serif" font-size="10.5" font-weight="600" fill="#334155">Regular Station</text>')
    svg.append('</g>')

    svg.append('</svg>')
    out_file = os.path.join(OUT_DIR, f'{city_id}_metro_schematic.svg')
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write("\n".join(svg))
    print(f"Generated clean schematic {out_file} ({len(svg)} lines)")

print(f"Total non-Delhi stations mapped: {len(all_station_coords)}")

DART_OUT = os.path.join(PROJECT_DIR, 'metropulse_main', 'lib', 'widgets', 'all_cities_schematic_coords.dart')
dart_content = [
    "import 'dart:ui';",
    "",
    "/// Auto-generated station schematic coordinates for all non-Delhi metro networks (3400x2600)",
    "const Map<String, Offset> allCitiesSchematicCoords = {"
]
for sid, (cx, cy) in sorted(all_station_coords.items()):
    dart_content.append(f"  '{sid}': Offset({cx:.1f}, {cy:.1f}),")
dart_content.append("};")

with open(DART_OUT, 'w', encoding='utf-8') as f:
    f.write("\n".join(dart_content) + "\n")
print(f"Exported {len(all_station_coords)} non-Delhi coordinates to {DART_OUT}")
