import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/database/database_helper.dart';
import '../data/models/part_model.dart';

class ExcelImporter {
  static final _db = DatabaseHelper();
  static final _dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  static Future<void> importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        Get.snackbar(
          'Error',
          'No sheets found in the Excel file',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      if (sheet.rows.isEmpty) {
        Get.snackbar(
          'Warning',
          'The Excel sheet is empty',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final List<PartModel> parts = [];
      final now = _dateFormat.format(DateTime.now());

      // Start from row index 1 to skip header row
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        // Skip empty rows
        if (row.isEmpty) continue;

        final model = _getCellString(row, 0);
        final partName = _getCellString(row, 1);

        // Skip rows without model or part name
        if (model.isEmpty && partName.isEmpty) continue;

        final price = _getCellDouble(row, 2);
        final customerPrice = _getCellDouble(row, 3);
        final tudoPrice = _getCellDouble(row, 4);

        parts.add(PartModel(
          model: model,
          partName: partName,
          price: price,
          customerPrice: customerPrice,
          tudoPrice: tudoPrice,
          category: 'Other',
          createdAt: now,
          updatedAt: now,
        ));
      }

      if (parts.isEmpty) {
        Get.snackbar(
          'Warning',
          'No valid parts found in the Excel file',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final count = await _db.bulkInsertParts(parts);

      Get.snackbar(
        'Success',
        'Imported $count parts successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        duration: const Duration(seconds: 3),
      );
    } on FileSystemException catch (e) {
      Get.snackbar(
        'Error',
        'Cannot read file: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Import failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static String _getCellString(List<Data?> row, int index) {
    if (index >= row.length) return '';
    final cell = row[index];
    if (cell == null) return '';
    final value = cell.value;
    if (value == null) return '';
    return value.toString().trim();
  }

  static double? _getCellDouble(List<Data?> row, int index) {
    if (index >= row.length) return null;
    final cell = row[index];
    if (cell == null) return null;
    final value = cell.value;
    if (value == null) return null;
    if (value is DoubleCellValue) return value.value;
    if (value is IntCellValue) return value.value.toDouble();
    return double.tryParse(value.toString().trim());
  }
}
