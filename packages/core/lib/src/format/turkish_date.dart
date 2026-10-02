/// Turkish day and month names, shared by both apps so a date reads the same
/// on the client's Bugün and the dietitian's Genel Bakış.
const trWeekdays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

const trMonths = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// Short month names for dates in lists and chart axes ("28 Eyl").
const trMonthsShort = [
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

/// "Perşembe, 24 Eylül": the date above a home screen's greeting.
String formatTodayLabel(DateTime d) =>
    '${trWeekdays[d.weekday - 1]}, ${d.day} ${trMonths[d.month - 1]}';
