import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

enum ExportFormat { pdf, csv }

class ReportExportService {
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static Future<void> exportReport({
    required BuildContext context,
    required ExportFormat format,
    required List<Map<String, dynamic>> transactions,
    required double total,
    required String reportTitle,
    required String dateRange,
    required List<double> trendBars,
  }) async {
    if (format == ExportFormat.pdf) {
      await _exportToPDF(
        context: context,
        transactions: transactions,
        total: total,
        reportTitle: reportTitle,
        dateRange: dateRange,
        trendBars: trendBars,
      );
    } else {
      await _exportToCSV(
        context: context,
        transactions: transactions,
        total: total,
        reportTitle: reportTitle,
      );
    }
  }

  static Future<void> _exportToPDF({
    required BuildContext context,
    required List<Map<String, dynamic>> transactions,
    required double total,
    required String reportTitle,
    required String dateRange,
    required List<double> trendBars,
  }) async {
    final pdf = pw.Document();

    // Use built-in font
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Brand colors
    final primaryColor = PdfColor.fromInt(0xFF38CAC7);
    final darkColor = PdfColor.fromInt(0xFF1D2330);
    final greyColor = PdfColor.fromInt(0xFF9AA0AF);
    final whiteColor = PdfColor.fromInt(0xFFFFFFFF);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Expense Report'.tr,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      dateRange,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '\$',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        build: (context) {
          return [
            // Summary Card
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('TOTAL EXPENSES'.tr,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 12,
                      color: whiteColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 36,
                      color: whiteColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${transactions.length} transactions',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColor.fromInt(0xFFFFFFFF).alpha < 1
                          ? PdfColor.fromInt(0xFFFFFFFF)
                          : PdfColor(1, 1, 1, 0.8),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            if (trendBars.isNotEmpty) ...[
              pw.Text('Expense Trend'.tr,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  color: darkColor,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF8F9FA),
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFEDEFF5)),
                ),
                child: pw.Container(
                  height: 120,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: List.generate(trendBars.length, (i) {
                      final h = (trendBars[i].clamp(0.1, 1.0)) * 100;
                      final isActive = i == 1;
                      final barColor = isActive
                          ? primaryColor
                          : PdfColor(
                              primaryColor.red,
                              primaryColor.green,
                              primaryColor.blue,
                              0.3,
                            );
                      return pw.Expanded(
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Container(
                              height: h,
                              width: 30,
                              decoration: pw.BoxDecoration(
                                color: barColor,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'W${i + 1}',
                              style: pw.TextStyle(
                                font: isActive ? fontBold : font,
                                fontSize: 10,
                                color: isActive ? darkColor : greyColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
            ],

            // Transactions Header
            pw.Text('Transaction Details'.tr,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 18,
                color: darkColor,
              ),
            ),
            pw.SizedBox(height: 16),

            // Transaction Table
            pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              border: pw.TableBorder(
                bottom: pw.BorderSide(
                  color: PdfColor(0.6, 0.63, 0.69, 0.3),
                  width: 0.5,
                ),
              ),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor(0.22, 0.79, 0.78, 0.1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  children: [
                    _tableHeader('Description', fontBold, primaryColor),
                    _tableHeader('Date', fontBold, primaryColor),
                    _tableHeader('Category', fontBold, primaryColor),
                    _tableHeader(
                      'Amount',
                      fontBold,
                      primaryColor,
                      alignRight: true,
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox(height: 8),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                  ],
                ),
                // Table Rows
                for (final txn in transactions)
                  _tableRow(
                    title: txn['title']?.toString() ?? 'Unknown',
                    date: _formatDate(txn['date']?.toString()),
                    category: txn['category']?.toString() ?? 'Other',
                    amount: _parseDouble(txn['amount']),
                    font: font,
                    fontBold: fontBold,
                    isEven: transactions.indexOf(txn) % 2 == 0,
                  ),
              ],
            ),

            pw.SizedBox(height: 40),

            // Footer
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'Generated on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                style: pw.TextStyle(font: font, fontSize: 10, color: greyColor),
              ),
            ),
          ];
        },
      ),
    );

    // Save and share
    final dir = await getTemporaryDirectory();
    final fileName =
        'expense_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Expense Report - $dateRange',
      subject: 'Expense Report',
    );
  }

  static pw.Widget _tableHeader(
    String text,
    pw.Font font,
    PdfColor color, {
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 11, color: color),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  static pw.TableRow _tableRow({
    required String title,
    required String date,
    required String category,
    required double amount,
    required pw.Font font,
    required pw.Font fontBold,
    required bool isEven,
  }) {
    return pw.TableRow(
      decoration: isEven
          ? pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF8F9FA),
              borderRadius: pw.BorderRadius.circular(4),
            )
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: pw.Text(
            title,
            style: pw.TextStyle(font: fontBold, fontSize: 11),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: pw.Text(date, style: pw.TextStyle(font: font, fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: pw.Text(
            category,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: pw.Text(
            '-\$${amount.abs().toStringAsFixed(2)}',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 11,
              color: PdfColor.fromInt(0xFFEF4444),
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static Future<void> _exportToCSV({
    required BuildContext context,
    required List<Map<String, dynamic>> transactions,
    required double total,
    required String reportTitle,
  }) async {
    final List<List<String>> csvData = [
      // Header row
      ['Expense Report'],
      [
        'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
      ],
      ['Total: \$${total.toStringAsFixed(2)}'],
      ['Transactions: ${transactions.length}'],
      [''],
      // Table headers
      [
        'ID',
        'Title',
        'Description',
        'Amount',
        'Category',
        'Date',
        'Property/Hotel',
        'Receipt',
      ],
      // Data rows
      for (final txn in transactions)
        [
          txn['id']?.toString() ?? '',
          txn['title']?.toString() ?? 'Unknown',
          txn['description']?.toString() ?? '',
          _parseDouble(txn['amount']).toStringAsFixed(2),
          txn['category']?.toString() ?? 'Other',
          _formatDate(txn['date']?.toString()),
          txn['property']?['title']?.toString() ??
              txn['hotel']?['title']?.toString() ??
              '',
          txn['receiptUrl']?.toString() ?? 'No receipt',
        ],
      [''],
      ['Summary'],
      ['Total Expenses', '\$${total.toStringAsFixed(2)}'],
      ['Transaction Count', transactions.length.toString()],
    ];

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);

    // Save and share
    final dir = await getTemporaryDirectory();
    final fileName =
        'expense_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Expense Report CSV',
      subject: 'Expense Report',
    );
  }
}
