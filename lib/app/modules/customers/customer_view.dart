import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'customer_controller.dart';
import '../memo/memo_controller.dart';

const _primary = Color(0xFF1A73E8);
const _bg = Color(0xFFF5F7FA);
const _textPrimary = Color(0xFF2C3E50);

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Customers',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No customers found',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.showAddCustomerDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadCustomers,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: controller.customers.length,
                  itemBuilder: (_, i) {
                    final customer = controller.customers[i];
                    return Dismissible(
                      key: Key('cust_${customer.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await controller
                            .confirmDeleteCustomer(customer.id!);
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
                        child: const Icon(Icons.delete,
                            color: Colors.red),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        elevation: 1,
                        child: ListTile(
                          onTap: () =>
                              _showCustomerMemos(context, customer),
                          leading: CircleAvatar(
                            backgroundColor:
                                _primary.withValues(alpha: 0.12),
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _textPrimary),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (customer.phone != null &&
                                  customer.phone!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 12,
                                        color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(customer.phone!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey)),
                                  ],
                                ),
                              if (customer.address != null &&
                                  customer.address!.isNotEmpty)
                                Text(customer.address!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddCustomerDialog,
        backgroundColor: _primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Future<void> _showCustomerMemos(
      BuildContext context, customer) async {
    await controller.loadCustomerMemos(customer.id!);
    if (!context.mounted) return;
    final memoCtrl = Get.find<MemoController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary),
                      ),
                    ),
                    const Text('Memos',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  if (controller.customerMemos.isEmpty) {
                    return const Center(
                        child: Text('No memos for this customer'));
                  }
                  return ListView.builder(
                    controller: scrollCtrl,
                    itemCount: controller.customerMemos.length,
                    itemBuilder: (_, i) {
                      final memo = controller.customerMemos[i];
                      final date = memo.createdAt != null
                          ? DateFormat('dd MMM yyyy').format(
                              DateTime.parse(memo.createdAt!))
                          : '';
                      final fmt = NumberFormat('#,##0.00', 'en_US');
                      return ListTile(
                        onTap: () {
                          Get.back();
                          memoCtrl.openMemoPreview(memo);
                        },
                        leading: CircleAvatar(
                          backgroundColor:
                              _primary.withValues(alpha: 0.1),
                          child: Text(
                            memo.memoNumber
                                    ?.replaceAll('#', '') ??
                                '?',
                            style: const TextStyle(
                                color: _primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(memo.memoNumber ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(date,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        trailing: Text(
                          '€${fmt.format(memo.total ?? 0)}',
                          style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
