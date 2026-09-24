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

/// "Perşembe, 24 Eylül": the date above a home screen's greeting.
String formatTodayLabel(DateTime d) =>
    '${trWeekdays[d.weekday - 1]}, ${d.day} ${trMonths[d.month - 1]}';
