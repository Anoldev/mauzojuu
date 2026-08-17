import 'package:intl/intl.dart';

class AppHelpers {
  // Format bei kwa TZS
  static String formatBei(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return 'Sh ${formatter.format(amount)}';
  }

  // Format tarehe kwa Kiswahili
  static String formatTarehe(DateTime date) {
    final miezi = [
      'Januari', 'Februari', 'Machi', 'Aprili', 'Mei', 'Juni',
      'Julai', 'Agosti', 'Septemba', 'Oktoba', 'Novemba', 'Desemba'
    ];
    return '${date.day} ${miezi[date.month - 1]} ${date.year}';
  }

  // Format tarehe fupi
  static String formatTareheFupi(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format wakati
  static String formatWakati(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Validate email
  static bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate simu ya Tanzania
  static bool validateSimuTanzania(String phone) {
    return RegExp(r'^(\+255|0)(6[1-9]|7[1-9])\d{7}$').hasMatch(phone);
  }

  // Format namba ya simu
  static String formatSimu(String phone) {
    if (phone.startsWith('0')) {
      return '+255${phone.substring(1)}';
    }
    return phone;
  }

  // Get hali ya agizo na rangi
  static Map<String, dynamic> getHaliAgizo(String hali) {
    switch (hali) {
      case 'inasubiri':
        return {'jina': 'Inasubiri', 'rangi': 0xFFFFC107, 'icon': '⏳'};
      case 'inashughulikiwa':
        return {'jina': 'Inashughulikiwa', 'rangi': 0xFF2196F3, 'icon': '🔄'};
      case 'imepelekwa':
        return {'jina': 'Imepelekwa', 'rangi': 0xFF9C27B0, 'icon': '🚚'};
      case 'imefikia':
        return {'jina': 'Imefikia', 'rangi': 0xFF00C853, 'icon': '✅'};
      case 'imefutwa':
        return {'jina': 'Imefutwa', 'rangi': 0xFFFF5252, 'icon': '❌'};
      default:
        return {'jina': hali, 'rangi': 0xFF546E7A, 'icon': '📦'};
    }
  }

  // Punguza maandishi marefu
  static String punguza(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
