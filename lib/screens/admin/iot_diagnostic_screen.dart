import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/iot_controller.dart';
import 'package:superapp/modal/iot_device_modal.dart';

class IoTDiagnosticScreen extends StatelessWidget {
  const IoTDiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IoTController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                itemCount: controller.devices.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final device = controller.devices[index];
                  return _buildDeviceCard(
                    context: context,
                    device: device,
                    isDark: isDark,
                    onRemove: () =>
                        _showRemoveDialog(context, controller, device.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.fetchListings();
          _showAddDeviceSheet(context, controller, isDark);
        },
        backgroundColor: const Color(0xFF38CAC7),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    IoTController controller,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: const Text('Are you sure you want to remove this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final deviceId = int.tryParse(id);
              if (deviceId != null) {
                controller.removeDevice(deviceId);
              }
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceSheet(
    BuildContext context,
    IoTController controller,
    bool isDark,
  ) {
    final nameCtrl = TextEditingController();
    String selectedStatus = 'Normal';
    String? selectedListingId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Device',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF38CAC7),
                    ),
                    onPressed: () => controller.fetchListings(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                nameCtrl,
                'Device Name',
                Icons.devices_other_rounded,
                isDark,
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Property or Hotel',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.isLoadingListings.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final hasListings =
                    controller.properties.isNotEmpty ||
                    controller.hotels.isNotEmpty;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      value: selectedListingId,
                      hint: Text(
                        hasListings
                            ? 'Choose a listing'
                            : 'No properties found',
                        style: TextStyle(
                          color: hasListings ? null : Colors.redAccent,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('None'),
                        ),
                        ...controller.properties.map(
                          (p) => DropdownMenuItem(
                            value: 'p_${p['id']}',
                            child: Text('${p['title']} (Property)'),
                          ),
                        ),
                        ...controller.hotels.map(
                          (h) => DropdownMenuItem(
                            value: 'h_${h['id']}',
                            child: Text('${h['title']} (Hotel)'),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setSheetState(() => selectedListingId = val),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusChip(
                    label: 'Normal',
                    isSelected: selectedStatus == 'Normal',
                    onTap: () => setSheetState(() => selectedStatus = 'Normal'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Urgent',
                    isSelected: selectedStatus == 'Urgent',
                    onTap: () => setSheetState(() => selectedStatus = 'Urgent'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      int? pId;
                      int? hId;
                      if (selectedListingId != null) {
                        if (selectedListingId!.startsWith('p_')) {
                          pId = int.parse(selectedListingId!.split('_')[1]);
                        } else if (selectedListingId!.startsWith('h_')) {
                          hId = int.parse(selectedListingId!.split('_')[1]);
                        }
                      }

                      controller.addDevice(
                        name: nameCtrl.text.trim(),
                        status: selectedStatus,
                        propertyId: pId,
                        hotelId: hId,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38CAC7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add Device',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF38CAC7)),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 70, // Keep space for the wave or gradient look
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF38CAC7), Color(0xFF2DD4BF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Text(
            'IoT Diagnostic',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Obx(() {
            final controller = Get.find<IoTController>();
            return Badge(
              label: Text(controller.devices.length.toString()),
              child: SvgPicture.asset(
                'assets/admin-filter.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required IoTDevice device,
    required bool isDark,
    required VoidCallback onRemove,
  }) {
    final isUrgent = device.status == 'Urgent';
    final iconColor = isUrgent
        ? const Color(0xFFEF4444)
        : (isDark ? Colors.white70 : const Color(0xFF64748B));
    final iconBg = isUrgent
        ? (isDark
              ? const Color(0xFFEF4444).withOpacity(0.1)
              : const Color(0xFFFEF2F2))
        : (isDark ? Colors.white10 : const Color(0xFFF1F5F9));

    final tagBg = isUrgent
        ? (isDark
              ? const Color(0xFFEF4444).withOpacity(0.2)
              : const Color(0xFFFEE2E2))
        : (isDark ? Colors.white10 : const Color(0xFFF1F5F9));
    final tagColor = isUrgent
        ? const Color(0xFFEF4444)
        : (isDark ? Colors.white70 : const Color(0xFF64748B));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUrgent
                  ? Icons.error_outline_rounded
                  : Icons.devices_other_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        device.status,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      device.location,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•', style: TextStyle(color: Colors.grey)),
                    ),
                    Text(
                      device.timeAgo,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant _StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() => _selected = true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selected ? const Color(0xFF38CAC7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selected
                ? Colors.transparent
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _selected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
