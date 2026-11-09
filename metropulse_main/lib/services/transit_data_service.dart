import '../models/city.dart';
import '../models/metro_line.dart';
import '../models/station.dart';
import '../models/service_alert.dart';

class TransitDataService {
  static final List<City> supportedCities = [
    const City(
      id: 'delhi_ncr',
      name: 'Delhi NCR Metro',
      stateOrCountry: 'Delhi / Noida / Gurugram',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://www.dmrcsmartcard.com/',
      centerLatitude: 28.6139,
      centerLongitude: 77.2090,
    ),
    const City(
      id: 'mumbai',
      name: 'Mumbai Metro',
      stateOrCountry: 'Maharashtra',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://www.reliancemumbaimetro.com/recharge.html',
      centerLatitude: 19.0760,
      centerLongitude: 72.8777,
    ),
    const City(
      id: 'bengaluru',
      name: 'Bengaluru Namma Metro',
      stateOrCountry: 'Karnataka',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://english.bmrc.co.in/',
      centerLatitude: 12.9716,
      centerLongitude: 77.5946,
    ),
    const City(
      id: 'hyderabad',
      name: 'Hyderabad Metro',
      stateOrCountry: 'Telangana',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://www.ltmetro.com/',
      centerLatitude: 17.3850,
      centerLongitude: 78.4867,
    ),
    const City(
      id: 'kolkata',
      name: 'Kolkata Metro',
      stateOrCountry: 'West Bengal',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://mtp.indianrailways.gov.in/',
      centerLatitude: 22.5726,
      centerLongitude: 88.3639,
    ),
    const City(
      id: 'chennai',
      name: 'Chennai Metro',
      stateOrCountry: 'Tamil Nadu',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://chennaimetrorail.org/',
      centerLatitude: 13.0827,
      centerLongitude: 80.2707,
    ),
    const City(
      id: 'pune',
      name: 'Pune Metro',
      stateOrCountry: 'Maharashtra',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://www.punemetrorail.org/',
      centerLatitude: 18.5204,
      centerLongitude: 73.8567,
    ),
    const City(
      id: 'ahmedabad',
      name: 'Ahmedabad Metro',
      stateOrCountry: 'Gujarat',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://www.gujaratmetrorail.com/',
      centerLatitude: 23.0225,
      centerLongitude: 72.5714,
    ),
    const City(
      id: 'kochi',
      name: 'Kochi Metro',
      stateOrCountry: 'Kerala',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://kochimetro.org/',
      centerLatitude: 9.9312,
      centerLongitude: 76.2673,
    ),
    const City(
      id: 'jaipur',
      name: 'Jaipur Metro',
      stateOrCountry: 'Rajasthan',
      currencySymbol: '₹',
      country: 'India',
      rechargeUrl: 'https://transport.rajasthan.gov.in/jmrc',
      centerLatitude: 26.9124,
      centerLongitude: 75.7873,
    ),
    const City(
      id: 'dubai',
      name: 'Dubai Metro',
      stateOrCountry: 'United Arab Emirates',
      currencySymbol: 'AED',
      country: 'UAE',
      isInternational: true,
      rechargeUrl: 'https://www.rta.ae/wps/portal/rta/ae/home/top-up-nol-card',
      centerLatitude: 25.2048,
      centerLongitude: 55.2708,
    ),
    const City(
      id: 'singapore',
      name: 'Singapore MRT',
      stateOrCountry: 'Singapore',
      currencySymbol: 'S\$',
      country: 'Singapore',
      isInternational: true,
      rechargeUrl: 'https://www.simplygo.com.sg/',
      centerLatitude: 1.3521,
      centerLongitude: 103.8198,
    ),
    const City(
      id: 'london',
      name: 'London Underground',
      stateOrCountry: 'United Kingdom',
      currencySymbol: '£',
      country: 'UK',
      isInternational: true,
      rechargeUrl: 'https://oyster.tfl.gov.uk/oyster/entry.do',
      centerLatitude: 51.5074,
      centerLongitude: -0.1278,
    ),
  ];

  // Fetch Lines for a given city
  static List<MetroLine> getLinesForCity(String cityId) {
    if (cityId == 'delhi_ncr') {
      return _delhiLines;
    } else if (cityId == 'mumbai') {
      return _mumbaiLines;
    } else if (cityId == 'bengaluru') {
      return _bengaluruLines;
    } else if (cityId == 'kolkata') {
      return _kolkataLines;
    } else if (cityId == 'hyderabad') {
      return _hyderabadLines;
    } else if (cityId == 'dubai') {
      return _dubaiLines;
    } else if (cityId == 'singapore') {
      return _singaporeLines;
    } else if (cityId == 'london') {
      return _londonLines;
    }
    // Default fallback to Delhi lines
    return _delhiLines;
  }

  // Fetch Stations for a given city
  static List<Station> getStationsForCity(String cityId) {
    if (cityId == 'delhi_ncr') {
      return _delhiStations;
    } else if (cityId == 'mumbai') {
      return _mumbaiStations;
    } else if (cityId == 'bengaluru') {
      return _bengaluruStations;
    } else if (cityId == 'kolkata') {
      return _kolkataStations;
    } else if (cityId == 'hyderabad') {
      return _hyderabadStations;
    } else if (cityId == 'dubai') {
      return _dubaiStations;
    } else if (cityId == 'singapore') {
      return _singaporeStations;
    } else if (cityId == 'london') {
      return _londonStations;
    }
    return _delhiStations;
  }

  // Active Service Alerts seed
  static List<ServiceAlert> getServiceAlertsForCity(String cityId) {
    if (cityId == 'delhi_ncr') {
      return [
        ServiceAlert(
          id: 'alert_del_1',
          cityId: 'delhi_ncr',
          lineId: 'yellow',
          lineName: 'Yellow Line',
          headline: 'Normal Service Resumed at Kashmere Gate',
          details: 'Crowd regulation measures lifted. Trains running on 3-minute scheduled intervals.',
          severity: AlertSeverity.normal,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        ServiceAlert(
          id: 'alert_del_2',
          cityId: 'delhi_ncr',
          lineId: 'blue',
          lineName: 'Blue Line',
          headline: 'Minor Signal Maintenance near Yamuna Bank',
          details: 'Expect 3-5 minute additional run time between Indraprastha and Mayur Vihar.',
          severity: AlertSeverity.moderate,
          timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
        ),
      ];
    } else if (cityId == 'mumbai') {
      return [
        ServiceAlert(
          id: 'alert_mum_1',
          cityId: 'mumbai',
          lineId: 'mumbai_line1',
          lineName: 'Line 1 (Blue Line)',
          headline: 'Full Peak Frequency Active',
          details: 'Trains arriving every 3.5 minutes between Versova and Ghatkopar.',
          severity: AlertSeverity.normal,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ];
    }
    return [
      ServiceAlert(
        id: 'alert_gen_1',
        cityId: cityId,
        lineId: 'system_wide',
        lineName: 'Metro Network',
        headline: 'All Lines Operating on Normal Timetable',
        details: 'First and last train schedules are running without disruptions.',
        severity: AlertSeverity.normal,
        timestamp: DateTime.now(),
      )
    ];
  }

  // =========================================================================
  // 1. DELHI NCR METRO DATASET
  // =========================================================================
  static final List<MetroLine> _delhiLines = [
    const MetroLine(
      id: 'yellow',
      cityId: 'delhi_ncr',
      name: 'Yellow Line',
      code: 'YL',
      colorHex: '#FBC02D',
      firstTrain: '05:30 AM',
      lastTrain: '11:30 PM',
      frequencyMinutes: 3,
      startStationName: 'Samaypur Badli',
      endStationName: 'Millennium City Centre Gurugram',
      stationIds: [
        'del_samaypur_badli',
        'del_azadpur',
        'del_vishwa_vidyalaya',
        'del_kashmere_gate',
        'del_chandni_chowk',
        'del_new_delhi',
        'del_rajiv_chowk',
        'del_central_secretariat',
        'del_dilli_haat_ina',
        'del_aiims',
        'del_hauz_khas',
        'del_malviya_nagar',
        'del_saket',
        'del_qutab_minar',
        'del_huda_city_centre',
      ],
    ),
    const MetroLine(
      id: 'blue',
      cityId: 'delhi_ncr',
      name: 'Blue Line',
      code: 'BL',
      colorHex: '#1976D2',
      firstTrain: '05:30 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 3,
      startStationName: 'Dwarka Sector 21',
      endStationName: 'Noida Electronic City',
      stationIds: [
        'del_dwarka_sec_21',
        'del_dwarka_mor',
        'del_janakpuri_west',
        'del_rajouri_garden',
        'del_kirti_nagar',
        'del_karol_bagh',
        'del_rajiv_chowk',
        'del_mandi_house',
        'del_yamuna_bank',
        'del_mayur_vihar_1',
        'del_botanical_garden',
        'del_noida_sec_18',
        'del_noida_electronic_city',
      ],
    ),
    const MetroLine(
      id: 'red',
      cityId: 'delhi_ncr',
      name: 'Red Line',
      code: 'RD',
      colorHex: '#D32F2F',
      firstTrain: '05:30 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 4,
      startStationName: 'Rithala',
      endStationName: 'Shaheed Sthal (New Bus Adda)',
      stationIds: [
        'del_rithala',
        'del_netaji_subhash_place',
        'del_kashmere_gate',
        'del_welcome',
        'del_shaheed_sthal',
      ],
    ),
    const MetroLine(
      id: 'magenta',
      cityId: 'delhi_ncr',
      name: 'Magenta Line',
      code: 'MG',
      colorHex: '#C2185B',
      firstTrain: '05:40 AM',
      lastTrain: '11:15 PM',
      frequencyMinutes: 5,
      startStationName: 'Janakpuri West',
      endStationName: 'Botanical Garden',
      stationIds: [
        'del_janakpuri_west',
        'del_igi_airport_t1',
        'del_munirka',
        'del_hauz_khas',
        'del_greater_kailash',
        'del_kalkaji_mandir',
        'del_botanical_garden',
      ],
    ),
    const MetroLine(
      id: 'pink',
      cityId: 'delhi_ncr',
      name: 'Pink Line',
      code: 'PK',
      colorHex: '#E91E63',
      firstTrain: '06:00 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 4,
      startStationName: 'Majlis Park',
      endStationName: 'Shiv Vihar',
      stationIds: [
        'del_azadpur',
        'del_netaji_subhash_place',
        'del_rajouri_garden',
        'del_dilli_haat_ina',
        'del_lajpat_nagar',
        'del_mayur_vihar_1',
        'del_anand_vihar_isbt',
      ],
    ),
    const MetroLine(
      id: 'airport_express',
      cityId: 'delhi_ncr',
      name: 'Airport Express',
      code: 'AX',
      colorHex: '#F57C00',
      firstTrain: '04:45 AM',
      lastTrain: '11:40 PM',
      frequencyMinutes: 8,
      startStationName: 'New Delhi',
      endStationName: 'Yashobhoomi Dwarka Sec 25',
      stationIds: [
        'del_new_delhi',
        'del_shivaji_stadium',
        'del_dhaula_kuan',
        'del_igi_airport_t3',
        'del_dwarka_sec_21',
      ],
    ),
  ];

  static final List<Station> _delhiStations = [
    const Station(
      id: 'del_rajiv_chowk',
      cityId: 'delhi_ncr',
      name: 'Rajiv Chowk (Connaught Place)',
      hindiName: 'राजीव चौक',
      lineIds: ['yellow', 'blue'],
      isInterchange: true,
      latitude: 28.6328,
      longitude: 77.2195,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Radial Road 1, B Block / CP Inner Circle'),
        StationGate(gateNumber: 'Gate 2', landmark: 'PVR Plaza / Regal Building'),
        StationGate(gateNumber: 'Gate 3', landmark: 'Janpath / Palika Bazar'),
        StationGate(gateNumber: 'Gate 4', landmark: 'Barakhamba Road / Tolstoy Marg'),
        StationGate(gateNumber: 'Gate 7', landmark: 'Marina Arcade / Odeon Cinema'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Millennium City Centre Gurugram) / Platform 2 (Towards Samaypur Badli)',
        'blue': 'Platform 3 (Towards Noida Electronic City / Vaishali) / Platform 4 (Towards Dwarka Sector 21)',
      },
    ),
    const Station(
      id: 'del_kashmere_gate',
      cityId: 'delhi_ncr',
      name: 'Kashmere Gate ISBT',
      hindiName: 'कश्मीरी गेट',
      lineIds: ['yellow', 'red'],
      isInterchange: true,
      latitude: 28.6675,
      longitude: 77.2285,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Maharana Pratap Inter State Bus Terminal (ISBT)'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Mori Gate / Old Delhi Rly Station Side'),
        StationGate(gateNumber: 'Gate 3', landmark: 'Lala Hardev Sahai Marg'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Millennium City Centre) / Platform 2 (Towards Samaypur Badli)',
        'red': 'Platform 3 (Towards Shaheed Sthal) / Platform 4 (Towards Rithala)',
      },
    ),
    const Station(
      id: 'del_hauz_khas',
      cityId: 'delhi_ncr',
      name: 'Hauz Khas',
      hindiName: 'हौज़ ख़ास',
      lineIds: ['yellow', 'magenta'],
      isInterchange: true,
      latitude: 28.5432,
      longitude: 77.2065,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Hauz Khas Enclave / Aurobindo Marg'),
        StationGate(gateNumber: 'Gate 2', landmark: 'IIT Delhi Main Gate / SDA Market'),
        StationGate(gateNumber: 'Gate 3', landmark: 'Sarvapriya Vihar'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Samaypur Badli)',
        'magenta': 'Platform 3 (Towards Botanical Garden) / Platform 4 (Towards Janakpuri West)',
      },
    ),
    const Station(
      id: 'del_new_delhi',
      cityId: 'delhi_ncr',
      name: 'New Delhi Railway Station',
      hindiName: 'नई दिल्ली',
      lineIds: ['yellow', 'airport_express'],
      isInterchange: true,
      latitude: 28.6429,
      longitude: 77.2219,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Ajmeri Gate (New Delhi Railway Station Platform 16)'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Bhavbhuti Marg / State Entry Road'),
        StationGate(gateNumber: 'Gate 3', landmark: 'Airport Express Metro Terminal Bridge'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
        'airport_express': 'Platform 1 (Express direct to IGI Airport T3 & Yashobhoomi)',
      },
    ),
    const Station(
      id: 'del_botanical_garden',
      cityId: 'delhi_ncr',
      name: 'Botanical Garden (Noida)',
      hindiName: 'बोटैनिकल गार्डन',
      lineIds: ['blue', 'magenta'],
      isInterchange: true,
      latitude: 28.5641,
      longitude: 77.3343,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Captain Gaur Marg / Noida Sector 37 Bus Stand'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Amity University feeder bus bay / Sector 38'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blue': 'Platform 1 (Towards Noida Electronic City) / Platform 2 (Towards Dwarka Sec 21)',
        'magenta': 'Platform 3 (Terminal Origin towards Janakpuri West / IGI Airport T1)',
      },
    ),
    const Station(
      id: 'del_janakpuri_west',
      cityId: 'delhi_ncr',
      name: 'Janakpuri West',
      hindiName: 'जनकपुरी पश्चिम',
      lineIds: ['blue', 'magenta'],
      isInterchange: true,
      latitude: 28.6295,
      longitude: 77.0778,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'District Centre Janakpuri'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Piccadily Hotel / Shivaji College'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blue': 'Platform 1 (Towards Noida / Vaishali) / Platform 2 (Towards Dwarka 21)',
        'magenta': 'Platform 3 (Towards Botanical Garden / Hauz Khas)',
      },
    ),
    const Station(
      id: 'del_dilli_haat_ina',
      cityId: 'delhi_ncr',
      name: 'Dilli Haat - INA',
      hindiName: 'दिल्ली हाट - आईएनए',
      lineIds: ['yellow', 'pink'],
      isInterchange: true,
      latitude: 28.5744,
      longitude: 77.2091,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Dilli Haat Craft Bazar & Food Court'),
        StationGate(gateNumber: 'Gate 2', landmark: 'INA Food Market'),
        StationGate(gateNumber: 'Gate 5', landmark: 'AIIMS / Safdarjung Hospital Underpass'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
        'pink': 'Platform 3 (Towards Shiv Vihar) / Platform 4 (Towards Majlis Park)',
      },
    ),
    const Station(
      id: 'del_dwarka_sec_21',
      cityId: 'delhi_ncr',
      name: 'Dwarka Sector 21',
      hindiName: 'द्वारका सेक्टर 21',
      lineIds: ['blue', 'airport_express'],
      isInterchange: true,
      latitude: 28.5522,
      longitude: 77.0583,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Pacific D21 Mall / Sector 21 Bus Terminal'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Sector 22 & 23 Residential Pocket'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blue': 'Platform 1 (Towards Noida / Vaishali)',
        'airport_express': 'Platform 2 (Towards New Delhi Railway Station / IGI Airport)',
      },
    ),
    const Station(
      id: 'del_rajouri_garden',
      cityId: 'delhi_ncr',
      name: 'Rajouri Garden',
      hindiName: 'राजौरी गार्डन',
      lineIds: ['blue', 'pink'],
      isInterchange: true,
      latitude: 28.6493,
      longitude: 77.1232,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Main Market / TDI Mall Rajouri Garden'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Ring Road Bus Terminal'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blue': 'Platform 1 (Towards Noida) / Platform 2 (Towards Dwarka 21)',
        'pink': 'Platform 3 (Towards Lajpat Nagar / Mayur Vihar) / Platform 4 (Towards Majlis Park)',
      },
    ),
    const Station(
      id: 'del_central_secretariat',
      cityId: 'delhi_ncr',
      name: 'Central Secretariat',
      hindiName: 'केन्द्रीय सचिवालय',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.6146,
      longitude: 77.2119,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Krishi Bhawan / Rajpath / Kartavya Path'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Shastri Bhawan / Dr. Rajendra Prasad Road'),
        StationGate(gateNumber: 'Gate 5', landmark: 'Udyog Bhawan / Rail Bhawan'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
      },
    ),
    const Station(
      id: 'del_aiims',
      cityId: 'delhi_ncr',
      name: 'AIIMS',
      hindiName: 'एम्स',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.5684,
      longitude: 77.2081,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'AIIMS Main Hospital OPD & Emergency'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Safdarjung Hospital Emergency / Medical College'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
      },
    ),
    const Station(
      id: 'del_huda_city_centre',
      cityId: 'delhi_ncr',
      name: 'Millennium City Centre Gurugram',
      hindiName: 'मिलेनियम सिटी सेंटर गुरुग्राम',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.4593,
      longitude: 77.0725,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Fortis Memorial Research Institute / Sector 29 F&B Hub'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Max Hospital Sushant Lok / Huda City Park'),
        StationGate(gateNumber: 'Gate 4', landmark: 'Auto & Cab Pick-up Bay / App Taxi Point'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 2 (Origin Station towards Samaypur Badli / Kashmere Gate)',
      },
    ),
    const Station(
      id: 'del_noida_electronic_city',
      cityId: 'delhi_ncr',
      name: 'Noida Electronic City',
      hindiName: 'नोएडा इलेक्ट्रॉनिक सिटी',
      lineIds: ['blue'],
      isInterchange: false,
      latitude: 28.6277,
      longitude: 77.3732,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Sector 62 IT Parks / NH-24 Ghaziabad Entry'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Sector 63 Commercial Hub'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blue': 'Platform 2 (Origin Station towards Dwarka Sector 21 / Rajiv Chowk)',
      },
    ),
    const Station(
      id: 'del_igi_airport_t3',
      cityId: 'delhi_ncr',
      name: 'IGI Airport Terminal 3',
      hindiName: 'इंदिरा गांधी अंतरराष्ट्रीय हवाई अड्डा टी-3',
      lineIds: ['airport_express'],
      isInterchange: false,
      latitude: 28.5562,
      longitude: 77.0865,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Terminal 3 International & Domestic Departures Level 2'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Terminal 2 Walkway / Multi-level Car Parking'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'airport_express': 'Platform 1 (Towards Dwarka 21) / Platform 2 (Towards New Delhi Rly Stn)',
      },
    ),
    const Station(
      id: 'del_samaypur_badli',
      cityId: 'delhi_ncr',
      name: 'Samaypur Badli',
      hindiName: 'समयपुर बादली',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.7454,
      longitude: 77.1352,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Badli Railway Station Foot Overbridge'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Sanjay Gandhi Transport Nagar'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Origin towards Millennium City Centre Gurugram)',
      },
    ),
    const Station(
      id: 'del_azadpur',
      cityId: 'delhi_ncr',
      name: 'Azadpur',
      hindiName: 'आज़ादपुर',
      lineIds: ['yellow', 'pink'],
      isInterchange: true,
      latitude: 28.7077,
      longitude: 77.1798,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Azadpur Mandi Gate 1 / Model Town'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Karnal Road Bus Terminal'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
        'pink': 'Platform 3 (Towards Shiv Vihar) / Platform 4 (Towards Majlis Park)',
      },
    ),
    const Station(
      id: 'del_vishwa_vidyalaya',
      cityId: 'delhi_ncr',
      name: 'Vishwa Vidyalaya (Delhi University)',
      hindiName: 'विश्वविद्यालय',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.6946,
      longitude: 77.2147,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'North Campus Arts Faculty / Kirori Mal College'),
        StationGate(gateNumber: 'Gate 3', landmark: 'Chhatra Marg / Daulat Ram College'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
      },
    ),
    const Station(
      id: 'del_chandni_chowk',
      cityId: 'delhi_ncr',
      name: 'Chandni Chowk',
      hindiName: 'चाँदनी चौक',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.6578,
      longitude: 77.2301,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Red Fort (Lal Qila) & Gauri Shankar Mandir'),
        StationGate(gateNumber: 'Gate 3', landmark: 'Delhi Main Railway Station (Old Delhi) Exit'),
        StationGate(gateNumber: 'Gate 5', landmark: 'Chandni Chowk Heritage Market / Dariba Kalan'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'yellow': 'Platform 1 (Towards Gurugram) / Platform 2 (Towards Badli)',
      },
    ),
    const Station(
      id: 'del_mandi_house',
      cityId: 'delhi_ncr',
      name: 'Mandi House',
      hindiName: 'मंडी हाउस',
      lineIds: ['blue'],
      isInterchange: false,
      latitude: 28.6258,
      longitude: 77.2343,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'National School of Drama / Kamani Auditorium'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Rabindra Bhawan / Shri Ram Centre'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blue': 'Platform 1 (Towards Noida) / Platform 2 (Towards Dwarka 21)',
      },
    ),
    const Station(
      id: 'del_kalkaji_mandir',
      cityId: 'delhi_ncr',
      name: 'Kalkaji Mandir',
      hindiName: 'कालकाजी मंदिर',
      lineIds: ['magenta'],
      isInterchange: false,
      latitude: 28.5492,
      longitude: 77.2592,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Shri Kalkaji Temple Main Sanctum'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Lotus Temple & Nehru Place Commercial Hub'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'magenta': 'Platform 1 (Towards Botanical Garden) / Platform 2 (Towards Janakpuri West)',
      },
    ),
  ];

  // =========================================================================
  // 2. MUMBAI METRO DATASET
  // =========================================================================
  static final List<MetroLine> _mumbaiLines = [
    const MetroLine(
      id: 'mumbai_line1',
      cityId: 'mumbai',
      name: 'Line 1 (Blue Line)',
      code: 'L1',
      colorHex: '#0288D1',
      firstTrain: '05:30 AM',
      lastTrain: '11:40 PM',
      frequencyMinutes: 3,
      startStationName: 'Versova',
      endStationName: 'Ghatkopar',
      stationIds: [
        'mum_versova',
        'mum_dn_nagar',
        'mum_andheri',
        'mum_western_express_highway',
        'mum_marol_naka',
        'mum_saki_naka',
        'mum_ghatkopar',
      ],
    ),
    const MetroLine(
      id: 'mumbai_line2a',
      cityId: 'mumbai',
      name: 'Line 2A (Yellow Line)',
      code: 'L2A',
      colorHex: '#FDD835',
      firstTrain: '06:00 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 5,
      startStationName: 'Dahisar East',
      endStationName: 'Andheri West (DN Nagar)',
      stationIds: [
        'mum_dahisar_east',
        'mum_borivali_west',
        'mum_malad_west',
        'mum_dn_nagar',
      ],
    ),
  ];

  static final List<Station> _mumbaiStations = [
    const Station(
      id: 'mum_andheri',
      cityId: 'mumbai',
      name: 'Andheri Metro & Suburban Rly',
      hindiName: 'अंधेरी',
      lineIds: ['mumbai_line1'],
      isInterchange: true,
      latitude: 19.1197,
      longitude: 72.8464,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Western Rly Harbour / Main Line Foot Over Bridge'),
        StationGate(gateNumber: 'Gate 2', landmark: 'SV Road / Andheri Market West'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'mumbai_line1': 'Platform 1 (Towards Ghatkopar) / Platform 2 (Towards Versova)',
      },
    ),
    const Station(
      id: 'mum_dn_nagar',
      cityId: 'mumbai',
      name: 'D.N. Nagar (Andheri West)',
      hindiName: 'डी. एन. नगर',
      lineIds: ['mumbai_line1', 'mumbai_line2a'],
      isInterchange: true,
      latitude: 19.1303,
      longitude: 72.8315,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Link Road / Indian Oil Nagar'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Bhavan College / JP Road'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'mumbai_line1': 'Platform 1 (Towards Ghatkopar) / Platform 2 (Towards Versova)',
        'mumbai_line2a': 'Platform 3 (Towards Dahisar East)',
      },
    ),
    const Station(
      id: 'mum_ghatkopar',
      cityId: 'mumbai',
      name: 'Ghatkopar Railway & Metro',
      hindiName: 'घाटकोपर',
      lineIds: ['mumbai_line1'],
      isInterchange: true,
      latitude: 19.0860,
      longitude: 72.9080,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Central Rly Suburban Platform Connector'),
        StationGate(gateNumber: 'Gate 2', landmark: 'LBS Marg / Ghatkopar West'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'mumbai_line1': 'Platform 2 (Origin Station towards Versova / Andheri)',
      },
    ),
    const Station(
      id: 'mum_versova',
      cityId: 'mumbai',
      name: 'Versova',
      hindiName: 'वर्सोवा',
      lineIds: ['mumbai_line1'],
      isInterchange: false,
      latitude: 19.1353,
      longitude: 72.8143,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Seven Bungalows Bus Depot / Beach Road'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'mumbai_line1': 'Platform 1 (Origin towards Ghatkopar)',
      },
    ),
    const Station(
      id: 'mum_dahisar_east',
      cityId: 'mumbai',
      name: 'Dahisar East',
      hindiName: 'दहिसर पूर्व',
      lineIds: ['mumbai_line2a'],
      isInterchange: false,
      latitude: 19.2570,
      longitude: 72.8631,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Western Express Highway / Dahisar Toll Naka'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'mumbai_line2a': 'Platform 1 (Towards Andheri West / D.N. Nagar)',
      },
    ),
  ];

  // =========================================================================
  // 3. BENGALURU NAMMA METRO DATASET
  // =========================================================================
  static final List<MetroLine> _bengaluruLines = [
    const MetroLine(
      id: 'blr_purple',
      cityId: 'bengaluru',
      name: 'Purple Line',
      code: 'PRP',
      colorHex: '#7B1FA2',
      firstTrain: '05:00 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 4,
      startStationName: 'Whitefield (Kadugodi)',
      endStationName: 'Challaghatta',
      stationIds: [
        'blr_whitefield',
        'blr_indiranagar',
        'blr_mg_road',
        'blr_majestic',
        'blr_vijayanagar',
        'blr_challaghatta',
      ],
    ),
    const MetroLine(
      id: 'blr_green',
      cityId: 'bengaluru',
      name: 'Green Line',
      code: 'GRN',
      colorHex: '#388E3C',
      firstTrain: '05:00 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 5,
      startStationName: 'Madavara (BIEC)',
      endStationName: 'Silk Institute',
      stationIds: [
        'blr_yeshwanthpur',
        'blr_majestic',
        'blr_national_college',
        'blr_jayanagar',
        'blr_silk_institute',
      ],
    ),
  ];

  static final List<Station> _bengaluruStations = [
    const Station(
      id: 'blr_majestic',
      cityId: 'bengaluru',
      name: 'Nadaprabhu Kempegowda Stn (Majestic)',
      hindiName: 'केम्पेगौड़ा मैजेस्टिक',
      lineIds: ['blr_purple', 'blr_green'],
      isInterchange: true,
      latitude: 12.9757,
      longitude: 77.5728,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'KSR Bengaluru City Railway Station Main Entry'),
        StationGate(gateNumber: 'Gate 2', landmark: 'KSRTC Inter-State Bus Stand / Gubbi Thotadappa Road'),
        StationGate(gateNumber: 'Gate 3', landmark: 'BMTC City Bus Stand / Subhash Nagar'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blr_purple': 'Platform 1 (Towards Whitefield) / Platform 2 (Towards Challaghatta)',
        'blr_green': 'Platform 3 (Towards Silk Institute) / Platform 4 (Towards Madavara / BIEC)',
      },
    ),
    const Station(
      id: 'blr_mg_road',
      cityId: 'bengaluru',
      name: 'Mahatma Gandhi Road (MG Road)',
      hindiName: 'एमजी रोड',
      lineIds: ['blr_purple'],
      isInterchange: false,
      latitude: 12.9754,
      longitude: 77.6066,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Church Street / Brigade Road Cross'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Anil Kumble Circle / Cauvery Arts Emporium'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blr_purple': 'Platform 1 (Towards Whitefield) / Platform 2 (Towards Majestic & Challaghatta)',
      },
    ),
    const Station(
      id: 'blr_indiranagar',
      cityId: 'bengaluru',
      name: 'Indiranagar',
      hindiName: 'इंदिरानगर',
      lineIds: ['blr_purple'],
      isInterchange: false,
      latitude: 12.9784,
      longitude: 77.6386,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: '100 Feet Road / CMH Road Junction'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Old Madras Road / BDA Complex'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blr_purple': 'Platform 1 (Towards Whitefield) / Platform 2 (Towards Majestic)',
      },
    ),
    const Station(
      id: 'blr_whitefield',
      cityId: 'bengaluru',
      name: 'Whitefield (Kadugodi)',
      hindiName: 'व्हाइटफील्ड',
      lineIds: ['blr_purple'],
      isInterchange: false,
      latitude: 12.9961,
      longitude: 77.7606,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Kadugodi Bus Stand / ITPL Main Road'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'blr_purple': 'Platform 2 (Origin Station towards Majestic / Challaghatta)',
      },
    ),
  ];

  // =========================================================================
  // 4. DUBAI METRO DATASET
  // =========================================================================
  static final List<MetroLine> _dubaiLines = [
    const MetroLine(
      id: 'dxb_red',
      cityId: 'dubai',
      name: 'Red Line',
      code: 'RED',
      colorHex: '#E53935',
      firstTrain: '05:00 AM',
      lastTrain: '12:00 AM',
      frequencyMinutes: 3,
      startStationName: 'Centrepoint',
      endStationName: 'Expo 2020 / UAE Exchange',
      stationIds: [
        'dxb_centrepoint',
        'dxb_airport_t3',
        'dxb_union',
        'dxb_burjuman',
        'dxb_burj_khalifa',
        'dxb_mall_of_emirates',
        'dxb_dmcc_marina',
        'dxb_expo_2020',
      ],
    ),
    const MetroLine(
      id: 'dxb_green',
      cityId: 'dubai',
      name: 'Green Line',
      code: 'GRN',
      colorHex: '#43A047',
      firstTrain: '05:30 AM',
      lastTrain: '11:30 PM',
      frequencyMinutes: 4,
      startStationName: 'Etisalat',
      endStationName: 'Creek',
      stationIds: [
        'dxb_etisalat',
        'dxb_union',
        'dxb_burjuman',
        'dxb_creek',
      ],
    ),
  ];

  static final List<Station> _dubaiStations = [
    const Station(
      id: 'dxb_burj_khalifa',
      cityId: 'dubai',
      name: 'Burj Khalifa / Dubai Mall',
      lineIds: ['dxb_red'],
      isInterchange: false,
      latitude: 25.2001,
      longitude: 55.2750,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Metro Link Air-Conditioned Bridge direct to Dubai Mall'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Downtown Boulevard & Emaar Square'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'dxb_red': 'Platform 1 (Towards Expo 2020 / UAE Exchange) / Platform 2 (Towards Centrepoint)',
      },
    ),
    const Station(
      id: 'dxb_union',
      cityId: 'dubai',
      name: 'Union Station',
      lineIds: ['dxb_red', 'dxb_green'],
      isInterchange: true,
      latitude: 25.2657,
      longitude: 55.3134,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Al Ghurair Centre & Deira Fish Roundabout'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Union Square Park / RTA Bus Station'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'dxb_red': 'Platform 1 (Towards Expo 2020) / Platform 2 (Towards Centrepoint)',
        'dxb_green': 'Platform 3 (Towards Creek) / Platform 4 (Towards Etisalat)',
      },
    ),
    const Station(
      id: 'dxb_burjuman',
      cityId: 'dubai',
      name: 'BurJuman',
      lineIds: ['dxb_red', 'dxb_green'],
      isInterchange: true,
      latitude: 25.2530,
      longitude: 55.3023,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'BurJuman Centre Mall Entrance'),
        StationGate(gateNumber: 'Gate 2', landmark: 'Khalid Bin Al Waleed Road / Tech Market'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'dxb_red': 'Platform 1 (Towards Expo) / Platform 2 (Towards Airport & Centrepoint)',
        'dxb_green': 'Platform 3 (Towards Creek) / Platform 4 (Towards Etisalat)',
      },
    ),
    const Station(
      id: 'dxb_airport_t3',
      cityId: 'dubai',
      name: 'Dubai Airport Terminal 3',
      lineIds: ['dxb_red'],
      isInterchange: false,
      latitude: 25.2497,
      longitude: 55.3639,
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Emirates Terminal 3 Departures & Arrivals'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      platformDirections: {
        'dxb_red': 'Platform 1 (Towards Downtown Dubai & Expo) / Platform 2 (Towards Centrepoint)',
      },
    ),
  ];

  // =========================================================================
  // 5. SINGAPORE MRT & 6. LONDON UNDERGROUND
  // =========================================================================
  static final List<MetroLine> _singaporeLines = [
    const MetroLine(
      id: 'sg_nsl',
      cityId: 'singapore',
      name: 'North South Line (Red)',
      code: 'NSL',
      colorHex: '#D32F2F',
      firstTrain: '05:30 AM',
      lastTrain: '11:45 PM',
      frequencyMinutes: 3,
      startStationName: 'Jurong East',
      endStationName: 'Marina South Pier',
      stationIds: ['sg_jurong_east', 'sg_orchard', 'sg_dhoby_ghaut', 'sg_raffles_place', 'sg_marina_bay'],
    ),
    const MetroLine(
      id: 'sg_ewl',
      cityId: 'singapore',
      name: 'East West Line (Green)',
      code: 'EWL',
      colorHex: '#388E3C',
      firstTrain: '05:30 AM',
      lastTrain: '11:45 PM',
      frequencyMinutes: 3,
      startStationName: 'Tuas Link',
      endStationName: 'Pasir Ris / Changi Airport',
      stationIds: ['sg_jurong_east', 'sg_buona_vista', 'sg_city_hall', 'sg_raffles_place', 'sg_changi_airport'],
    ),
  ];

  static final List<Station> _singaporeStations = [
    const Station(
      id: 'sg_raffles_place',
      cityId: 'singapore',
      name: 'Raffles Place',
      lineIds: ['sg_nsl', 'sg_ewl'],
      isInterchange: true,
      latitude: 1.2830,
      longitude: 103.8513,
      gates: [
        StationGate(gateNumber: 'Exit A', landmark: 'Caltex House / D\'Almeida Street'),
        StationGate(gateNumber: 'Exit H', landmark: 'Asian Civilisations Museum & Singapore River'),
      ],
      facilities: StationFacilities(),
      platformDirections: {
        'sg_nsl': 'Platform A (Towards Marina South Pier) / Platform B (Towards Jurong East via Woodlands)',
        'sg_ewl': 'Platform C (Towards Pasir Ris) / Platform D (Towards Tuas Link)',
      },
    ),
    const Station(
      id: 'sg_orchard',
      cityId: 'singapore',
      name: 'Orchard Road',
      lineIds: ['sg_nsl'],
      isInterchange: false,
      latitude: 1.3040,
      longitude: 103.8318,
      gates: [
        StationGate(gateNumber: 'Exit ION', landmark: 'ION Orchard Shopping Centre basement 2'),
        StationGate(gateNumber: 'Exit B', landmark: 'Tang Plaza / Scotts Road'),
      ],
      facilities: StationFacilities(),
      platformDirections: {
        'sg_nsl': 'Platform A (Towards Marina South Pier) / Platform B (Towards Jurong East)',
      },
    ),
  ];

  static final List<MetroLine> _londonLines = [
    const MetroLine(
      id: 'lon_central',
      cityId: 'london',
      name: 'Central Line',
      code: 'CEN',
      colorHex: '#E53935',
      firstTrain: '05:30 AM',
      lastTrain: '12:00 AM',
      frequencyMinutes: 3,
      startStationName: 'West Ruislip / Ealing Broadway',
      endStationName: 'Epping',
      stationIds: ['lon_notting_hill', 'lon_oxford_circus', 'lon_holborn', 'lon_bank', 'lon_stratford'],
    ),
    const MetroLine(
      id: 'lon_piccadilly',
      cityId: 'london',
      name: 'Piccadilly Line',
      code: 'PIC',
      colorHex: '#1565C0',
      firstTrain: '05:30 AM',
      lastTrain: '12:00 AM',
      frequencyMinutes: 4,
      startStationName: 'Heathrow Airport / Uxbridge',
      endStationName: 'Cockfosters',
      stationIds: ['lon_heathrow_t23', 'lon_south_kensington', 'lon_piccadilly_circus', 'lon_king_cross'],
    ),
  ];

  static final List<Station> _londonStations = [
    const Station(
      id: 'lon_oxford_circus',
      cityId: 'london',
      name: 'Oxford Circus',
      lineIds: ['lon_central'],
      isInterchange: true,
      latitude: 51.5152,
      longitude: -0.1419,
      gates: [
        StationGate(gateNumber: 'Exit 1', landmark: 'Regent Street North / BBC Broadcasting House'),
        StationGate(gateNumber: 'Exit 3', landmark: 'Oxford Street West & John Lewis'),
      ],
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: false),
      platformDirections: {
        'lon_central': 'Eastbound (Towards Bank & Stratford) / Westbound (Towards Notting Hill & Ealing)',
      },
    ),
    const Station(
      id: 'lon_king_cross',
      cityId: 'london',
      name: 'King\'s Cross St. Pancras',
      lineIds: ['lon_piccadilly'],
      isInterchange: true,
      latitude: 51.5308,
      longitude: -0.1238,
      gates: [
        StationGate(gateNumber: 'Main Concourse', landmark: 'Platform 9 3/4 & Eurostar International Terminal'),
      ],
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true),
      platformDirections: {
        'lon_piccadilly': 'Eastbound (Towards Cockfosters) / Westbound (Towards Heathrow Airport)',
      },
    ),
  ];

  // =========================================================================
  // KOLKATA METRO PRODUCTION DATASET
  // =========================================================================
  static final List<MetroLine> _kolkataLines = [
    const MetroLine(
      id: 'kol_blue',
      cityId: 'kolkata',
      name: 'Blue Line (Line 1: Dakshineswar - Kavi Subhash)',
      code: 'L1',
      colorHex: '#1E88E5',
      firstTrain: '06:55 AM',
      lastTrain: '09:40 PM',
      frequencyMinutes: 6,
      startStationName: 'Dakshineswar',
      endStationName: 'Kavi Subhash',
      stationIds: ['kol_dakshineswar', 'kol_dum_dum', 'kol_esplanade', 'kol_park_street', 'kol_kalighat', 'kol_kavi_subhash'],
    ),
    const MetroLine(
      id: 'kol_green',
      cityId: 'kolkata',
      name: 'Green Line (Line 2: Howrah - Sector V)',
      code: 'L2',
      colorHex: '#43A047',
      firstTrain: '07:00 AM',
      lastTrain: '09:45 PM',
      frequencyMinutes: 10,
      startStationName: 'Howrah Maidan (River Tunnel)',
      endStationName: 'Salt Lake Sector V',
      stationIds: ['kol_howrah_maidan', 'kol_howrah_station', 'kol_esplanade', 'kol_sealdah', 'kol_salt_lake_sector_v'],
    ),
  ];

  static final List<Station> _kolkataStations = [
    const Station(
      id: 'kol_howrah_station',
      cityId: 'kolkata',
      name: 'Howrah Railway Station (Underwater Metro)',
      hindiName: 'हावड़ा स्टेशन',
      lineIds: ['kol_green'],
      isInterchange: true,
      latitude: 22.5855,
      longitude: 88.3426,
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Howrah Railway Concourse & Ganga River Ferry Link'),
      ],
      platformDirections: {
        'kol_green': 'Platform 1: Esplanade via River Ganga Tunnel | Platform 2: Howrah Maidan',
      },
    ),
    const Station(
      id: 'kol_esplanade',
      cityId: 'kolkata',
      name: 'Esplanade (Line 1 & 2 Hub)',
      hindiName: 'एस्प्लेनेड',
      lineIds: ['kol_blue', 'kol_green'],
      isInterchange: true,
      latitude: 22.5645,
      longitude: 88.3516,
      facilities: StationFacilities(hasParking: false, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'New Market & Jawaharlal Nehru Road'),
      ],
      platformDirections: {
        'kol_blue': 'Platform 1: Kavi Subhash | Platform 2: Dakshineswar',
        'kol_green': 'Platform 3: Howrah Maidan via Underwater Tunnel',
      },
    ),
  ];

  // =========================================================================
  // HYDERABAD METRO PRODUCTION DATASET
  // =========================================================================
  static final List<MetroLine> _hyderabadLines = [
    const MetroLine(
      id: 'hyd_red',
      cityId: 'hyderabad',
      name: 'Red Line (Miyapur - LB Nagar)',
      code: 'C1',
      colorHex: '#E53935',
      firstTrain: '06:00 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 4,
      startStationName: 'Miyapur',
      endStationName: 'LB Nagar',
      stationIds: ['hyd_miyapur', 'hyd_kphb_colony', 'hyd_ameerpet', 'hyd_mg_bus_station', 'hyd_lb_nagar'],
    ),
    const MetroLine(
      id: 'hyd_blue',
      cityId: 'hyderabad',
      name: 'Blue Line (Nagole - Raidurg Hitec City)',
      code: 'C3',
      colorHex: '#1E88E5',
      firstTrain: '06:00 AM',
      lastTrain: '11:00 PM',
      frequencyMinutes: 4,
      startStationName: 'Nagole',
      endStationName: 'Raidurg (Hitec City)',
      stationIds: ['hyd_nagole', 'hyd_secunderabad_east', 'hyd_ameerpet', 'hyd_hitec_city', 'hyd_raidurg'],
    ),
  ];

  static final List<Station> _hyderabadStations = [
    const Station(
      id: 'hyd_ameerpet',
      cityId: 'hyderabad',
      name: 'Ameerpet (Red & Blue Line Hub)',
      hindiName: 'अमीरपेट',
      lineIds: ['hyd_red', 'hyd_blue'],
      isInterchange: true,
      latitude: 17.4375,
      longitude: 78.4483,
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      gates: [
        StationGate(gateNumber: 'Gate A', landmark: 'Sarathi Studios & Ameerpet Circle'),
      ],
      platformDirections: {
        'hyd_red': 'Platform 1: LB Nagar | Platform 2: Miyapur',
        'hyd_blue': 'Platform 3: Raidurg (Hitec City) | Platform 4: Nagole',
      },
    ),
    const Station(
      id: 'hyd_raidurg',
      cityId: 'hyderabad',
      name: 'Raidurg (Hitec City / Mindspace)',
      hindiName: 'रायदुर्ग',
      lineIds: ['hyd_blue'],
      isInterchange: false,
      latitude: 17.4398,
      longitude: 78.3772,
      facilities: StationFacilities(hasParking: true, hasEscalator: true, hasElevator: true, hasAtm: true, hasRestroom: true),
      gates: [
        StationGate(gateNumber: 'Gate 1', landmark: 'Mindspace IT Park Skywalk'),
      ],
      platformDirections: {
        'hyd_blue': 'Platform 1 & 2: Nagole via Ameerpet',
      },
    ),
  ];
}
