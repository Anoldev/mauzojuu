// ─── App Constants ────────────────────────────────────────────────
class AppConstants {
  // App Info
  static const String appName = 'MauzoJuu';
  static const String appTagline = 'Duka Lako Mtandaoni';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.mauzojuu.app';

  // Firestore Collections
  static const String usersCollection = 'watumiaji';
  static const String bidhaaCollection = 'bidhaa';
  static const String maagizaCollection = 'maagizo';
  static const String maduka = 'maduka';
  static const String ripotiCollection = 'ripoti';

  // Storage Paths
  static const String bidhaaImagesPath = 'bidhaa_picha';
  static const String profileImagesPath = 'profaili_picha';
  static const String dukaImagesPath = 'duka_picha';

  // SharedPrefs Keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';
  static const String keyDukaId = 'duka_id';

  // Currency
  static const String currency = 'TZS';
  static const String currencySymbol = 'Sh';

  // Order Status
  static const String orderPending = 'inasubiri';
  static const String orderProcessing = 'inashughulikiwa';
  static const String orderShipped = 'imepelekwa';
  static const String orderDelivered = 'imefikia';
  static const String orderCancelled = 'imefutwa';

  // Bidhaa Categories
  static const List<String> categories = [
    'Nguo & Mavazi',
    'Elektroniki',
    'Chakula & Vinywaji',
    'Nyumba & Samani',
    'Kilimo',
    'Afya & Uzuri',
    'Vitabu & Elimu',
    'Michezo',
    'Magari & Vipande',
    'Nyingine',
  ];
}
