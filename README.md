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

## 4. Production Checklist Status (10/10 Complete)
- [x] **1. Unique App Identity & Package Naming**:
  - Client: `com.apoorv.metropulse`
  - Admin: `com.apoorv.metropulse.admin`
- [x] **2. Production App Icon & Adaptive Assets**:
  - `flutter_launcher_icons` generated for Android adaptive mipmaps and iOS AppIcon set.
- [x] **3. Native Splash Screen**:
  - `flutter_native_splash` configured with brand navy background (`#0F172A`) and transit logo.
- [x] **4. Branding Credit Included**:
  - *"Made with ❤️ by Apoorv"* visible in Settings/About, Home footer, and Admin header.
- [x] **5. AdMob Configuration & Safety**:
  - Test IDs wired for banner, interstitial, and rewarded ads; global kill-switch and Pro ad suppression implemented.
- [x] **6. Payment & Entitlement Verification**:
  - Razorpay Prime Commuter Pass flow with instant local persistence (`shared_preferences`) and restore purchase.
- [x] **7. Hardened Firestore Security Rules**:
  - Public read-only access for cached transit graphs; write access restricted to verified Admin UID.
- [x] **8. Error Handling & Offline State**:
  - Customized `ErrorWidget.builder` prevents red exception screens; offline graph routing functions without internet.
- [x] **9. Store Listing Assets in `publish/`**:
  - 512×512 icon (no alpha), 1024×1024 icon, 1024×500 feature graphic, 4 localized preview screenshots, and full store metadata.
- [x] **10. Release Build Artifacts Generated**:
  - `metropulse_main/publish/builds/app-release.apk` (57.6 MB)
  - `metropulse_main/publish/builds/app-release.aab` (58.5 MB)
