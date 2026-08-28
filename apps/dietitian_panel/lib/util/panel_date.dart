/// The panel's one date format: dd.MM.yyyy.
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.'
    '${d.year}';

/// dd.MM, for contexts where the year is implied (this week's appointments).
String formatDayMonth(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}';
