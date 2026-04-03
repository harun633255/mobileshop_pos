import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/database_helper.dart';
import '../../utils/pdf_generator.dart';

class SettingsController extends GetxController {
  final _db = DatabaseHelper();

  final shopName = 'My Mobile Shop'.obs;
  final shopPhone = ''.obs;
  final shopAddress = ''.obs;

  // Bluetooth
  final isBluetoothConnected = false.obs;
  final connectedDeviceName = ''.obs;
  final isScanningBluetooth = false.obs;

  // Bulk price update
  final bulkPercentage = ''.obs;

  static const _keyShopName = 'shop_name';
  static const _keyShopPhone = 'shop_phone';
  static const _keyShopAddress = 'shop_address';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      shopName.value = prefs.getString(_keyShopName) ?? 'My Mobile Shop';
      shopPhone.value = prefs.getString(_keyShopPhone) ?? '';
      shopAddress.value = prefs.getString(_keyShopAddress) ?? '';
    } catch (_) {}
  }

  Future<void> saveSettings({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyShopName, name);
      await prefs.setString(_keyShopPhone, phone);
      await prefs.setString(_keyShopAddress, address);
      shopName.value = name;
      shopPhone.value = phone;
      shopAddress.value = address;
      Get.snackbar('Success', 'Settings saved',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> scanBluetoothDevices() async {
    if (!Platform.isAndroid) {
      Get.snackbar('Info',
          'Bluetooth printing is only supported on Android',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.snackbar('Info',
        'Pair your thermal printer via Android Bluetooth settings, then reconnect.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4));
  }

  Future<void> disconnectBluetooth() async {
    isBluetoothConnected.value = false;
    connectedDeviceName.value = '';
    Get.snackbar('Disconnected', 'Printer disconnected',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> showBulkPriceUpdateDialog() async {
    final textController = TextEditingController();
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Bulk Price Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Enter % to increase customer prices.\nExample: 10 = 10% increase'),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Percentage (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bulkPercentage.value = textController.text;
      await _applyBulkPriceUpdate();
    }
    textController.dispose();
  }

  Future<void> _applyBulkPriceUpdate() async {
    try {
      final pct = double.tryParse(bulkPercentage.value);
      if (pct == null) {
        Get.snackbar('Error', 'Invalid percentage',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final multiplier = 1 + (pct / 100);
      await _db.bulkUpdateCustomerPrice(multiplier);
      Get.snackbar(
        'Success',
        'Customer prices updated by ${pct.toStringAsFixed(1)}%',
        snackPosition: SnackPosition.BOTTOM,
      );
      bulkPercentage.value = '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to update prices: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> exportPriceList() async {
    try {
      final parts = await _db.getAllParts();
      final partsMap = parts
          .map((p) => {
                'model': p.model,
                'part_name': p.partName,
                'price': p.price ?? 0.0,
                'customer_price': p.customerPrice ?? 0.0,
              })
          .toList();
      await PdfGenerator.exportAllPartsAsPdf(partsMap);
    } catch (e) {
      Get.snackbar('Error', 'Export failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
