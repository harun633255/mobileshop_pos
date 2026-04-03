import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/memo_model.dart';
import '../data/models/memo_item_model.dart';
import '../modules/settings/settings_controller.dart';

class PdfGenerator {
  static final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  static pw.Widget _buildHeader(SettingsController settings,
      pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          settings.shopName.value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        if (settings.shopPhone.value.isNotEmpty)
          pw.Text(
            'Phone: ${settings.shopPhone.value}',
            style: pw.TextStyle(font: font, fontSize: 11),
            textAlign: pw.TextAlign.center,
          ),
        if (settings.shopAddress.value.isNotEmpty)
          pw.Text(
            settings.shopAddress.value,
            style: pw.TextStyle(font: font, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _buildMemoInfo(MemoModel memo, pw.Font font) {
    final date = memo.createdAt != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(memo.createdAt!))
        : DateFormat('dd MMM yyyy').format(DateTime.now());
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Memo: ${memo.memoNumber ?? ''}',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: $date',
                style: pw.TextStyle(font: font, fontSize: 11)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text('Customer: ${memo.customerName ?? 'N/A'}',
            style: pw.TextStyle(font: font, fontSize: 11)),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildItemsTable(
      List<MemoItemModel> items, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableCell('Part Name', boldFont, bold: true),
            _tableCell('Qty', boldFont,
                bold: true, align: pw.TextAlign.center),
            _tableCell('Unit Price', boldFont,
                bold: true, align: pw.TextAlign.right),
            _tableCell('Total', boldFont,
                bold: true, align: pw.TextAlign.right),
          ],
        ),
        ...items.map((item) => pw.TableRow(
              children: [
                _tableCell(item.partName ?? '', font),
                _tableCell(item.quantity.toString(), font,
                    align: pw.TextAlign.center),
                _tableCell(
                    _currencyFormat.format(item.unitPrice), font,
                    align: pw.TextAlign.right),
                _tableCell(
                    _currencyFormat.format(item.totalPrice), font,
                    align: pw.TextAlign.right),
              ],
            )),
      ],
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font,
      {bool bold = false,
      pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          fontWeight:
              bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildTotals(
      MemoModel memo, pw.Font font, pw.Font boldFont) {
    final subtotal = memo.subtotal ?? 0.0;
    final discount = memo.discount ?? 0.0;
    final total = memo.total ?? 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(height: 8),
        _totalRow('Subtotal:', subtotal, font),
        if (discount > 0) _totalRow('Discount:', discount, font),
        pw.Divider(thickness: 0.5),
        _totalRow('Total:', total, boldFont, bold: true, fontSize: 13),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(
      String label, double amount, pw.Font font,
      {bool bold = false, double fontSize = 11}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize,
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
          pw.SizedBox(width: 16),
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              _currencyFormat.format(amount),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                  font: font,
                  fontSize: fontSize,
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  static Future<pw.Document> _buildDocument(
      MemoModel memo, List<MemoItemModel> items) async {
    // Use built-in Helvetica fonts (offline-compatible)
    final font = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();
    final settings = Get.find<SettingsController>();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(settings, font, boldFont),
              pw.SizedBox(height: 12),
              _buildMemoInfo(memo, font),
              _buildItemsTable(items, font, boldFont),
              _buildTotals(memo, font, boldFont),
              if (memo.note != null && memo.note!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text('Note: ${memo.note}',
                    style: pw.TextStyle(font: font, fontSize: 10)),
              ],
            ],
          );
        },
      ),
    );
    return pdf;
  }

  static Future<void> printMemo(
      MemoModel memo, List<MemoItemModel> items) async {
    try {
      final pdf = await _buildDocument(memo, items);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Invoice_${memo.memoNumber}',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to print: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<String?> savePdf(
      MemoModel memo, List<MemoItemModel> items) async {
    try {
      final pdf = await _buildDocument(memo, items);
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'Invoice_${memo.memoNumber?.replaceAll('#', '')}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save PDF: $e',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  static Future<void> sharePdf(
      MemoModel memo, List<MemoItemModel> items) async {
    try {
      final path = await savePdf(memo, items);
      if (path != null) {
        await Share.shareXFiles(
          [XFile(path)],
          text:
              'Invoice ${memo.memoNumber} for ${memo.customerName ?? 'Customer'}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to share: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> exportAllPartsAsPdf(
      List<Map<String, dynamic>> parts) async {
    try {
      final font = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();
      final settings = Get.find<SettingsController>();

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(settings, font, boldFont),
            pw.SizedBox(height: 12),
            pw.Text('Price List',
                style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  width: 0.5, color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Model', boldFont, bold: true),
                    _tableCell('Part Name', boldFont, bold: true),
                    _tableCell('Price', boldFont,
                        bold: true, align: pw.TextAlign.right),
                    _tableCell('Customer Price', boldFont,
                        bold: true, align: pw.TextAlign.right),
                  ],
                ),
                ...parts.map((p) => pw.TableRow(
                      children: [
                        _tableCell(p['model'] ?? '', font),
                        _tableCell(p['part_name'] ?? '', font),
                        _tableCell(
                          _currencyFormat.format(p['price'] ?? 0.0),
                          font,
                          align: pw.TextAlign.right,
                        ),
                        _tableCell(
                          _currencyFormat
                              .format(p['customer_price'] ?? 0.0),
                          font,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      );
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Price_List',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to export: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Format memo as plain text for thermal receipt printer
  static String formatThermalReceipt(MemoModel memo,
      List<MemoItemModel> items, SettingsController settings) {
    final sb = StringBuffer();
    const line = '================================';
    const thinLine = '--------------------------------';
    final date = memo.createdAt != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(memo.createdAt!))
        : DateFormat('dd MMM yyyy').format(DateTime.now());

    sb.writeln(line);
    sb.writeln(_center(settings.shopName.value, 32));
    if (settings.shopPhone.value.isNotEmpty) {
      sb.writeln(_center('Ph: ${settings.shopPhone.value}', 32));
    }
    sb.writeln(line);
    sb.writeln('Memo: ${memo.memoNumber}   Date: $date');
    sb.writeln('Customer: ${memo.customerName ?? 'N/A'}');
    sb.writeln(thinLine);
    sb.writeln(
        '${'Item'.padRight(18)}${'Qty'.padLeft(3)}${'Total'.padLeft(11)}');
    sb.writeln(thinLine);

    for (final item in items) {
      final name = (item.partName ?? '').length > 18
          ? (item.partName ?? '').substring(0, 18)
          : (item.partName ?? '');
      sb.writeln(
          '${name.padRight(18)}${item.quantity.toString().padLeft(3)}${_currencyFormat.format(item.totalPrice).padLeft(11)}');
    }

    sb.writeln(thinLine);
    sb.writeln(
        '${'Subtotal:'.padRight(21)}${_currencyFormat.format(memo.subtotal ?? 0).padLeft(11)}');
    if ((memo.discount ?? 0) > 0) {
      sb.writeln(
          '${'Discount:'.padRight(21)}${_currencyFormat.format(memo.discount ?? 0).padLeft(11)}');
    }
    sb.writeln(
        '${'TOTAL:'.padRight(21)}${_currencyFormat.format(memo.total ?? 0).padLeft(11)}');
    sb.writeln(line);
    sb.writeln(_center('Thank you!', 32));
    sb.writeln(line);
    sb.writeln('');
    sb.writeln('');
    return sb.toString();
  }

  static String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }
}
