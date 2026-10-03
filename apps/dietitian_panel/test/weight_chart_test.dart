import 'package:dietitian_panel/widgets/weight_chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool overlap(double aTop, double aH, double bTop, double bH) =>
      aTop < bTop + bH && bTop < aTop + aH;

  test('"hedef" stays on its line when nothing is there', () {
    final top = targetLabelTop(
      targetY: 200,
      labelHeight: 14,
      valueTop: 40,
      valueHeight: 18,
    );
    expect(top, 193);
  });

  // A narrow card at 2x text drew "5 Ağu" over "30 Eyl".
  test('the start date shows only where it clears the end date', () {
    expect(
      startDateFits(plotLeft: 40, plotRight: 400, startWidth: 50, endWidth: 50),
      isTrue,
    );
    expect(
      startDateFits(plotLeft: 40, plotRight: 140, startWidth: 50, endWidth: 50),
      isFalse,
    );
  });

  // Zeynep: 58,2 kg right above a 58,0 target drew both labels in one spot.
  test('"hedef" moves off a weight label close to the target', () {
    for (final valueTop in [180.0, 186.0, 192.0, 198.0, 205.0]) {
      final top = targetLabelTop(
        targetY: 200,
        labelHeight: 14,
        valueTop: valueTop,
        valueHeight: 18,
      );
      expect(overlap(top, 14, valueTop, 18), isFalse, reason: '$valueTop');
    }
  });
}
