# 🚇 MetroPulse - Next-Gen Urban Transit & Metro Navigation Suite

> **Universal Source of Truth for MetroPulse Transit System**  
> Built strictly adhering to the Master Production Guidelines.  
> **Signature Attribution**: *Made with ❤️ by Apoorv*

---

## 1. Project Directory Architecture

```text
E:\YOUTUBE 2026\Publish APPS\MetroPulse\
├── metropulse_main\                         <-- Client App (Play Store & App Store)
│   ├── android\                             # Package: com.apoorv.metropulse
│   ├── ios\                                 # Bundle ID: com.apoorv.metropulse
│   ├── lib\                                 # Zero-friction UI, Dijkstra/BFS Engine, Vector Map
│   ├── publish\                             # All publishing-related assets & build outputs
│   │   ├── icons\                           # 512x512 Play Store icon, iOS 1024x1024 app icon
│   │   ├── graphics\                        # 1024x500 Feature graphic, promo banners
│   │   ├── screenshots\                     # Phone & Tablet store preview screenshots
│   │   ├── store_listing\                   # Title, short description, full description, privacy policy doc
│   │   └── builds\                          # Output APKs (.apk) and App Bundles (.aab)
│   ├── firestore.rules                      # Production-locked client security rules
│   └── pubspec.yaml
│
├── metropulse_admin\                        <-- Admin App (Operator & Control Dashboard)
│   ├── android\                             # Package: com.apoorv.metropulse.admin
│   ├── ios\                                 # Bundle ID: com.apoorv.metropulse.admin
│   ├── web\                                 # Web/Desktop Admin Console
│   ├── lib\                                 # Line & Station CMS, Live Delay Broadcaster, Pricing Controls
│   └── pubspec.yaml
│
└── README.md                                # High-level architecture & synchronization protocol
```

---

## 2. Decoupled Core Applications

### A. Main Client App (`metropulse_main`)
- **Package Identifier**: `com.apoorv.metropulse`
- **Zero-Friction Launch**: Instant access to metro route planner, schedules, and maps without requiring login.
- **On-Demand Authentication**: Google Sign-In invoked only when upgrading to **Prime Commuter Pass** to bind the purchase.
- **Offline Graph Engine**: Pure Dart Dijkstra (fastest travel time) and BFS (fewest line changes) routing algorithms.
- **Ultra-Crisp Interactive Map**: High-DPI pan-and-zoom vector viewer with search-to-pan locator.
- **Monetization Engine**: AdMob (banner, frequency-capped interstitial, rewarded exit guides) + Razorpay Lifetime Prime Pass.

### B. Admin Dashboard App (`metropulse_admin`)
- **Package Identifier**: `com.apoorv.metropulse.admin`
- **City & Line CMS**: Manage Indian & international networks, line colors, stations, interchange nodes, and exit gates.
- **Live Disruption Broadcaster**: Real-time service delay alerts and holiday schedule announcements.
- **Dynamic Pricing & AdMob Remote Config**: Instant ad kill-switch, frequency slider, and Prime Pass discount pricing.

---

## 3. Universal Attribution Requirement
Every client and admin screen features:
> **"Made with ❤️ by Apoorv"**
- Settings / About screen footer
- Home Screen navigation drawer and dashboard footer
- Admin App header profile and footer

---

## 4. Production Checklist Status
- [x] Unique App Identity & Package Naming (`com.apoorv.metropulse` & `com.apoorv.metropulse.admin`)
- [x] Standard Directory Structure (`publish/` sub-directories created)
- [x] Hardened Firestore Security Rules
- [ ] Production App Icon & Native Splash Assets
- [ ] Offline Graph Engine & Seed Datasets
- [ ] Dynamic AdMob Module with Safety Test IDs
- [ ] Razorpay Prime Pass Integration
- [ ] Admin Control Dashboard
- [ ] Store Listing & Release Builds Generated
