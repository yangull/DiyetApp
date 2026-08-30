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

/// 'Ağu', for chart axes. Used where the axis used to carry a hard-coded month
/// that quietly went stale as soon as the calendar moved past it.
String formatMonthShort(DateTime d) => _monthsShort[d.month - 1];
