import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'memo_controller.dart';

const _primary = Color(0xFF1A73E8);
const _textPrimary = Color(0xFF2C3E50);

/// No Scaffold — embedded directly in HomeView's IndexedStack.
class MemoHistoryContent extends GetView<MemoController> {
  const MemoHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            onChanged: controller.onHistorySearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by customer or memo number...',
              prefixIcon:
                  const Icon(Icons.search, color: Colors.grey),
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
        Obx(() {
          if (controller.fromDate.value != null ||
              controller.toDate.value != null) {
            final df = DateFormat('dd MMM yyyy');
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list,
                      size: 16, color: _primary),
                  const SizedBox(width: 8),
                  Text(
                    '${controller.fromDate.value != null ? df.format(controller.fromDate.value!) : 'Any'}'
                    ' → '
                    '${controller.toDate.value != null ? df.format(controller.toDate.value!) : 'Any'}',
                    style: const TextStyle(
                        color: _primary, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator());
            }
            if (controller.memos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No memos found',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.loadMemos,
              child: ListView.builder(
                padding:
                    const EdgeInsets.fromLTRB(12, 8, 12, 80),
                itemCount: controller.memos.length,
                itemBuilder: (_, i) {
                  final memo = controller.memos[i];
                  return Dismissible(
                    key: Key('memo_${memo.id}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await controller
                          .confirmDeleteMemo(memo.id!);
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding:
                          const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete,
                          color: Colors.red),
                    ),
                    child: _MemoCard(
                      memo: memo,
                      onTap: () =>
                          controller.openMemoPreview(memo),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MemoCard extends StatelessWidget {
  final dynamic memo;
  final VoidCallback onTap;

  const _MemoCard({required this.memo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = memo.createdAt != null
        ? DateFormat('dd MMM yyyy')
            .format(DateTime.parse(memo.createdAt))
        : '';
    final fmt = NumberFormat('#,##0.00', 'en_US');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _primary.withValues(alpha: 0.1),
          child: Text(
            memo.memoNumber?.replaceAll('#', '') ?? '?',
            style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ),
        title: Text(
          memo.customerName ?? 'Unknown',
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        subtitle: Text(
          '${memo.memoNumber} • $date',
          style:
              const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Text(
          '€${fmt.format(memo.total ?? 0.0)}',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _primary,
              fontSize: 14),
        ),
      ),
    );
  }
}
