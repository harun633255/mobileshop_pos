import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/memo_model.dart';

class CustomerController extends GetxController {
  final _db = DatabaseHelper();

  final customers = <CustomerModel>[].obs;
  final customerMemos = <MemoModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
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
      loadCustomers();
    });
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final result = await _db.getAllCustomers(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      customers.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load customers: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomerMemos(int customerId) async {
    try {
      isLoading.value = true;
      customerMemos.value = await _db.getMemosByCustomer(customerId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load memos: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showAddCustomerDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar('Validation', 'Customer name is required',
            snackPosition: SnackPosition.BOTTOM);
        nameController.dispose();
        phoneController.dispose();
        addressController.dispose();
        return;
      }
      await _saveCustomer(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );
    }

    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }

  Future<void> _saveCustomer({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final now = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      final customer = CustomerModel(
        name: name,
        phone: phone.isEmpty ? null : phone,
        address: address.isEmpty ? null : address,
        createdAt: now,
      );
      await _db.insertCustomer(customer);
      await loadCustomers();
      Get.snackbar('Success', 'Customer added',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save customer: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> confirmDeleteCustomer(int id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure? This cannot be undone.'),
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
      try {
        await _db.deleteCustomer(id);
        await loadCustomers();
        Get.snackbar('Deleted', 'Customer deleted',
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}
