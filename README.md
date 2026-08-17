# MauzoJuu 🚀
### Duka Lako Mtandaoni — Shopify ya Kiswahili

> Platform ya kwanza ya e-commerce ya Kiswahili kwa Afrika Mashariki

---

## 📱 Kuhusu App

**MauzoJuu** ni mfumo wa kukuza biashara unaoruhusu  wafanyabiashara Tanzania na Afrika Mashariki:
- Kuunda duka lao la mtandaoni kwa urahisi
- Kuorodhesha bidhaa na picha
- Kupokea na kusimamia maagizo ya wateja
- Kuona takwimu za mauzo kwa wakati halisi

---

## 🛠️ Tech Stack

| Sehemu | Teknolojia |
|--------|-----------|
| Mobile App | Flutter (Dart) |
| Backend | Firebase Firestore |
| Auth | Firebase Authentication |
| Storage | Firebase Storage |
| State | Flutter Riverpod |
| Navigation | Go Router |

---

## 🚀 Kuanzisha (Setup)

### 1. Mahitaji
```bash
flutter --version  # Flutter 3.x+
dart --version     # Dart 3.x+
```

### 2. Sakinisha packages
```bash
flutter pub get
```

### 3. Unganisha Firebase
```bash
# Sakinisha FlutterFire CLI
dart pub global activate flutterfire_cli

# Sanidi Firebase (inakuuliza project yako)
flutterfire configure
```

### 4. Endesha app
```bash
flutter run
```

---

## 📁 Muundo wa Mradi

```
lib/
├── main.dart              # Entry point
├── app.dart               # Root widget
├── firebase_options.dart  # Firebase config
├── theme/
│   └── app_theme.dart     # Design system
├── models/
│   ├── bidhaa.dart        # Product model
│   ├── agizo.dart         # Order model
│   └── mtumiaji.dart      # User & Store models
├── services/
│   ├── auth_service.dart  # Authentication
│   ├── bidhaa_service.dart # Products CRUD
│   └── agizo_service.dart  # Orders CRUD
├── screens/
│   ├── splash/            # Splash screen
│   ├── onboarding/        # Onboarding
│   ├── auth/              # Login & Register
│   ├── dashboard/         # Main dashboard
│   ├── bidhaa/            # Products screens
│   ├── maagizo/           # Orders screens
│   ├── duka/              # Store customization
│   ├── ripoti/            # Analytics
│   └── mipangilio/        # Settings
├── widgets/               # Reusable widgets
└── utils/
    ├── constants.dart     # App constants
    ├── helpers.dart       # Helper functions
    ├── router.dart        # Navigation
    └── main_shell.dart    # Bottom nav shell
```

---

## 🏪 Play Store

- **Package**: `com.mauzojuu.app`
- **Category**: Business
- **Min SDK**: Android 6.0 (API 23)
- **Target SDK**: Android 14 (API 34)

### Build APK
```bash
flutter build apk --release
```

### Build App Bundle (kwa Play Store)
```bash
flutter build appbundle --release
```

---

## 🔮 Roadmap

- [x] MVP — E-commerce platform ya msingi
- [ ] M-Pesa / Mobile Money integration
- [ ] WhatsApp Business notifications
- [ ] TRA invoice compliance
- [ ] Multi-vendor marketplace
- [ ] iOS App Store version
- [ ] Web dashboard

---

*Made with ❤️ for Tanzania na Afrika Mashariki*
