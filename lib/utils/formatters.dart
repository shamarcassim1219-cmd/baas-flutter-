import 'package:intl/intl.dart';

/// A Baas account is always Sri Lankan (no international/email
/// flow like the customer app has), so this is always LKR - no
/// isInternational flag needed here.
String formatMoney(double amount) {
  final formatter = NumberFormat.currency(locale: 'en_LK', symbol: 'Rs. ', decimalDigits: 2);
  return formatter.format(amount);
}

/// Short date for list rows (job cards, ledger history) - e.g. "12 Aug".
String formatShortDate(DateTime date) {
  return DateFormat('d MMM').format(date);
}

/// Short date+time for things like "Online since 8:30 AM".
String formatShortTime(DateTime date) {
  return DateFormat('h:mm a').format(date);
}
