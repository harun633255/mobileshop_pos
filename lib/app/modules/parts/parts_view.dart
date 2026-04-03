import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parts_controller.dart';

const _primary = Color(0xFF1A73E8);
const _bg = Color(0xFFF5F7FA);
const _textPrimary = Color(0xFF2C3E50);

/// No Scaffold — embedded directly in HomeView's IndexedStack.
class PartsContent extends GetView<PartsController> {
  const PartsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchBar(),
        _CategoryFilter(),
        Expanded(child: _PartsList()),
      ],
    );
  }
}

class _SearchBar extends GetView<PartsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: TextField(
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by model or product name...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends GetView<PartsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = controller.categories.toList();
      final selectedCat = controller.selectedCategory.value;
      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: cats.map((cat) {
            final selected = selectedCat == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: selected,
                onSelected: (_) =>
                    controller.selectedCategory.value = cat,
                selectedColor: _primary.withValues(alpha: 0.15),
                checkmarkColor: _primary,
                labelStyle: TextStyle(
                  color: selected ? _primary : _textPrimary,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: selected ? _primary : Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _PartsList extends GetView<PartsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.parts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No products found',
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: controller.startAddPart,
                icon: const Icon(Icons.add),
                label: const Text('Add First Product'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
        itemCount: controller.parts.length,
        itemBuilder: (_, i) {
          final part = controller.parts[i];
          return Dismissible(
            key: Key('part_${part.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              await controller.confirmDeletePart(part.id!);
              return false;
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                onTap: () => controller.startEditPart(part),
                title: Text(
                  part.partName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textPrimary),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(part.model,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    if (part.category != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          part.category!,
                          style: const TextStyle(
                              fontSize: 10, color: _primary),
                        ),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (part.customerPrice != null)
                      Text(
                        '€${part.customerPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primary,
                            fontSize: 14),
                      ),
                    if (part.price != null)
                      Text(
                        'Base: €${part.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
      );
    });
  }
}
