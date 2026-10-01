import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light(AppDensity.comfortable),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(400, 800),
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('AppLoading', () {
    testWidgets('names the wait once, for the eye and the screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const AppLoading(label: 'Yükleniyor')));
      expect(find.text('Yükleniyor'), findsOneWidget);
      expect(find.bySemanticsLabel('Yükleniyor'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the card form keeps a card\'s height while waiting', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const AppLoading.card()));
      expect(
        tester.getSize(find.byType(CloudCard)).height,
        greaterThanOrEqualTo(168),
      );
    });
  });

  group('AppErrorView', () {
    testWidgets('retry is the filled main action, the way out is quiet', (
      tester,
    ) async {
      var retried = 0;
      var left = 0;
      await tester.pumpWidget(
        _host(
          AppErrorView(
            title: 'Hesap bilgileri yüklenemedi',
            message: 'Bağlantını kontrol edip tekrar dene.',
            onRetry: () => retried++,
            actionLabel: 'Çıkış yap',
            onAction: () => left++,
          ),
        ),
      );
      expect(find.widgetWithText(FilledButton, 'Tekrar dene'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Çıkış yap'), findsOneWidget);
      await tester.tap(find.text('Tekrar dene'));
      await tester.tap(find.text('Çıkış yap'));
      expect((retried, left), (1, 1));
    });

    testWidgets('without a retry there is only the quiet action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          AppErrorView(
            title: 'Bu hesap diyetisyen hesabı.',
            actionLabel: 'Çıkış yap',
            onAction: () {},
          ),
        ),
      );
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Çıkış yap'), findsOneWidget);
    });

    testWidgets('the card form sits in a Cloud Card, left-aligned', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.topLeft,
            child: AppErrorView.card(title: 'Yüklenemedi', onRetry: () {}),
          ),
        ),
      );
      expect(find.byType(CloudCard), findsOneWidget);
      final card = tester.getRect(find.byType(CloudCard));
      expect(
        tester.getRect(find.text('Yüklenemedi')).left,
        lessThan(card.left + 40),
      );
    });

    testWidgets('the notice is one row with a text retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _host(
          AppErrorView.notice(
            message: 'Adlar yüklenemedi.',
            onRetry: () => retried = true,
          ),
        ),
      );
      expect(find.byType(CloudCard), findsNothing);
      expect(find.widgetWithText(TextButton, 'Tekrar dene'), findsOneWidget);
      await tester.tap(find.text('Tekrar dene'));
      expect(retried, isTrue);
    });

    testWidgets('fits a small phone at 200 % text, buttons inside', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          AppErrorView(
            title: 'Hesap bilgileri yüklenemedi',
            message: 'Bağlantınızı kontrol edip tekrar deneyin.',
            onRetry: () {},
            actionLabel: 'Çıkış yap',
            onAction: () {},
          ),
          scale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      for (final label in ['Tekrar dene', 'Çıkış yap']) {
        final rect = tester.getRect(find.text(label));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(360));
      }
    });
  });

  group('EmptyState', () {
    testWidgets('shows what is missing and offers the first step', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          EmptyState(
            title: 'Henüz danışanınız yok',
            message: 'İlk davetinizi gönderin.',
            actionLabel: 'Danışan davet et',
            onAction: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Henüz danışanınız yok'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Danışan davet et'));
      expect(tapped, isTrue);
    });
  });
}
