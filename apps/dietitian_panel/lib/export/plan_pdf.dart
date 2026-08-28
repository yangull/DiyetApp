import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../demo/demo_models.dart';

/// The plan as the client receives it: a sheet to carry, stick on a fridge, or
/// read on a phone. This is the artifact a dietitian hands over today, and the
/// most concrete answer to "why would I stop using Excel".
///
/// Only approved plans reach this file. That is locked decision §2 #1 applied
/// at one more boundary — an unapproved AI draft must not become a document
/// that can be sent, printed, or forwarded.

/// The PDF's own fonts must carry Turkish glyphs; the built-in Helvetica does
/// not. Reuses the bundled faces from `core` rather than fetching anything.
Future<pw.ThemeData> _theme() async {
  final regular = await rootBundle.load(
    'packages/core/fonts/Figtree-Regular.ttf',
  );
  final semiBold = await rootBundle.load(
    'packages/core/fonts/Figtree-SemiBold.ttf',
  );
  return pw.ThemeData.withFont(
    base: pw.Font.ttf(regular),
    bold: pw.Font.ttf(semiBold),
  );
}

const _ink = PdfColor.fromInt(0xFF1A2B26);
const _muted = PdfColor.fromInt(0xFF6B7C76);
const _rule = PdfColor.fromInt(0xFFDAE4E0);

Future<Uint8List> buildPlanPdf({
  required DemoClient client,
  required DietPlan plan,
  required int targetKcal,
}) async {
  final doc = pw.Document(theme: await _theme());

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => _header(client, plan.day, context.pageNumber),
      footer: (context) => _footer(),
      build: (context) => [
        _summary('${plan.kcal} kcal', targetKcal),
        pw.SizedBox(height: 18),
        for (final meal in plan.meals) ...[
          _mealHeading(meal.name, meal.time),
          for (final item in meal.items)
            if (item.food.trim().isNotEmpty)
              _row(item.food, item.amount)
            else if (item.amount.trim().isNotEmpty)
              _row('—', item.amount),
          pw.SizedBox(height: 14),
        ],
      ],
    ),
  );

  return doc.save();
}

Future<Uint8List> buildExchangePlanPdf({
  required DemoClient client,
  required ExchangePlan plan,
  required int targetKcal,
}) async {
  final doc = pw.Document(theme: await _theme());

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => _header(client, plan.day, context.pageNumber),
      footer: (context) => _footer(),
      build: (context) => [
        _summary('${plan.kcal} kcal', targetKcal),
        pw.SizedBox(height: 18),
        for (final meal in plan.meals) ...[
          _mealHeading(meal.name, meal.time),
          for (final line in meal.lines)
            if (line.count > 0)
              _row(
                kExchangeGroupLabels[line.group] ?? line.group.name,
                '${line.count} değişim',
              ),
          pw.SizedBox(height: 14),
        ],
        // Counts alone are unusable away from the panel: the client needs to
        // know what one exchange looks like on a plate.
        pw.SizedBox(height: 10),
        pw.Text(
          'Değişim listesi',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Bir grubun içindeki her seçenek birbirinin yerine geçer.',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
        pw.SizedBox(height: 10),
        for (final group in ExchangeGroup.values)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  kExchangeGroupLabels[group] ?? group.name,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  (kExchangeFoods[group] ?? const []).join(' · '),
                  style: const pw.TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _header(DemoClient client, String day, int pageNumber) {
  if (pageNumber > 1) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(
        '${client.name} · $day',
        style: const pw.TextStyle(fontSize: 9, color: _muted),
      ),
    );
  }
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 18),
    padding: const pw.EdgeInsets.only(bottom: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.8)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Beslenme programı',
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '${client.name} · $day',
          style: pw.TextStyle(
            fontSize: 19,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _footer() => pw.Container(
  alignment: pw.Alignment.centerLeft,
  margin: const pw.EdgeInsets.only(top: 12),
  child: pw.Text(
    'Diyetisyeniniz tarafından onaylandı. Sorularınızı uygulama '
    'üzerinden iletebilirsiniz.',
    style: const pw.TextStyle(fontSize: 8, color: _muted),
  ),
);

pw.Widget _summary(String planned, int targetKcal) => pw.Row(
  children: [
    _figure('Günlük toplam', planned),
    pw.SizedBox(width: 28),
    _figure('Hesaplanan ihtiyaç', '$targetKcal kcal'),
  ],
);

pw.Widget _figure(String label, String value) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text(
      label.toUpperCase(),
      style: const pw.TextStyle(fontSize: 7, color: _muted),
    ),
    pw.SizedBox(height: 2),
    pw.Text(
      value,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  ],
);

pw.Widget _mealHeading(String name, String time) => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 6),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Text(
        name,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: _ink,
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Text(time, style: const pw.TextStyle(fontSize: 9, color: _muted)),
    ],
  ),
);

pw.Widget _row(String left, String right) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 3, left: 2),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 5,
        child: pw.Text(left, style: const pw.TextStyle(fontSize: 10)),
      ),
      pw.Expanded(
        flex: 3,
        child: pw.Text(
          right,
          style: const pw.TextStyle(fontSize: 10, color: _muted),
        ),
      ),
    ],
  ),
);
