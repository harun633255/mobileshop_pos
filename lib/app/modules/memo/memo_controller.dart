import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/memo_model.dart';
import '../../data/models/memo_item_model.dart';
import '../../data/models/part_model.dart';
import '../../utils/pdf_generator.dart';

class MemoController extends GetxController {
  final _db = DatabaseHelper();

  // ── History list ────────────────────────────────────────────────────────
  final memos = <MemoModel>[].obs;
  final isLoading = false.obs;
  final historySearch = ''.obs;
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  Timer? _historyDebounce;

  // ── Create memo ─────────────────────────────────────────────────────────
  final memoItems = <MemoItemModel>[].obs;
  final customerNameInput = ''.obs;
  final customerPhoneInput = ''.obs;
  final discountInput = '0'.obs;
  final noteInput = ''.obs;
  final partSearchQuery = ''.obs;
  final partSearchResults = <PartModel>[].obs;
  final isSearchingParts = false.obs;
  final customerSuggestions = <String>[].obs;

  Timer? _partSearchDebounce;
  Timer? _customerSearchDebounce;

  // ── Preview ─────────────────────────────────────────────────────────────
  final previewMemo = Rxn<MemoModel>();
  final previewItems = <MemoItemModel>[].obs;
  final isShareLoading = false.obs;

  // ── Computed ─────────────────────────────────────────────────────────────
  double get subtotal =>
      memoItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discount => double.tryParse(discountInput.value) ?? 0.0;

  double get total => subtotal - discount;

  @override
  void onInit() {
    super.onInit();
    loadMemos();
  }

  @override
  void onClose() {
    _historyDebounce?.cancel();
    _partSearchDebounce?.cancel();
    _customerSearchDebounce?.cancel();
    super.onClose();
  }

  // ── History methods ──────────────────────────────────────────────────────

  void onHistorySearchChanged(String q) {
    _historyDebounce?.cancel();
    _historyDebounce = Timer(const Duration(milliseconds: 300), () {
      historySearch.value = q;
      loadMemos();
    });
  }

  Future<void> loadMemos() async {
    try {
      isLoading.value = true;
      final df = DateFormat('yyyy-MM-dd');
      final result = await _db.getAllMemos(
        search: historySearch.value.isEmpty ? null : historySearch.value,
        fromDate: fromDate.value != null ? df.format(fromDate.value!) : null,
        toDate: toDate.value != null ? df.format(toDate.value!) : null,
      );
      memos.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load memos: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void clearDateFilter() {
    fromDate.value = null;
    toDate.value = null;
    loadMemos();
  }

  Future<void> openMemoPreview(MemoModel memo) async {
    try {
      isLoading.value = true;
      final items = await _db.getMemoItems(memo.id!);
      previewMemo.value = memo;
      previewItems.value = items;
      Get.toNamed('/memo-preview');
    } catch (e) {
      Get.snackbar('Error', 'Failed to open memo: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmDeleteMemo(int id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Memo'),
        content:
            const Text('Are you sure you want to delete this memo?'),
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
        await _db.deleteMemo(id);
        await loadMemos();
        Get.snackbar('Deleted', 'Memo deleted',
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  // ── Create memo methods ──────────────────────────────────────────────────

  void startCreateMemo() {
    memoItems.clear();
    customerNameInput.value = '';
    customerPhoneInput.value = '';
    discountInput.value = '0';
    noteInput.value = '';
    partSearchQuery.value = '';
    partSearchResults.clear();
    customerSuggestions.clear();
    Get.toNamed('/create-memo');
  }

  void onCustomerNameChanged(String query) {
    customerNameInput.value = query;
    _customerSearchDebounce?.cancel();
    _customerSearchDebounce =
        Timer(const Duration(milliseconds: 300), () async {
      if (query.length >= 2) {
        final names = await _db.getCustomerNames(query);
        customerSuggestions.value = names;
      } else {
        customerSuggestions.clear();
      }
    });
  }

  void onPartSearchChanged(String query) {
    partSearchQuery.value = query;
    _partSearchDebounce?.cancel();
    _partSearchDebounce =
        Timer(const Duration(milliseconds: 300), () async {
      if (query.length >= 2) {
        isSearchingParts.value = true;
        try {
          final results = await _db.getAllParts(search: query);
          partSearchResults.value = results;
        } finally {
          isSearchingParts.value = false;
        }
      } else {
        partSearchResults.clear();
      }
    });
  }

  void addPartToMemo(PartModel part) {
    // Check if already added — increase quantity instead
    final existingIndex =
        memoItems.indexWhere((item) => item.partId == part.id);
    if (existingIndex >= 0) {
      final existing = memoItems[existingIndex];
      final newQty = existing.quantity + 1;
      memoItems[existingIndex] = existing.copyWith(
        quantity: newQty,
        totalPrice: newQty * existing.unitPrice,
      );
    } else {
      final unitPrice = part.customerPrice ?? part.price ?? 0.0;
      memoItems.add(MemoItemModel(
        partId: part.id,
        model: part.model,
        partName: part.partName,
        quantity: 1,
        unitPrice: unitPrice,
        totalPrice: unitPrice,
      ));
    }
    partSearchQuery.value = '';
    partSearchResults.clear();
  }

  void updateItemQuantity(int index, int delta) {
    if (index < 0 || index >= memoItems.length) return;
    final item = memoItems[index];
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      removeItem(index);
      return;
    }
    memoItems[index] = item.copyWith(
      quantity: newQty,
      totalPrice: newQty * item.unitPrice,
    );
  }

  void updateItemPrice(int index, double price) {
    if (index < 0 || index >= memoItems.length) return;
    final item = memoItems[index];
    memoItems[index] = item.copyWith(
      unitPrice: price,
      totalPrice: item.quantity * price,
    );
  }

  void removeItem(int index) {
    if (index >= 0 && index < memoItems.length) {
      memoItems.removeAt(index);
    }
  }

  Future<void> saveMemo() async {
    if (memoItems.isEmpty) {
      Get.snackbar('Validation', 'Add at least one part',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (customerNameInput.value.trim().isEmpty) {
      Get.snackbar('Validation', 'Customer name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final now = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      final memoNumber = await _db.generateMemoNumber();

      final memo = MemoModel(
        memoNumber: memoNumber,
        customerName: customerNameInput.value.trim(),
        subtotal: subtotal,
        discount: discount,
        total: total,
        note: noteInput.value.trim().isEmpty ? null : noteInput.value.trim(),
        createdAt: now,
      );

      final memoId = await _db.insertMemo(memo);

      final items = memoItems
          .map((item) => item.copyWith(memoId: memoId))
          .toList();
      await _db.insertMemoItems(items);

      final savedMemo = memo.copyWith(id: memoId);
      previewMemo.value = savedMemo;
      previewItems.value = items;

      await loadMemos();

      Get.snackbar('Success', 'Memo $memoNumber saved',
          snackPosition: SnackPosition.BOTTOM);

      Get.offNamed('/memo-preview');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save memo: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Preview actions ──────────────────────────────────────────────────────

  Future<void> printMemo() async {
    if (previewMemo.value == null) return;
    await PdfGenerator.printMemo(previewMemo.value!, previewItems);
  }

  Future<void> shareMemo() async {
    if (previewMemo.value == null) return;
    try {
      isShareLoading.value = true;
      await PdfGenerator.sharePdf(previewMemo.value!, previewItems);
    } finally {
      isShareLoading.value = false;
    }
  }

  Future<void> saveMemoAsPdf() async {
    if (previewMemo.value == null) return;
    try {
      isShareLoading.value = true;
      final path =
          await PdfGenerator.savePdf(previewMemo.value!, previewItems);
      if (path != null) {
        Get.snackbar('Saved', 'PDF saved to $path',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4));
      }
    } finally {
      isShareLoading.value = false;
    }
  }
}
