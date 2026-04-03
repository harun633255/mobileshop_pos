import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'memo_controller.dart';
import '../../data/models/memo_item_model.dart';
import '../../data/models/part_model.dart';

const _primary = Color(0xFF1A73E8);
const _bg = Color(0xFFF5F7FA);
const _textPrimary = Color(0xFF2C3E50);

class CreateMemoView extends GetView<MemoController> {
  const CreateMemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final customerNameCtrl = TextEditingController();
    final customerPhoneCtrl = TextEditingController();
    final discountCtrl =
        TextEditingController(text: controller.discountInput.value);
    final noteCtrl = TextEditingController();
    final partSearchCtrl = TextEditingController();

    customerNameCtrl.text = controller.customerNameInput.value;
    customerPhoneCtrl.text = controller.customerPhoneInput.value;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Create Memo',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer section
              _SectionCard(
                title: 'Customer Details',
                child: Column(
                  children: [
                    _CustomerNameField(
                      controller: customerNameCtrl,
                      memoController: controller,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customerPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) =>
                          controller.customerPhoneInput.value = v,
                      decoration: _inputDeco('Phone', Icons.phone),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Part search section
              _SectionCard(
                title: 'Add Products',
                child: Column(
                  children: [
                    TextField(
                      controller: partSearchCtrl,
                      onChanged: (v) {
                        controller.onPartSearchChanged(v);
                      },
                      decoration: _inputDeco(
                          'Search product to add...', Icons.search),
                    ),
                    Obx(() {
                      if (controller.isSearchingParts.value) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (controller.partSearchResults.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        constraints:
                            const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              controller.partSearchResults.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final part =
                                controller.partSearchResults[i];
                            return _PartSearchTile(
                              part: part,
                              onTap: () {
                                controller.addPartToMemo(part);
                                partSearchCtrl.clear();
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Items list
              Obx(() {
                if (controller.memoItems.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _SectionCard(
                  title: 'Items (${controller.memoItems.length})',
                  child: Column(
                    children: List.generate(
                      controller.memoItems.length,
                      (i) => _MemoItemRow(
                        item: controller.memoItems[i],
                        index: i,
                        controller: controller,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Totals section
              _SectionCard(
                title: 'Payment Summary',
                child: Column(
                  children: [
                    TextField(
                      controller: discountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      onChanged: (v) => controller.discountInput.value = v,
                      decoration: _inputDeco('Discount (€)', Icons.discount),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Column(
                      children: [
                        _TotalRow(
                            label: 'Subtotal',
                            value: controller.subtotal,
                            bold: false),
                        const Divider(),
                        _TotalRow(
                            label: 'Discount',
                            value: controller.discount,
                            bold: false),
                        const Divider(thickness: 1.5),
                        _TotalRow(
                            label: 'TOTAL',
                            value: controller.total,
                            bold: true),
                      ],
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Note
              _SectionCard(
                title: 'Note (optional)',
                child: TextField(
                  controller: noteCtrl,
                  onChanged: (v) => controller.noteInput.value = v,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Any additional notes...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.saveMemo,
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Save Memo',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

class _CustomerNameField extends StatefulWidget {
  final TextEditingController controller;
  final MemoController memoController;

  const _CustomerNameField({
    required this.controller,
    required this.memoController,
  });

  @override
  State<_CustomerNameField> createState() => _CustomerNameFieldState();
}

class _CustomerNameFieldState extends State<_CustomerNameField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.memoController.onCustomerNameChanged,
          decoration: const InputDecoration(
            labelText: 'Customer Name *',
            prefixIcon: Icon(Icons.person, color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        Obx(() {
          final suggestions =
              widget.memoController.customerSuggestions;
          if (suggestions.isEmpty) return const SizedBox.shrink();
          return Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                title: Text(suggestions[i]),
                leading: const Icon(Icons.person_outline, size: 18),
                onTap: () {
                  widget.controller.text = suggestions[i];
                  widget.memoController.customerNameInput.value =
                      suggestions[i];
                  widget.memoController.customerSuggestions.clear();
                  _focusNode.unfocus();
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PartSearchTile extends StatelessWidget {
  final PartModel part;
  final VoidCallback onTap;

  const _PartSearchTile({required this.part, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = part.customerPrice ?? part.price ?? 0.0;
    return ListTile(
      dense: true,
      onTap: onTap,
      title: Text(part.partName,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(part.model,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Text(
        '€${price.toStringAsFixed(2)}',
        style: const TextStyle(
            color: _primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MemoItemRow extends StatefulWidget {
  final MemoItemModel item;
  final int index;
  final MemoController controller;

  const _MemoItemRow({
    required this.item,
    required this.index,
    required this.controller,
  });

  @override
  State<_MemoItemRow> createState() => _MemoItemRowState();
}

class _MemoItemRowState extends State<_MemoItemRow> {
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
        text: widget.item.unitPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.partName ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: _textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () =>
                    widget.controller.removeItem(widget.index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Text(
            widget.item.model ?? '',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Quantity stepper
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => widget.controller
                          .updateItemQuantity(widget.index, -1),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        widget.item.quantity.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => widget.controller
                          .updateItemQuantity(widget.index, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Unit price
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  onChanged: (v) {
                    final price = double.tryParse(v);
                    if (price != null) {
                      widget.controller.updateItemPrice(
                          widget.index, price);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    prefixText: '€',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    '€${widget.item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primary,
                        fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: _primary),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _TotalRow(
      {required this.label, required this.value, required this.bold});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            '€${value.toStringAsFixed(2)}',
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
