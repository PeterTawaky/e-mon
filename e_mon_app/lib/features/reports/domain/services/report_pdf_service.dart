import 'dart:io';

import 'package:e_mon_app/core/utils/app_assets.dart';
import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

class ReportPdfService {
  Future<File> saveReport(EnergyReport report) async {
    final document = pw.Document();
    final companyLogo = await _loadImage(Assets.imagesLogo);
    final appLogo = await _loadImage(Assets.imagesAppLogo);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) {
          return [
            _buildHeader(companyLogo: companyLogo, appLogo: appLogo),
            pw.SizedBox(height: 24),
            _buildMeta(report),
            pw.SizedBox(height: 20),
            _buildTable(report),
            pw.SizedBox(height: 18),
            _buildTotals(report),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final reportsDirectory = Directory('${directory.path}/WattWise Reports');
    if (!reportsDirectory.existsSync()) {
      reportsDirectory.createSync(recursive: true);
    }

    final fileName =
        '${report.kind.label.replaceAll(' ', '_')}_${_fileStamp(report.extractedAt)}.pdf';
    final file = File('${reportsDirectory.path}/$fileName');
    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<void> openReport(File file) async {
    final uri = Uri.file(file.path);
    await launchUrl(uri);
  }

  Future<pw.MemoryImage> _loadImage(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  pw.Widget _buildHeader({
    required pw.MemoryImage companyLogo,
    required pw.MemoryImage appLogo,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#14B8A6'), width: 1),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Image(companyLogo, width: 54, height: 54),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HA Technology',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Energy intelligence report',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'WattWise',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#0D9488'),
                    ),
                  ),
                  pw.Text(
                    'Live consumption analytics',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(width: 12),
              pw.Image(appLogo, width: 54, height: 54),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMeta(EnergyReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#CCFBF1'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _metaItem('Report', report.kind.label),
          _metaItem('Tier mode', report.tierMode.label),
          _metaItem('Extracted at', _formatDateTime(report.extractedAt)),
          _metaItem('Readings', report.readingsCount.toString()),
        ],
      ),
    );
  }

  pw.Widget _metaItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildTable(EnergyReport report) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#99F6E4')),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#14B8A6')),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      headers: ['Time Period', _reportDateRange(report), 'Rate', 'Charge'],
      data: report.rows.map((row) {
        return [
          row.timePeriod,
          '${row.summationValue.toStringAsFixed(2)} kWh',
          row.rate.toStringAsFixed(2),
          row.charge.toStringAsFixed(2),
        ];
      }).toList(),
    );
  }

  pw.Widget _buildTotals(EnergyReport report) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 240,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#14B8A6')),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          children: [
            _totalRow(
              'Total usage',
              '${report.totalUsage.toStringAsFixed(2)} kWh',
            ),
            pw.Divider(color: PdfColor.fromHex('#14B8A6')),
            _totalRow('Total charge', report.totalCharge.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime value) {
    return '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)} '
        '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
  }

  String _reportDateRange(EnergyReport report) {
    if (report.rows.isEmpty) {
      return 'Date Range';
    }
    return report.rows.first.dateRange;
  }

  String _fileStamp(DateTime value) {
    return '${value.year}${_twoDigits(value.month)}${_twoDigits(value.day)}_'
        '${_twoDigits(value.hour)}${_twoDigits(value.minute)}${_twoDigits(value.second)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
