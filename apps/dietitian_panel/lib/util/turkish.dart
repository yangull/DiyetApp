/// Dart's toUpperCase follows English rules, so "Beslenme tipi" became
/// "BESLENME TIPI". Turkish dotted and dotless i are mapped first.
String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// The other direction: "YILMAZ" becomes "yılmaz", not "yilmaz", so a
/// search typed in capitals still finds the name.
String trLower(String s) =>
    s.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

/// Turkish writes a decimal comma: 72,4 kg, not 72.4 kg.
String formatDecimal(num value, [int digits = 1]) =>
    value.toStringAsFixed(digits).replaceAll('.', ',');
