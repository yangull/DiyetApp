import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uppercases the Turkish i pair correctly', () {
    expect(trUpper('Beslenme tipi'), 'BESLENME TİPİ');
    expect(trUpper('Kas kütlesi'), 'KAS KÜTLESİ');
    expect(trUpper('ılık'), 'ILIK');
  });

  test('writes decimals with a comma', () {
    expect(formatDecimal(72.4), '72,4');
    expect(formatDecimal(0.8612, 2), '0,86');
    expect(formatDecimal(80, 0), '80');
  });
}
