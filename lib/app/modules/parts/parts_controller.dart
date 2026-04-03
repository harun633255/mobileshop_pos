import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/part_model.dart';

class PartsController extends GetxController {
  final _db = DatabaseHelper();

  final parts = <PartModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;

  final categories = [
    'All',
    'Display',
    'Battery',
    'Charger',
    'Camera',
    'Speaker',
    'Other'
  ];

  Timer? _debounceTimer;

  // For add/edit form
  final editingPart = Rxn<PartModel>();

  @override
  void onInit() {
    super.onInit();
    loadParts();
    ever(selectedCategory, (_) => loadParts());
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      loadParts();
    });
  }

  Future<void> loadParts() async {
    try {
      isLoading.value = true;
      final result = await _db.getAllParts(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        category:
            selectedCategory.value == 'All' ? null : selectedCategory.value,
      );
      parts.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load parts: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void startAddPart() {
    editingPart.value = null;
    Get.toNamed('/add-part');
  }

  void startEditPart(PartModel part) {
    editingPart.value = part;
    Get.toNamed('/edit-part');
  }

  Future<void> savePart({
    required String model,
    required String partName,
    required String price,
    required String customerPrice,
    required String tudoPrice,
    required String category,
  }) async {
    if (model.trim().isEmpty) {
      Get.snackbar('Validation', 'Model name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (partName.trim().isEmpty) {
      Get.snackbar('Validation', 'Part name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final now = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

      if (editingPart.value == null) {
        final part = PartModel(
          model: model.trim(),
          partName: partName.trim(),
          price: double.tryParse(price),
          customerPrice: double.tryParse(customerPrice),
          tudoPrice: double.tryParse(tudoPrice),
          category: category,
          createdAt: now,
          updatedAt: now,
        );
        await _db.insertPart(part);
        Get.snackbar('Success', 'Part added successfully',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        final part = editingPart.value!.copyWith(
          model: model.trim(),
          partName: partName.trim(),
          price: double.tryParse(price),
          customerPrice: double.tryParse(customerPrice),
          tudoPrice: double.tryParse(tudoPrice),
          category: category,
          updatedAt: now,
        );
        await _db.updatePart(part);
        Get.snackbar('Success', 'Part updated successfully',
            snackPosition: SnackPosition.BOTTOM);
      }

      await loadParts();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save part: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmDeletePart(int id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Part'),
        content: const Text(
            'Are you sure you want to delete this part? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935)),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deletePart(id);
    }
  }

  Future<void> _deletePart(int id) async {
    try {
      await _db.deletePart(id);
      await loadParts();
      Get.snackbar('Deleted', 'Part deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
