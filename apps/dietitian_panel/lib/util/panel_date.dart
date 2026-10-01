import 'package:core/core.dart';

/// The panel's one date format: dd.MM.yyyy.
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.'
    '${d.year}';

/// dd.MM, for contexts where the year is implied (this week's appointments).
String formatDayMonth(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}';

/// HH:mm, for a message timeline where only the time of day matters.
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

const _monthsShort = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

/// '4 Ağu', for chart axes: the endpoints of a date-spaced series.
String formatDayMonthShort(DateTime d) =>
    '${d.day} ${_monthsShort[d.month - 1]}';

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
