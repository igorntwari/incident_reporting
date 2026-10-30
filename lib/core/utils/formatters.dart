import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _dateTime = DateFormat('MMM d, yyyy · h:mm a');
  static final _shortDate = DateFormat('MMM d, h:mm a');

  static String dateTime(DateTime date) => _dateTime.format(date);

  static String shortDate(DateTime date) => _shortDate.format(date);

  /// "Just now", "5 minutes ago", "2 days ago", then an absolute date.
  static String timeAgo(DateTime date, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(date);
    String plural(int n, String unit) => '$n $unit${n == 1 ? '' : 's'} ago';

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return plural(diff.inMinutes, 'minute');
    if (diff.inDays < 1) return plural(diff.inHours, 'hour');
    if (diff.inDays < 7) return plural(diff.inDays, 'day');
    return DateFormat('MMM d, yyyy').format(date);
  }
}
