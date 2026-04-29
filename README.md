# Frames 🚪

> Discover Liverpool's hidden artists through its iconic doors.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Frames is a Flutter mobile app that turns Liverpool's streets into an art gallery. Walk to historic doors across the city, scan QR codes to unlock artist profiles, collect door stickers by neighbourhood, earn badges, and compete with friends.

---

## 📱 Application

- [GitHub Repository](https://github.com/yussr19/casa0015-mobile-assessment-frames)
- [Landing Page](https://yussr19.github.io/casa0015-mobile-assessment-frames)

---

## 📝 Introduction

Liverpool has a thriving independent art scene, but most people walk past its artists every day without knowing they exist. Frames bridges the gap between the city's physical architecture and its creative community — using doors as portals to the artists who call Liverpool home.

---

## 👤 User Personas

![Persona 1](Images/persona1.png)
![Persona 2](Images/persona2.png)
![Persona 3](Images/persona3.png)

---

## 🎬 Storyboard

The initial designs and layout were sketched out on paper before being developed further.

<p align="center">
  <img src="https://github.com/user-attachments/assets/deb92536-c772-49b3-b890-4516282b73f5" width="250"/>
  <img src="https://github.com/user-attachments/assets/b4eb9c90-6963-4a7f-9671-5b33d22cb886" width="250"/>
  <img src="https://github.com/user-attachments/assets/6b3d4b71-8fff-4ad7-b835-73504a634d63" width="250"/>
</p>

The sketches were then developed further to explore the user journey and experience:

<img width="1063" alt="Wireframe 1" src="https://github.com/user-attachments/assets/5bf6384d-8395-43da-98b2-1e23d82c35b9" />
<img width="1063" alt="Wireframe 2" src="https://github.com/user-attachments/assets/fb95ff8d-6f6e-4f38-ac1f-cc760a59db02" />

---

## ✨ Main Features

- **Geocaching Map** — Radar-style Google Maps with 9 hidden doors across Liverpool
- **QR Scanner** — Scan door codes to unlock artist profiles with spark animation and haptic feedback
- **Artist Cards** — Flip animation reveals artist bio, artwork, rarity rating and share button
- **Sticker Collection** — Door stickers organised by neighbourhood with completion badges
- **Rarity System** — Common, Rare and Legendary doors worth different points
- **Badges & Achievements** — 9 unlockable badges with Liverpool landmark illustrations
- **Proximity Alert** — Radar pulses gold when within 100m of an undiscovered door
- **Door of the Week** — Featured door highlighted in yellow on the map
- **First Finder Badge** — Special popup for the first user to scan each door
- **Leaderboard** — Live friend activity feed and weekly rankings

---

## 🗺️ Neighbourhoods

| Neighbourhood | Doors | Rarity |
|---|---|---|
| City Centre | 3 | Common & Rare |
| Ropewalks | 5 | Rare & Legendary |
| Baltic Triangle | 1 | Legendary |

---

## 💻 Development Environment

- Flutter SDK: 3.0+
- Dart SDK: 3.0+
- iOS 16+ / Android 10+
- VS Code or Android Studio
- Firebase project (Blaze plan for Storage)

---

## 📦 Dependencies and APIs

| Package | Purpose |
|---|---|
| google_maps_flutter | Interactive map with custom markers |
| mobile_scanner | QR code scanning (simulator compatible) |
| firebase_core / auth / firestore / storage | Backend and data |
| geolocator | GPS location for proximity detection |
| share_plus | Share artist cards to social media |
| google_fonts | Typography |

---

## 📱 Getting Started

### For Users

1. Download Frames on iOS
2. Open the app and tap the door knocker to enter
3. Allow location permissions
4. Walk to a door in Liverpool and scan its QR code
5. Collect all 9 artist cards!

### For Developers

1. Clone the repository:
```bash
git clone https://github.com/yussr19/casa0015-mobile-assessment-frames.git
cd casa0015-mobile-assessment-frames/frames_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Add your Google Maps API key to `ios/Runner/AppDelegate.swift`

5. Run the app:
```bash
flutter run
```

---

## 📞 Contact

- **Student:** Yussr Osman
- **Module:** CASA0015 Mobile Systems & Interactions
- **Institution:** UCL Connected Environments
- **Year:** 2026

---

## 📄 License

This project is licensed under the MIT License.
