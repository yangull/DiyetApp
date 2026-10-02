import 'package:core/core.dart';

/// The panel's one date format: "28 Eyl", with the year ("28 Eyl 2025") only
/// when it is not the current one. Lists, tables and chart axes all read this
/// way (audit X6).
String formatDate(DateTime d, {DateTime? now}) {
  final base = '${d.day} ${trMonthsShort[d.month - 1]}';
  return d.year == (now ?? DateTime.now()).year ? base : '$base ${d.year}';
}

/// HH:mm, for a message timeline where only the time of day matters.
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole calendar days from [from] to [to], counted on UTC dates so a
/// 23- or 25-hour day around a clock change still counts as one.
int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// An agenda's day heading: "Bugün", "Yarın · Cumartesi 26 Eylül",
/// "Pazartesi 28 Eylül". The screen's header already carries today's date.
String formatDayHeading(DateTime day, {DateTime? now}) {
  final d = _dateOnly(day);
  final days = _daysBetween(now ?? DateTime.now(), d);
  final date = '${trWeekdays[d.weekday - 1]} ${d.day} ${trMonths[d.month - 1]}';
  if (days == 0) return 'Bugün';
  if (days == 1) return 'Yarın · $date';
  return date;
}

/// The day inside a sentence: "bugün", "yarın", "pazartesi" within the week,
/// else "2 Ekim".
String formatDayInSentence(DateTime day, {DateTime? now}) {
  final d = _dateOnly(day);
  final days = _daysBetween(now ?? DateTime.now(), d);
  if (days == 0) return 'bugün';
  if (days == 1) return 'yarın';
  if (days > 1 && days < 7) {
    return trLower(trWeekdays[d.weekday - 1]);
  }
  return '${d.day} ${trMonths[d.month - 1]}';
}
