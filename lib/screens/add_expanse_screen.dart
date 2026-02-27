import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/add_expanse_controller.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddExpenseController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: controller.back,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          "Add Expense",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Card(
                          height: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  "TOTAL AMOUNT",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Get.isDarkMode ? Colors.white70 : const Color(0xFF9AA0AF),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 50),

                                TextFormField(
                                  controller: controller.amountCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textAlign: TextAlign.start,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Get.isDarkMode ? Colors.white : const Color(0xFF9AA0AF),
                                        fontWeight: FontWeight.w900,
                                      ),

                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    hintText: "${"\$"}0.00",
                                    hintStyle: theme.textTheme.bodyLarge
                                        ?.copyWith(color: Get.isDarkMode ? Colors.white54 : Colors.grey),

                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Label("Description", theme),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controller.descCtrl,
                          textInputAction: TextInputAction.next,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Get.isDarkMode ? Colors.white : const Color(0xFF1D2330),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: "e.g., Plumbing Repair",
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: Get.isDarkMode ? Colors.white54 : const Color(0xFFB6BAC5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Label("Hotel/Property", theme),
                        const SizedBox(height: 6),
                        Obx(
                          () => _DropdownField(
                            hint: "Select hotel or property",
                            value: controller.property.value.isEmpty
                                ? null
                                : controller.property.value,
                            items: controller.listingNames,
                            onChanged: (v) => controller.pickProperty(v ?? ''),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Label("Category", theme),
                        const SizedBox(height: 6),
                        Obx(
                          () => _DropdownField(
                            hint: "Select",
                            value: controller.category.value.isEmpty
                                ? null
                                : controller.category.value,
                            items: controller.categories,
                            onChanged: (v) => controller.pickCategory(v ?? ''),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Label("Date", theme),
                        const SizedBox(height: 6),
                        Obx(
                          () => InkWell(
                            onTap: () => controller.pickDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                filled: theme.inputDecorationTheme.filled,
                                fillColor: theme.inputDecorationTheme.fillColor,
                                contentPadding:
                                    theme.inputDecorationTheme.contentPadding,
                                enabledBorder:
                                    theme.inputDecorationTheme.enabledBorder,
                                focusedBorder:
                                    theme.inputDecorationTheme.focusedBorder,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.date.value.isEmpty
                                          ? "mm/dd/yyyy"
                                          : controller.date.value,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: controller.date.value.isEmpty
                                                ? (Get.isDarkMode ? Colors.white54 : const Color(0xFFB6BAC5))
                                                : (Get.isDarkMode ? Colors.white : const Color(0xFF1D2330)),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                    color: Get.isDarkMode ? Colors.white54 : const Color(0xFF9AA0AF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Label("Receipt", theme),
                        const SizedBox(height: 6),
                        Obx(
                          () => _ReceiptBox(
                            primary: theme.colorScheme.primary,
                            theme: theme,
                            fileName: controller.receiptName.value,
                            onTapUpload: controller.pickReceipt,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.saveExpense(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          controller.isLoading.value ? "Saving..." : "Save Expense",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.theme);
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        color: Get.isDarkMode ? Colors.white : const Color(0xFF1D2330),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: const InputDecoration(),
      dropdownColor: isDark ? theme.cardColor : Colors.white,
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1D2330),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
      hint: Text(
        hint,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? Colors.white54 : const Color(0xFFB6BAC5),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReceiptBox extends StatelessWidget {
  const _ReceiptBox({
    required this.primary,
    required this.theme,
    required this.fileName,
    required this.onTapUpload,
  });

  final Color primary;
  final ThemeData theme;
  final String fileName;
  final VoidCallback onTapUpload;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName.isNotEmpty;
    final isDark = Get.isDarkMode;

    return InkWell(
      onTap: onTapUpload,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFEDEFF5)),
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.camera_alt_outlined, size: 18, color: primary),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hasFile ? "Selected: $fileName" : "Click to upload",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "or drag and drop ",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white54 : const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),

            Text(
              "SVG, PNG, JPG or PDF",
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white54 : const Color(0xFF9AA0AF),
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.height});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
