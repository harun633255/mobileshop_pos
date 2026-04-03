import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../utils/excel_importer.dart';
import '../parts/parts_controller.dart';

const _primary = Color(0xFF1A73E8);
const _textPrimary = Color(0xFF2C3E50);

/// No Scaffold — embedded directly in HomeView's IndexedStack.
class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final s = Get.find<SettingsController>();
    _nameCtrl = TextEditingController(text: s.shopName.value);
    _phoneCtrl = TextEditingController(text: s.shopPhone.value);
    _addressCtrl = TextEditingController(text: s.shopAddress.value);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Info
            _SettingSection(
              title: 'Shop Information',
              icon: Icons.store,
              children: [
                _buildTextField(
                  controller: _nameCtrl,
                  label: 'Shop Name',
                  icon: Icons.storefront,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneCtrl,
                  label: 'Shop Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressCtrl,
                  label: 'Shop Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ctrl.saveSettings(
                      name: _nameCtrl.text,
                      phone: _phoneCtrl.text,
                      address: _addressCtrl.text,
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thermal Printer — mobile only
            if (Platform.isAndroid || Platform.isIOS) ...[
              _SettingSection(
                title: 'Thermal Printer',
                icon: Icons.print,
                children: [
                  Obx(() => Row(
                        children: [
                          Icon(
                            ctrl.isBluetoothConnected.value
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: ctrl.isBluetoothConnected.value
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ctrl.isBluetoothConnected.value
                                  ? 'Connected: ${ctrl.connectedDeviceName.value}'
                                  : 'No printer connected',
                              style: TextStyle(
                                color: ctrl.isBluetoothConnected.value
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: ctrl.scanBluetoothDevices,
                          icon: Obx(() =>
                              ctrl.isScanningBluetooth.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(
                                      Icons.bluetooth_searching)),
                          label: const Text('Scan Devices'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => ctrl.isBluetoothConnected.value
                          ? IconButton(
                              onPressed: ctrl.disconnectBluetooth,
                              icon: const Icon(Icons.link_off,
                                  color: Colors.red),
                              tooltip: 'Disconnect',
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Price List
            _SettingSection(
              title: 'Price List',
              icon: Icons.price_change,
              children: [
                _SettingTile(
                  icon: Icons.upload_file,
                  title: 'Import from Excel',
                  subtitle:
                      'Import products from .xlsx (columns: Model, Product, Price, Customer Price, Tudo)',
                  onTap: () async {
                    await ExcelImporter.importFromExcel();
                    Get.find<PartsController>().loadParts();
                  },
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.picture_as_pdf,
                  title: 'Export Price List as PDF',
                  subtitle: 'Print or share the full parts list',
                  onTap: ctrl.exportPriceList,
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.trending_up,
                  title: 'Bulk Price Update',
                  subtitle:
                      'Increase all customer prices by a percentage',
                  onTap: ctrl.showBulkPriceUpdateDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // App info
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline,
                          color: _primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Mobile Parts Manager',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimary)),
                          Text('Version 1.0.0 • Offline POS',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 14),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: _textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
