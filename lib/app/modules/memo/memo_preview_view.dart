import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'memo_controller.dart';
import '../../data/models/memo_item_model.dart';
import '../../modules/settings/settings_controller.dart';

const _primary = Color(0xFF1A73E8);
const _bg = Color(0xFFF5F7FA);
const _textPrimary = Color(0xFF2C3E50);

class MemoPreviewView extends GetView<MemoController> {
  const MemoPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.previewMemo.value?.memoNumber ?? 'Invoice',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            )),
        backgroundColor: _primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() => controller.isShareLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      tooltip: 'Share',
                      onPressed: controller.shareMemo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      tooltip: 'Print',
                      onPressed: controller.printMemo,
                    ),
                  ],
                )),
        ],
      ),
      body: Obx(() {
        final memo = controller.previewMemo.value;
        if (memo == null) {
          return const Center(child: Text('No memo to display'));
        }
        final items = controller.previewItems;
        final settings = Get.find<SettingsController>();
        final date = memo.createdAt != null
            ? DateFormat('dd MMM yyyy')
                .format(DateTime.parse(memo.createdAt!))
            : DateFormat('dd MMM yyyy').format(DateTime.now());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Invoice card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              settings.shopName.value,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                            if (settings.shopPhone.value.isNotEmpty)
                              Text(
                                'Phone: ${settings.shopPhone.value}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            if (settings.shopAddress.value.isNotEmpty)
                              Text(
                                settings.shopAddress.value,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Memo info
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _infoChip('Memo', memo.memoNumber ?? ''),
                          _infoChip('Date', date),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _infoChip('Customer', memo.customerName ?? 'N/A'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Items table header
                      Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: Text('Item',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text('Qty',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text('Price',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text('Total',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ),
                        ],
                      ),
                      const Divider(height: 12),

                      // Items
                      ...items.map((item) => _ItemRow(item: item)),

                      const Divider(height: 20),

                      // Totals
                      _totalRow('Subtotal', memo.subtotal ?? 0),
                      if ((memo.discount ?? 0) > 0)
                        _totalRow('Discount', memo.discount ?? 0),
                      const Divider(thickness: 1.5),
                      _totalRow('TOTAL', memo.total ?? 0, bold: true),

                      if (memo.note != null &&
                          memo.note!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.note,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  memo.note!,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Thank you for your business!',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(() => OutlinedButton.icon(
                          onPressed: controller.isShareLoading.value
                              ? null
                              : controller.saveMemoAsPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Save PDF'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                                color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                          onPressed: controller.isShareLoading.value
                              ? null
                              : controller.shareMemo,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.printMemo,
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoChip(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
                color: Colors.grey, fontSize: 13),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount, {bool bold = false}) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
              color: _textPrimary,
            ),
          ),
          Text(
            '€${fmt.format(amount)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 14,
              color: bold ? _primary : _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final MemoItemModel item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.partName ?? '',
              style:
                  const TextStyle(fontSize: 13, color: _textPrimary),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              item.quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              fmt.format(item.unitPrice),
              textAlign: TextAlign.right,
              style:
                  const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              fmt.format(item.totalPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
