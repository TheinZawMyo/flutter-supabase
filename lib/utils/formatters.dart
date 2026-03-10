import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, {String? code, String? symbol}) {
    final curCode = code ?? 'MMK';
    final curSymbol = symbol ?? 'Ks';

    if (curCode == 'MMK') {
      final formatter = NumberFormat('#,###', 'en_US');
      return '${formatter.format(amount)}$curSymbol';
    }

    final formatter = NumberFormat.currency(
      symbol: curSymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }
}
