import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../home/home_controller.dart';
import '../parts/parts_controller.dart';
import '../parts/parts_view.dart';
import '../memo/memo_controller.dart';
import '../memo/memo_history_view.dart';
import '../settings/settings_view.dart';
import '../../data/models/memo_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/excel_importer.dart';

const _primary = Color(0xFF1A73E8);
const _bg = Color(0xFFF5F7FA);
const _textPrimary = Color(0xFF2C3E50);

/// Root scaffold — ONE scaffold for the whole bottom-nav shell.
/// Embedded tab widgets must NOT wrap themselves in another Scaffold.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentTabIndex.value;
      return Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(index),
        body: IndexedStack(
          index: index,
          children: const [
            _HomeContent(),
            PartsContent(),
            MemoHistoryContent(),
            SettingsContent(),
          ],
        ),
        floatingActionButton: _buildFab(index),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Memos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(int index) {
    switch (index) {
      case 1:
        return AppBar(
          title: const Text('Products List',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: _primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.white),
              tooltip: 'Import Excel',
              onPressed: () async {
                await ExcelImporter.importFromExcel();
                Get.find<PartsController>().loadParts();
              },
            ),
          ],
        );
      case 2:
        return AppBar(
          title: const Text('Memo History',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: _primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Obx(() {
              final ctrl = Get.find<MemoController>();
              if (ctrl.fromDate.value != null ||
                  ctrl.toDate.value != null) {
                return TextButton.icon(
                  onPressed: ctrl.clearDateFilter,
                  icon: const Icon(Icons.clear,
                      color: Colors.white, size: 16),
                  label: const Text('Clear',
                      style: TextStyle(color: Colors.white)),
                );
              }
              return IconButton(
                icon: const Icon(Icons.date_range,
                    color: Colors.white),
                onPressed: () =>
                    _showDateFilter(Get.context!),
              );
            }),
          ],
        );
      case 3:
        return AppBar(
          title: const Text('Settings',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: _primary,
          elevation: 0,
          automaticallyImplyLeading: false,
        );
      default:
        return AppBar(
          title: const Text('Mobile Parts Manager',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: _primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: Get.find<HomeController>().loadDashboard,
            ),
          ],
        );
    }
  }

  Widget? _buildFab(int index) {
    switch (index) {
      case 1:
        return FloatingActionButton(
          heroTag: 'fab_parts',
          onPressed: Get.find<PartsController>().startAddPart,
          backgroundColor: _primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2:
        return FloatingActionButton(
          heroTag: 'fab_memos',
          onPressed: Get.find<MemoController>().startCreateMemo,
          backgroundColor: _primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      default:
        return null;
    }
  }

  Future<void> _showDateFilter(BuildContext context) async {
    final now = DateTime.now();
    final ctrl = Get.find<MemoController>();
    final from = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select From Date',
    );
    if (from != null && context.mounted) {
      final to = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: from,
        lastDate: now,
        helpText: 'Select To Date',
      );
      ctrl.fromDate.value = from;
      ctrl.toDate.value = to;
      ctrl.loadMemos();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME TAB CONTENT (no Scaffold)
// ─────────────────────────────────────────────────────────────────────────────

class _HomeContent extends GetView<HomeController> {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsRow(),
              const SizedBox(height: 20),
              _QuickActions(),
              const SizedBox(height: 20),
              _RecentMemos(),
            ],
          ),
        ),
      );
    });
  }
}

class _StatsRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.inventory_2,
                label: 'Total Products',
                value: controller.totalParts.value.toString(),
                color: _primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.today,
                label: 'Today',
                value: controller.todayMemos.value.toString(),
                color: const Color(0xFF34A853),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_month,
                label: 'This Month',
                value: controller.monthMemos.value.toString(),
                color: const Color(0xFFFBBC04),
              ),
            ),
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final memoCtrl = Get.find<MemoController>();
    final homeCtrl = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              icon: Icons.add_circle,
              label: 'New Memo',
              color: _primary,
              onTap: memoCtrl.startCreateMemo,
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.inventory_2,
              label: 'Products List',
              color: const Color(0xFF34A853),
              onTap: () => homeCtrl.changeTab(1),
            ),
            const SizedBox(width: 12),
            _ActionButton(
              icon: Icons.people,
              label: 'Customers',
              color: const Color(0xFFEA4335),
              onTap: () => Get.toNamed(AppRoutes.customers),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentMemos extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Memos',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary)),
            TextButton(
              onPressed: () =>
                  Get.find<HomeController>().changeTab(2),
              child: const Text('See All'),
            ),
          ],
        ),
        Obx(() {
          if (controller.recentMemos.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No memos yet',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            );
          }
          return Column(
            children: controller.recentMemos
                .map((memo) => _MemoListTile(memo: memo))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _MemoListTile extends StatelessWidget {
  final MemoModel memo;

  const _MemoListTile({required this.memo});

  @override
  Widget build(BuildContext context) {
    final memoCtrl = Get.find<MemoController>();
    final date = memo.createdAt != null
        ? DateFormat('dd MMM yyyy')
            .format(DateTime.parse(memo.createdAt!))
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => memoCtrl.openMemoPreview(memo),
        leading: CircleAvatar(
          backgroundColor: _primary.withValues(alpha: 0.1),
          child: const Icon(Icons.receipt, color: _primary),
        ),
        title: Text(memo.memoNumber ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: _textPrimary)),
        subtitle: Text(memo.customerName ?? '',
            style: const TextStyle(color: Colors.grey)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${(memo.total ?? 0.0).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primary,
                  fontSize: 14),
            ),
            Text(date,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
