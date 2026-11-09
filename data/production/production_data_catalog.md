# MetroPulse Production Transit Data Catalog & Verification Reference

**Document Version:** 1.0 (Production Verified)  
**Last Verified Date:** November 9, 2026  
**Firestore Project:** `metropulse-transit-2026`  
**Author / Maintainer:** Apoorv (*Made with ❤️ by Apoorv*)

---

## 1. Verified Transit Networks & Official Sources

All transit schedules, lines, stations, and interchange geometries have been cross-referenced and verified across primary transit authority portals:

| Metro System | Operating Authority | Official Authority Website | Verified First Train | Verified Last Train |
| :--- | :--- | :--- | :--- | :--- |
| **Delhi NCR Metro** | Delhi Metro Rail Corp (DMRC) / NMRC | [delhimetrorail.com](https://www.delhimetrorail.com) | 05:30 AM (Airport 04:45 AM) | 11:00 PM (Airport 11:40 PM) |
| **Mumbai Metro** | MMRDA / MMMOCL / MMOPL / MMRC | [mmrda.maharashtra.gov.in](https://mmrda.maharashtra.gov.in) | 05:30 AM (Line 1) / 05:55 AM (Lines 2A/7/3) | 11:50 PM (Line 1) / 11:00 PM (Line 2A/7) |
| **Bengaluru Metro** | Bangalore Metro Rail Corp (BMRCL) | [bmrc.co.in](https://www.bmrc.co.in) | 05:00 AM (Mon 04:15 AM) | 11:05 PM (Terminals) |
| **Kolkata Metro** | Metro Railway Kolkata (Indian Railways) | [mtp.indianrailways.gov.in](https://mtp.indianrailways.gov.in) | 06:55 AM (Line 1) / 07:00 AM (Line 2) | 09:40 PM (Line 1) / 09:45 PM (Line 2) |
| **Hyderabad Metro** | L&T Metro Rail (Hyderabad) Limited | [ltmetro.com](https://www.ltmetro.com) | 06:00 AM (All Corridors) | 11:00 PM (All Corridors) |

---

## 2. Delhi NCR Metro (Comprehensive Network Breakdown)

### Lines & Operational Corridors:
1. **Yellow Line (Line 2)**:
   - **Route**: Samaypur Badli ↔ Millennium City Centre Gurugram
   - **Stations**: 37 stations (Samaypur Badli, Azadpur, Kashmere Gate, New Delhi, Rajiv Chowk, Central Secretariat, INA, Hauz Khas, Saket, Qutab Minar, Sikanderpur, Millennium City Centre).
   - **Headway**: Peak 3 mins, Off-Peak 4–5 mins.
   - **First / Last Train**: 05:30 AM / 11:00 PM.

2. **Blue Line (Line 3 & 4)**:
   - **Line 3 (Main)**: Dwarka Sector 21 ↔ Noida Electronic City (50 stations).
   - **Line 4 (Branch)**: Yamuna Bank ↔ Vaishali Ghaziabad (8 stations).
   - **Headway**: Peak 3 mins (Main), 5 mins (Branch).
   - **First / Last Train**: 05:30 AM / 11:00 PM.

3. **Red Line (Line 1)**:
   - **Route**: Rithala ↔ Shaheed Sthal (New Bus Adda Ghaziabad) (29 stations).
   - **First / Last Train**: 05:30 AM / 11:00 PM.

4. **Violet Line (Line 6)**:
   - **Route**: Kashmere Gate ↔ Raja Nahar Singh Ballabhgarh (34 stations).
   - **First / Last Train**: 06:00 AM / 11:00 PM.

5. **Magenta Line (Line 8)**:
   - **Route**: Janakpuri West ↔ Botanical Garden Noida (25 stations).
   - **Key Stops**: IGI Airport Terminal 1, Hauz Khas, Kalkaji Mandir.
   - **First / Last Train**: 05:40 AM / 11:20 PM.

6. **Pink Line (Line 7)**:
   - **Route**: Majlis Park ↔ Shiv Vihar Ring Loop (38 stations).
   - **First / Last Train**: 06:00 AM / 11:00 PM.

7. **Airport Express (Orange Line)**:
   - **Route**: New Delhi Railway Station ↔ Yashobhoomi Dwarka Sector 25 (7 stations).
   - **Speed**: High speed up to 120 km/h (New Delhi to IGI Airport T3 in 15 mins).
   - **First / Last Train**: 04:45 AM / 11:40 PM.

8. **Rapid Metro Gurugram**:
   - **Route**: Sector 55-56 ↔ Phase 3 Cyber City (11 stations).
   - **First / Last Train**: 06:05 AM / 10:00 PM.

9. **Aqua Line (NMRC)**:
   - **Route**: Noida Sector 51 ↔ Depot Station Greater Noida (21 stations).
   - **First / Last Train**: 06:00 AM / 10:00 PM.

---

## 3. Mumbai Metro Network

1. **Line 1 (Blue Line)**:
   - **Route**: Versova ↔ Ghatkopar (12 stations).
   - **Key Interchanges**: Andheri (Western Railway & Line 2A), Marol Naka (Line 3), Ghatkopar (Central Railway).
   - **First / Last Train**: 05:30 AM / 11:50 PM.

2. **Line 2A (Yellow Line)**:
   - **Route**: Dahisar East ↔ Andheri West (17 stations).
   - **Interchanges**: Dahisar East (Line 7), Andheri West / DN Nagar (Line 1).
   - **First / Last Train**: 05:55 AM / 11:00 PM.

3. **Line 7 (Red Line)**:
   - **Route**: Dahisar East ↔ Gundavali Andheri East (14 stations).
   - **Interchanges**: Dahisar East (Line 2A), Gundavali / WEH (Line 1).
   - **First / Last Train**: 05:58 AM / 11:00 PM.

4. **Line 3 (Aqua Line Phase 1)**:
   - **Route**: Aarey JVLR ↔ Bandra Kurla Complex (BKC) (10 underground stations).
   - **Key Stops**: CSMIA Airport T2, CSMIA Airport T1, Marol Naka, BKC.
   - **First / Last Train**: 05:55 AM / 10:30 PM.

---

## 4. Bengaluru Namma Metro Network

1. **Purple Line**:
   - **Route**: Challaghatta ↔ Whitefield Kadugodi (37 stations).
   - **Interchange**: Nadaprabhu Kempegowda Majestic (with Green Line & KSR Railway).
   - **First / Last Train**: 05:00 AM (Mon 04:15 AM) / 11:05 PM.

2. **Green Line**:
   - **Route**: Madavara (BIEC) ↔ Silk Institute (32 stations).
   - **Interchanges**: Majestic, RV Road (Yellow Line).
   - **First / Last Train**: 05:00 AM (Mon 04:15 AM) / 11:05 PM.

---

## 5. Kolkata Metro Network

1. **Blue Line (Line 1)**:
   - **Route**: Dakshineswar ↔ Kavi Subhash (26 stations).
   - **First / Last Train**: 06:55 AM / 09:40 PM.

2. **Green Line (Line 2)**:
   - **Route**: Howrah Maidan ↔ Esplanade ↔ Salt Lake Sector V.
   - **Engineering Marvel**: India's first underwater metro tunnel under the Hooghly / Ganga River (Howrah Station to Mahakaran).
   - **First / Last Train**: 07:00 AM / 09:45 PM.

---

## 6. Hyderabad Metro Network

1. **Red Line (Corridor 1)**: Miyapur ↔ LB Nagar (27 stations).
2. **Blue Line (Corridor 3)**: Nagole ↔ Raidurg Hitec City (23 stations).
3. **Green Line (Corridor 2)**: JBS Parade Ground ↔ MG Bus Station (9 stations).
- **Major Interchange**: Ameerpet (Red Line & Blue Line cross-platform transfer).
- **First / Last Train**: 06:00 AM / 11:00 PM.

---

## 7. Cloud Firestore Synchronization Schema

The production dataset is hosted in Google Cloud Firestore:
- **Project ID**: `metropulse-transit-2026`
- **Location**: `asia-south1` (Mumbai)
- **Security Rules**: Public read-only for clients, admin-write only.

### Collections:
```
firestore:
  ├── cities/
  │    └── {cityId}           -> id, name, currencySymbol, country, rechargeUrl, centerCoords
  ├── lines/
  │    └── {lineId}           -> id, cityId, name, code, colorHex, firstTrain, lastTrain, frequency, stationIds
  ├── stations/
  │    └── {stationId}        -> id, cityId, name, hindiName, lineIds, isInterchange, latitude, longitude, facilities, gates, platformDirections
  ├── alerts/
  │    └── {alertId}          -> cityId, lineId, headline, details, severity, isEmergency, createdAt
  └── config/
       └── monetization       -> isPro, discountPriceINR, originalPriceINR, discountPercent, adUnitIds
```

---

## 8. 100% Offline Resilience Architecture

The client application operates on a local-first paradigm:
1. All baseline production data is bundled inside `TransitDataService` for zero-latency, 100% offline navigation even in deep underground tunnels.
2. When online, `TransitSyncService` streams live updates from Cloud Firestore and updates local cached models in real-time over the air (OTA).
3. Even if Firestore is completely unreachable or airplane mode is active, the app continues to compute Dijkstra shortest-path routes, render 4K schematic vector maps, and calculate fares without any disruption.
