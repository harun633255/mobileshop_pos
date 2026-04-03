import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parts_controller.dart';

const _primary = Color(0xFF1A73E8);
const _bg = Color(0xFFF5F7FA);

class AddEditPartView extends GetView<PartsController> {
  const AddEditPartView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingPart.value != null;
    final part = controller.editingPart.value;

    final modelCtrl =
        TextEditingController(text: isEditing ? part!.model : '');
    final partNameCtrl =
        TextEditingController(text: isEditing ? part!.partName : '');
    final priceCtrl = TextEditingController(
        text: isEditing && part!.price != null
            ? part.price!.toStringAsFixed(2)
            : '');
    final customerPriceCtrl = TextEditingController(
        text: isEditing && part!.customerPrice != null
            ? part.customerPrice!.toStringAsFixed(2)
            : '');
    final tudoPriceCtrl = TextEditingController(
        text: isEditing && part!.tudoPrice != null
            ? part.tudoPrice!.toStringAsFixed(2)
            : '');

    final selectedCategory =
        (isEditing ? part!.category ?? 'Other' : 'Other').obs;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard([
                _buildTextField(
                  controller: modelCtrl,
                  label: 'Model Name *',
                  hint: 'e.g. iPhone 14 Pro',
                  icon: Icons.phone_android,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: partNameCtrl,
                  label: 'Product Name *',
                  hint: 'e.g. Display Assembly',
                  icon: Icons.construction,
                ),
              ]),
              const SizedBox(height: 12),
              _buildCard([
                const Text(
                  'Category',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: selectedCategory.value,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: controller.categories
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) selectedCategory.value = v;
                      },
                    )),
              ]),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: priceCtrl,
                  label: 'Base Price (€)',
                  hint: '0.00',
                  icon: Icons.attach_money,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: customerPriceCtrl,
                  label: 'Customer Price (€)',
                  hint: '0.00',
                  icon: Icons.person,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: tudoPriceCtrl,
                  label: 'Tudo Price (€)',
                  hint: '0.00',
                  icon: Icons.store,
                  isNumber: true,
                ),
              ]),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  controller.savePart(
                                    model: modelCtrl.text,
                                    partName: partNameCtrl.text,
                                    price: priceCtrl.text,
                                    customerPrice: customerPriceCtrl.text,
                                    tudoPrice: tudoPriceCtrl.text,
                                    category: selectedCategory.value,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : Text(
                                  isEditing ? 'Update Product' : 'Save Product',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textCapitalization: isNumber
          ? TextCapitalization.none
          : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
