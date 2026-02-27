import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/services/api_service.dart';

class ExpenseDetailController extends GetxController {
  ExpenseDetailController({required this.expenseId});

  final int expenseId;

  final isLoading = false.obs;
  final expense = Rxn<Map<String, dynamic>>();

  String? _token;
  File? _newReceiptFile;
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
    await fetch();
  }

  Future<void> fetch() async {
    if (_token == null || _token!.isEmpty) return;
    isLoading.value = true;
    try {
      final data = await ApiService.getExpense(token: _token!, expenseId: expenseId);
      expense.value = data;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense() async {
    if (_token == null || _token!.isEmpty) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;
    try {
      await ApiService.deleteExpense(token: _token!, expenseId: expenseId);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editExpense(BuildContext context) async {
    final current = expense.value;
    if (current == null) return;
    if (_token == null || _token!.isEmpty) return;

    final titleCtrl = TextEditingController(text: current['title']?.toString() ?? '');
    final amountCtrl = TextEditingController(text: current['amount']?.toString() ?? '');
    
    // Parse current date for editing
    DateTime currentDate;
    try {
      currentDate = DateTime.parse(current['date']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      currentDate = DateTime.now();
    }
    final selectedDate = currentDate.obs;

    final categoryRx = (current['category']?.toString() ?? 'OTHER').obs;
    final currentReceiptUrl = current['receiptUrl']?.toString();
    final newReceiptPath = Rxn<String>();

    Future<void> pickReceipt(ImageSource source) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          _newReceiptFile = File(pickedFile.path);
          newReceiptPath.value = pickedFile.path;
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to pick image: $e');
      }
    }

    final saved = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Expense'),
        content: Obx(
          () => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: categoryRx.value,
                  items: const [
                    DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'UTILITIES', child: Text('Utilities')),
                    DropdownMenuItem(value: 'TAX', child: Text('Tax')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (v) {
                    if (v != null) categoryRx.value = v;
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                // Date picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Receipt picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Receipt',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (newReceiptPath.value != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(newReceiptPath.value!),
                          height: 120,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            _newReceiptFile = null;
                            newReceiptPath.value = null;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (currentReceiptUrl != null && currentReceiptUrl.isNotEmpty)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentReceiptUrl,
                          height: 120,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => Get.bottomSheet(
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt, color: Get.theme.colorScheme.primary),
                                    title: const Text('Take a Photo'),
                                    onTap: () {
                                      Get.back();
                                      pickReceipt(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo_library, color: Get.theme.colorScheme.primary),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Get.back();
                                      pickReceipt(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Change Receipt'),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: () => Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Get.theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera_alt, color: Get.theme.colorScheme.primary),
                                title: const Text('Take a Photo'),
                                onTap: () {
                                  Get.back();
                                  pickReceipt(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_library, color: Get.theme.colorScheme.primary),
                                title: const Text('Choose from Gallery'),
                                onTap: () {
                                  Get.back();
                                  pickReceipt(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Add Receipt', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final amount = double.tryParse(amountCtrl.text);
    if (amount == null) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    isLoading.value = true;
    try {
      // Upload new receipt if selected
      String? receiptUrl;
      if (_newReceiptFile != null) {
        Get.snackbar('Uploading', 'Uploading receipt image...');
        final fileBytes = await _newReceiptFile!.readAsBytes();
        final uploadResult = await ApiService.uploadReceipt(
          token: _token!,
          fileBytes: fileBytes,
          filename: 'receipt.jpg',
        );
        receiptUrl = uploadResult['receiptUrl']?.toString();
      }

      await ApiService.updateExpense(
        token: _token!,
        expenseId: expenseId,
        title: titleCtrl.text.trim(),
        amount: amount,
        category: categoryRx.value,
        date: '${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}',
        receiptUrl: receiptUrl,
      );
      _newReceiptFile = null;
      await fetch();
      Get.snackbar('Updated', 'Expense updated');
      // Return true to parent so it refreshes the list
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final int expenseId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseDetailController(expenseId: expenseId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.editExpense(context),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value ? null : controller.deleteExpense,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.expense.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = controller.expense.value;
          if (data == null) {
            return Center(
              child: Text(
                'No expense found',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          final title = data['title']?.toString() ?? '';
          final category = data['category']?.toString() ?? 'OTHER';
          final amount = data['amount']?.toString() ?? '0';
          final dateStr = data['date']?.toString() ?? '';

          String place = 'N/A';
          if (data['property'] is Map) {
            place = (data['property']['title'] ?? 'N/A').toString();
          } else if (data['hotel'] is Map) {
            place = (data['hotel']['title'] ?? 'N/A').toString();
          }

          final receiptUrl = data['receiptUrl']?.toString();

          return RefreshIndicator(
            onRefresh: controller.fetch,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _InfoTile(label: 'Title', value: title),
                _InfoTile(label: 'Amount', value: '\$$amount'),
                _InfoTile(label: 'Category', value: category),
                _InfoTile(label: 'Hotel/Property', value: place),
                _InfoTile(label: 'Date', value: _prettyDate(dateStr)),
                const SizedBox(height: 16),
                Text(
                  'Receipt',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (receiptUrl == null || receiptUrl.trim().isEmpty)
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Get.isDarkMode ? Colors.white12 : const Color(0xFFEDEFF5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'No receipt uploaded',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      receiptUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 160,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stack) {
                        debugPrint('Receipt image load error: $error, URL: $receiptUrl');
                        return Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Get.isDarkMode ? Colors.white12 : const Color(0xFFEDEFF5)),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Unable to load receipt',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Get.isDarkMode ? Colors.white12 : const Color(0xFFEDEFF5)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Get.isDarkMode ? Colors.white70 : const Color(0xFF9AA0AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Get.isDarkMode ? Colors.white : const Color(0xFF1D2330),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _prettyDate(String iso) {
  if (iso.trim().isEmpty) return '';
  try {
    final d = DateTime.parse(iso);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}
