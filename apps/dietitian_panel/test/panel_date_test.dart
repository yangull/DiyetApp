import 'package:dietitian_panel/util/panel_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final friday = DateTime(2026, 9, 25, 9, 30);

  test('agenda headings name today, tomorrow and later days', () {
    expect(formatDayHeading(DateTime(2026, 9, 25, 11), now: friday), 'Bugün');
    expect(
      formatDayHeading(DateTime(2026, 9, 26, 10), now: friday),
      'Yarın · Cumartesi 26 Eylül',
    );
    expect(
      formatDayHeading(DateTime(2026, 9, 28, 11, 30), now: friday),
      'Pazartesi 28 Eylül',
    );
  });

  test('a day inside a sentence is lower case within the week', () {
    expect(
      formatDayInSentence(DateTime(2026, 9, 25, 23), now: friday),
      'bugün',
    );
    expect(formatDayInSentence(DateTime(2026, 9, 26), now: friday), 'yarın');
    expect(formatDayInSentence(DateTime(2026, 9, 29), now: friday), 'salı');
    expect(formatDayInSentence(DateTime(2026, 10, 2), now: friday), '2 Ekim');
  });

  // The day the clocks go forward in Europe has 23 hours, which a browser in
  // a DST time zone sees even though Turkey has none. This only bites when
  // the test machine's own time zone changes its clocks.
  test('tomorrow stays tomorrow across a clock change', () {
    final morning = DateTime(2027, 3, 28, 9);
    expect(formatDayInSentence(DateTime(2027, 3, 29), now: morning), 'yarın');
    expect(
      formatDayHeading(DateTime(2027, 3, 29), now: morning),
      startsWith('Yarın'),
    );
  });

  test(
    'formatDate is one format: day and short month, the year only if not now',
    () {
      final now = DateTime(2026, 10, 2);
      expect(formatDate(DateTime(2026, 9, 28), now: now), '28 Eyl');
      expect(formatDate(DateTime(2025, 12, 5), now: now), '5 Ara 2025');
    },
  );
}
