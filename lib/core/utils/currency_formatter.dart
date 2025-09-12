import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs.',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }
}