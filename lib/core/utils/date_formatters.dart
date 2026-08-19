import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String shortDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  static String dateTime(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  static String relative(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return shortDate(local);
  }
}
