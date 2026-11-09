import json
import os

OUT_DIR = r'MetroPulse\metropulse_main\assets\maps'
os.makedirs(OUT_DIR, exist_ok=True)

# Define city configurations with lines, stations, and layout geometry
cities_config = {
    'mumbai': {
        'title': 'MUMBAI METRO NETWORK',
        'width': 3200,
        'height': 2600,
        'lines': [
            {
                'id': 'blue',
                'name': 'Line 1: Versova - Ghatkopar',
                'color': '#0284C7',
                'stations': [
                    ('mum_versova', 'Versova', 'वर्सोवा', 600, 1300),
                    ('mum_dn_nagar', 'D.N. Nagar', 'डी.एन. नगर', 900, 1300),
                    ('mum_azad_nagar', 'Azad Nagar', 'आझाद नगर', 1200, 1300),
                    ('mum_andheri', 'Andheri Metro', 'अंधेरी मेट्रो', 1500, 1300),
                    ('mum_western_express', 'Western Express Highway', 'पश्चिम द्रुतगती महामार्ग', 1800, 1300),
                    ('mum_jb_nagar', 'Chakala (J.B. Nagar)', 'चाकला (जे.बी. नगर)', 2100, 1300),
                    ('mum_airport_road', 'Airport Road', 'विमानतळ रस्ता', 2400, 1300),
                    ('mum_marol_naka', 'Marol Naka', 'मरोळ नाका', 2650, 1300),
                    ('mum_saki_naka', 'Saki Naka', 'साकी नाका', 2850, 1400),
                    ('mum_asalpha', 'Asalpha', 'असल्फा', 2850, 1550),
                    ('mum_jagrutinagar', 'Jagruti Nagar', 'जागृती नगर', 2850, 1700),
                    ('mum_ghatkopar', 'Ghatkopar', 'घाटकोपर', 2850, 1850),
                ]
            },
            {
                'id': 'yellow',
                'name': 'Line 2A: Dahisar E - Andheri W',
                'color': '#F59E0B',
                'stations': [
                    ('mum_dahisar_e', 'Dahisar (East)', 'दहिसर (पूर्व)', 900, 400),
                    ('mum_anand_nagar', 'Anand Nagar', 'आनंद नगर', 900, 550),
                    ('mum_kandivali_w', 'Kandivali (West)', 'कांदिवली (पश्चिम)', 900, 750),
                    ('mum_malad_w', 'Malad (West)', 'मालाड (पश्चिम)', 900, 950),
                    ('mum_dn_nagar', 'D.N. Nagar', 'डी.एन. नगर', 900, 1300),
                ]
            },
            {
                'id': 'red',
                'name': 'Line 7: Dahisar E - Gundavali',
                'color': '#DC2626',
                'stations': [
                    ('mum_dahisar_e', 'Dahisar (East)', 'दहिसर (पूर्व)', 900, 400),
                    ('mum_borivali_e', 'Borivali (East)', 'बोरिवली (पूर्व)', 1500, 600),
                    ('mum_kandivali_e', 'Kandivali (East)', 'कांदिवली (पूर्व)', 1500, 800),
                    ('mum_goregaon_e', 'Goregaon (East)', 'गोरेगाव (पूर्व)', 1500, 1000),
                    ('mum_gundavali', 'Gundavali', 'गुंदवली', 1500, 1200),
                    ('mum_western_express', 'Western Express Highway', 'पश्चिम द्रुतगती महामार्ग', 1800, 1300),
                ]
            },
            {
                'id': 'aqua',
                'name': 'Line 3: Aqua Line (Aarey - BKC - Cuffe Parade)',
                'color': '#06B6D4',
                'stations': [
                    ('mum_aarey', 'Aarey JVLR', 'आरे जेव्हीएलआर', 2650, 800),
                    ('mum_marol_naka', 'Marol Naka', 'मरोळ नाका', 2650, 1300),
                    ('mum_csmia_t2', 'CSMIA Terminal 2', 'सीएसएमआयए टी२', 2650, 1600),
                    ('mum_bkc', 'BKC (Bandra Kurla Complex)', 'बीकेसी', 2400, 1950),
                    ('mum_worli', 'Worli', 'वरळी', 2100, 2200),
                    ('mum_cuffe_parade', 'Cuffe Parade', 'कफ परेड', 1800, 2450),
                ]
            }
        ],
        'waterway': '<path d="M 400 0 C 450 600, 400 1200, 350 1800 C 300 2200, 200 2400, 150 2600" fill="none" stroke="#E0F2FE" stroke-width="40"/><text x="240" y="1100" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(88 240 1100)">ARABIAN SEA</text>'
    },
    'bengaluru': {
        'title': 'BENGALURU NAMMA METRO',
        'width': 3200,
        'height': 2600,
        'lines': [
            {
                'id': 'purple',
                'name': 'Purple Line: Challaghatta - Whitefield (Kadugodi)',
                'color': '#7C3AED',
                'stations': [
                    ('blr_challaghatta', 'Challaghatta', 'ಚಲ್ಲಘಟ್ಟ', 400, 1300),
                    ('blr_kengeri', 'Kengeri', 'ಕೆಂಗೇರಿ', 650, 1300),
                    ('blr_mysuru_road', 'Mysuru Road', 'ಮೈಸೂರು ರಸ್ತೆ', 950, 1300),
                    ('blr_vijayanagar', 'Vijayanagar', 'ವಿಜಯನಗರ', 1250, 1300),
                    ('blr_majestic', 'Nadaprabhu Kempegowda (Majestic)', 'ಮೆಜೆಸ್ಟಿಕ್', 1600, 1300),
                    ('blr_vidhana_soudha', 'Vidhana Soudha', 'ವಿಧಾನ ಸೌಧ', 1850, 1300),
                    ('blr_mg_road', 'M.G. Road', 'ಎಂ.ಜಿ. ರಸ್ತೆ', 2100, 1300),
                    ('blr_indiranagar', 'Indiranagar', 'ಇಂದಿರಾನಗರ', 2350, 1300),
                    ('blr_baiyappanahalli', 'Baiyappanahalli', 'ಬೈಯಪ್ಪನಹಳ್ಳಿ', 2600, 1300),
                    ('blr_kr_puram', 'K.R. Pura', 'ಕೆ.ಆರ್. ಪುರ', 2800, 1300),
                    ('blr_whitefield', 'Whitefield (Kadugodi)', 'ವೈಟ್‌ಫೀಲ್ಡ್', 3000, 1300),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line: Madavara (BIEC) - Silk Institute',
                'color': '#16A34A',
                'stations': [
                    ('blr_madavara', 'Madavara (BIEC)', 'ಮಾದವಾರ', 1600, 350),
                    ('blr_nagasandra', 'Nagasandra', 'ನಾಗಸಂದ್ರ', 1600, 550),
                    ('blr_peenya', 'Peenya', 'ಪೀಣ್ಯ', 1600, 750),
                    ('blr_yeshwantpur', 'Yeshwantpur', 'ಯಶವಂತಪುರ', 1600, 950),
                    ('blr_mantri_square', 'Mantri Square Sampige Road', 'ಮಂತ್ರಿ ಸ್ಕ್ವೇರ್', 1600, 1120),
                    ('blr_majestic', 'Nadaprabhu Kempegowda (Majestic)', 'ಮೆಜೆಸ್ಟಿಕ್', 1600, 1300),
                    ('blr_chickpete', 'Chickpete', 'ಚಿಕ್ಕಪೇಟೆ', 1600, 1500),
                    ('blr_kr_market', 'Krishna Rajendra Market', 'ಕೆ.ಆರ್. ಮಾರ್ಕೆಟ್', 1600, 1680),
                    ('blr_national_college', 'National College', 'ನ್ಯಾಷನಲ್ ಕಾಲೇಜ್', 1600, 1850),
                    ('blr_lalbagh', 'Lalbagh', 'ಲಾಲ್‌ಬಾಗ್', 1600, 2020),
                    ('blr_jayanagar', 'Jayanagar', 'ಜಯನಗರ', 1600, 2180),
                    ('blr_banashankari', 'Banashankari', 'ಬನಶಂಕರಿ', 1600, 2320),
                    ('blr_silk_institute', 'Silk Institute', 'ರೇಷ್ಮೆ ಸಂಸ್ಥೆ', 1600, 2480),
                ]
            },
            {
                'id': 'yellow',
                'name': 'Yellow Line: R.V. Road - Bommasandra (Electronic City)',
                'color': '#EAB308',
                'stations': [
                    ('blr_national_college', 'National College', 'ನ್ಯಾಷನಲ್ ಕಾಲೇಜ್', 1600, 1850),
                    ('blr_jayadeva', 'Jayadeva Hospital', 'ಜಯದೇವ', 1950, 1950),
                    ('blr_bmtc_silk_board', 'Central Silk Board', 'ಸಿಲ್ಕ್ ಬೋರ್ಡ್', 2250, 2100),
                    ('blr_electronic_city', 'Electronic City', 'ಎಲೆಕ್ಟ್ರಾನಿಕ್ ಸಿಟಿ', 2550, 2250),
                    ('blr_bommasandra', 'Bommasandra', 'ಬೊಮ್ಮಸಂದ್ರ', 2850, 2400),
                ]
            }
        ],
        'waterway': None
    },
    'kolkata': {
        'title': 'KOLKATA METRO NETWORK',
        'width': 3200,
        'height': 2600,
        'lines': [
            {
                'id': 'blue',
                'name': 'Blue Line (Line 1): Dakshineswar - Kavi Subhash',
                'color': '#0284C7',
                'stations': [
                    ('kol_dakshineswar', 'Dakshineswar', 'দক্ষিণেশ্বর', 1600, 350),
                    ('kol_baranagar', 'Baranagar', 'বরাহনগর', 1600, 520),
                    ('kol_dum_dum', 'Dum Dum', 'দমদম', 1600, 700),
                    ('kol_shyambazar', 'Shyambazar', 'শ্যামবাজার', 1600, 900),
                    ('kol_shobhabazar', 'Shobhabazar Sutanuti', 'শোভাবাজার', 1600, 1060),
                    ('kol_esplanade', 'Esplanade Hub', 'এসপ্ল্যানেড', 1600, 1300),
                    ('kol_park_street', 'Park Street', 'পার্ক স্ট্রিট', 1600, 1480),
                    ('kol_rabindra_sadan', 'Rabindra Sadan', 'রবীন্দ্র সদন', 1600, 1650),
                    ('kol_kalighat', 'Kalighat', 'কালীঘাট', 1600, 1850),
                    ('kol_tollygunge', 'Mahanayak Uttam Kumar (Tollygunge)', 'টালিগঞ্জ', 1600, 2080),
                    ('kol_kavi_subhash', 'Kavi Subhash (New Garia)', 'কবি সুভাষ', 1600, 2350),
                ]
            },
            {
                'id': 'green',
                'name': 'Green Line (Line 2): Howrah Maidan - Sector V (Underwater Ganga)',
                'color': '#16A34A',
                'stations': [
                    ('kol_howrah_maidan', 'Howrah Maidan', 'হাওড়া ময়দান', 650, 1300),
                    ('kol_howrah_rly', 'Howrah Railway Station', 'হাওড়া স্টেশন', 950, 1300),
                    ('kol_esplanade', 'Esplanade Hub', 'এসপ্ল্যানেড', 1600, 1300),
                    ('kol_sealdah', 'Sealdah Rly Station', 'শিয়ালদহ', 2050, 1300),
                    ('kol_phoolbagan', 'Phoolbagan', 'ফুলবাগান', 2350, 1300),
                    ('kol_salt_lake_stadium', 'Salt Lake Stadium', 'সল্টলেক স্টেডিয়াম', 2600, 1300),
                    ('kol_sector_v', 'Salt Lake Sector V', 'সল্টলেক সেক্টর ৫', 2900, 1300),
                ]
            }
        ],
        'waterway': '<path d="M 1250 0 C 1300 600, 1250 1200, 1300 1800 C 1350 2200, 1400 2400, 1450 2600" fill="none" stroke="#E0F2FE" stroke-width="48"/><text x="1340" y="1000" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(85 1340 1000)">HOOGHLY (GANGA) RIVER</text>'
    },
    'hyderabad': {
        'title': 'HYDERABAD METRO RAIL',
        'width': 3200,
        'height': 2600,
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
                    ('hyd_khairatabad', 'Khairatabad', 'ఖైరతాబాద్', 1800, 1600),
                    ('hyd_nampally', 'Nampally Railway Stn', 'నాంపల్లి', 2000, 1750),
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
        ],
        'waterway': '<path d="M 600 2000 C 1200 1900, 1800 1900, 2600 1950 L 3200 2000" fill="none" stroke="#E0F2FE" stroke-width="36"/><text x="1400" y="1960" font-family="sans-serif" font-size="14" font-weight="800" fill="#7DD3FC" letter-spacing="6">MUSI RIVER</text>'
    },
    'chennai': {
        'title': 'CHENNAI METRO RAIL (CMRL)',
        'width': 3200,
        'height': 2600,
        'lines': [
            {
                'id': 'blue',
                'name': 'Blue Line: Wimco Nagar - Chennai International Airport',
                'color': '#0284C7',
                'stations': [
                    ('che_wimco_nagar', 'Wimco Nagar Depot', 'விம்கோ நகர்', 2200, 350),
                    ('che_tollgate', 'Tollgate', 'டோல்கேட்', 2200, 600),
                    ('che_washermanpet', 'Washermanpet', 'வண்ணாரப்பேட்டை', 2200, 850),
                    ('che_high_court', 'High Court', 'உயர் நீதிமன்றம்', 2200, 1100),
                    ('che_central', 'Puratchi Thalaivar Dr. M.G.R Central', 'சென்ட்ரல்', 1900, 1300),
                    ('che_thousand_lights', 'Thousand Lights', 'ஆயிரம் விளக்கு', 1700, 1550),
                    ('che_teynampet', 'Teynampet', 'தேனாம்பேட்டை', 1500, 1750),
                    ('che_nandanam', 'Nandanam', 'நந்தனம்', 1350, 1900),
                    ('che_saidapet', 'Saidapet', 'சைதாப்பேட்டை', 1200, 2050),
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
        ],
        'waterway': '<path d="M 2600 0 C 2650 800, 2600 1600, 2650 2600" fill="none" stroke="#E0F2FE" stroke-width="45"/><text x="2720" y="1100" font-family="sans-serif" font-size="16" font-weight="800" fill="#7DD3FC" letter-spacing="8" transform="rotate(90 2720 1100)">BAY OF BENGAL</text>'
    }
}

for city_id, cfg in cities_config.items():
    w = cfg['width']
    h = cfg['height']
    svg = []
    svg.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="100%" height="100%">')
    svg.append(f'<rect width="{w}" height="{h}" fill="#FFFFFF"/>')

    if cfg['waterway']:
        svg.append(f'<!-- Water Body -->\n{cfg["waterway"]}')

    # Draw lines
    svg.append('<!-- LINES -->\n<g stroke-linecap="round" stroke-linejoin="round">')
    station_map = {}
    for line in cfg['lines']:
        pts = []
        for s in line['stations']:
            sid, name, reg_name, x, y = s
            pts.append(f"{x} {y}")
            if sid not in station_map:
                station_map[sid] = {'name': name, 'reg': reg_name, 'x': x, 'y': y, 'lines': [line['color']], 'count': 1}
            else:
                station_map[sid]['count'] += 1
                station_map[sid]['lines'].append(line['color'])

        d = f"M {pts[0]} " + " ".join([f"L {p}" for p in pts[1:]])
        svg.append(f'  <path d="{d}" fill="none" stroke="{line["color"]}" stroke-width="10"/>')
    svg.append('</g>')

    # Draw stations
    svg.append('<!-- STATIONS -->\n<g id="stations-layer">')
    for sid, sinfo in station_map.items():
        x = sinfo['x']
        y = sinfo['y']
        is_ic = sinfo['count'] > 1 or 'Interchange' in sinfo['name'] or 'Hub' in sinfo['name'] or 'Central' in sinfo['name'] or 'Majestic' in sinfo['name'] or 'D.N. Nagar' in sinfo['name'] or 'Andheri' in sinfo['name']
        dx = 14
        dy = -6
        text_anchor = "start"

        if x > 2500:
            dx = -14
            text_anchor = "end"

        if is_ic:
            svg.append(f'  <circle cx="{x}" cy="{y}" r="12" fill="#FFFFFF" stroke="#0F172A" stroke-width="3"/>')
            svg.append(f'  <circle cx="{x}" cy="{y}" r="5" fill="#0F172A"/>')
            svg.append(f'  <text x="{x + dx}" y="{y + dy}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155" paint-order="stroke" stroke="#FFFFFF" stroke-width="4.5" stroke-linejoin="round">{sinfo["reg"]}</text>')
            svg.append(f'  <text x="{x + dx}" y="{y + dy + 13}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="13" font-weight="bold" fill="#020617" paint-order="stroke" stroke="#FFFFFF" stroke-width="4.5" stroke-linejoin="round">{sinfo["name"]}</text>')
        else:
            svg.append(f'  <circle cx="{x}" cy="{y}" r="5" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')
            svg.append(f'  <text x="{x + dx}" y="{y + dy}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="9.5" font-weight="500" fill="#475569" paint-order="stroke" stroke="#FFFFFF" stroke-width="4" stroke-linejoin="round">{sinfo["reg"]}</text>')
            svg.append(f'  <text x="{x + dx}" y="{y + dy + 10}" text-anchor="{text_anchor}" font-family="sans-serif" font-size="11" font-weight="600" fill="#0F172A" paint-order="stroke" stroke="#FFFFFF" stroke-width="4" stroke-linejoin="round">{sinfo["name"]}</text>')
    svg.append('</g>')

    # Legend
    leg_x = w - 740
    leg_y = 60
    leg_w = 680
    leg_h = 100 + len(cfg['lines']) * 38 + 50
    svg.append(f'<!-- LEGEND -->')
    svg.append(f'<g transform="translate({leg_x}, {leg_y})">')
    svg.append(f'  <rect width="{leg_w}" height="{leg_h}" rx="16" ry="16" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="2"/>')
    svg.append(f'  <text x="24" y="38" font-family="sans-serif" font-size="15" font-weight="bold" fill="#0F172A" letter-spacing="1">{cfg["title"]}</text>')
    svg.append(f'  <line x1="24" y1="50" x2="{leg_w - 24}" y2="50" stroke="#E2E8F0" stroke-width="1.5"/>')
    for idx, line in enumerate(cfg['lines']):
        iy = 78 + idx * 36
        svg.append(f'  <circle cx="36" cy="{iy}" r="6" fill="{line["color"]}"/>')
        svg.append(f'  <text x="54" y="{iy + 4}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">{line["name"]}</text>')

    sym_y = 78 + len(cfg['lines']) * 36 + 15
    svg.append(f'  <line x1="24" y1="{sym_y - 12}" x2="{leg_w - 24}" y2="{sym_y - 12}" stroke="#E2E8F0" stroke-width="1.5"/>')
    svg.append(f'  <circle cx="36" cy="{sym_y + 10}" r="8" fill="#FFFFFF" stroke="#0F172A" stroke-width="2.5"/>')
    svg.append(f'  <circle cx="36" cy="{sym_y + 10}" r="3" fill="#0F172A"/>')
    svg.append(f'  <text x="54" y="{sym_y + 14}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">Interchange Station</text>')
    svg.append(f'  <circle cx="240" cy="{sym_y + 10}" r="4.5" fill="#FFFFFF" stroke="#1E293B" stroke-width="2"/>')
    svg.append(f'  <text x="256" y="{sym_y + 14}" font-family="sans-serif" font-size="11" font-weight="600" fill="#334155">Regular Station</text>')
    svg.append('</g>')

    svg.append('</svg>')
    out_file = os.path.join(OUT_DIR, f'{city_id}_metro_schematic.svg')
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write("\n".join(svg))
    print(f"Generated {out_file} ({len(svg)} lines)")
