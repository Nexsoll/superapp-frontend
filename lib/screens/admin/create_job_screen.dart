import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/job_assignment_controller.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/services/listing_service.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  String _selectedUrgency = 'NORMAL';
  bool _isSubmitting = false;

  bool _isLoadingListings = true;
  List<dynamic> _properties = [];
  List<dynamic> _hotels = [];
  String? _selectedListingId;

  final List<Map<String, dynamic>> _urgencyOptions = [
    {
      'value': 'NORMAL',
      'label': 'Normal',
      'icon': Icons.schedule_rounded,
      'color': const Color(0xFF38CAC7),
      'bg': const Color(0xFFE6F7F7),
    },
    {
      'value': 'URGENT',
      'label': 'Urgent',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFEF4444),
      'bg': const Color(0xFFFEE2E2),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    try {
      final token = Get.find<ProfileController>().token;
      final api = ListingService();
      final props = await api.getMyProperties(token);
      final hots = await api.getMyHotels(token);
      if (mounted) {
        setState(() {
          _properties = props;
          _hotels = hots;
          _isLoadingListings = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingListings = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final controller = Get.find<JobAssignmentController>();
    final budgetText = _budgetCtrl.text.trim();
    final budget = budgetText.isNotEmpty ? double.tryParse(budgetText) : null;

    int? pId;
    int? hId;
    if (_selectedListingId != null) {
      if (_selectedListingId!.startsWith('p_')) {
        pId = int.parse(_selectedListingId!.split('_')[1]);
      } else if (_selectedListingId!.startsWith('h_')) {
        hId = int.parse(_selectedListingId!.split('_')[1]);
      }
    }

    final success = await controller.createJob(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      urgency: _selectedUrgency,
      budget: budget,
      propertyId: pId,
      hotelId: hId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Get.back(); // Pop the create screen first
      // Slight delay to ensure the screen has popped before showing the snackbar
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          'Success',
          'Job created successfully',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          backgroundColor: const Color(0xFF38CAC7),
          colorText: Colors.white,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _SectionLabel(label: 'Job Title', isDark: isDark),
                    const SizedBox(height: 8),
                    _StyledField(
                      controller: _titleCtrl,
                      hint: 'e.g. Leak Repair in Unit 4B',
                      isDark: isDark,
                      theme: theme,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 20),

                    // Description
                    _SectionLabel(label: 'Description', isDark: isDark),
                    const SizedBox(height: 8),
                    _StyledField(
                      controller: _descCtrl,
                      hint: 'Describe the job in detail...',
                      isDark: isDark,
                      theme: theme,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),

                    // Property or Hotel
                    _SectionLabel(
                      label: 'Select Property or Hotel',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingListings)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      )
                    else if (_properties.isEmpty && _hotels.isEmpty)
                      Text('No properties or hotels found'.tr,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF94A3B8),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: isDark
                                ? theme.cardColor
                                : Colors.white,
                            value: _selectedListingId,
                            hint: Text('Select Property or Hotel'.tr,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white30
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('None'.tr),
                              ),
                              if (_properties.isNotEmpty)
                                ..._properties.map(
                                  (p) => DropdownMenuItem<String>(
                                    value: 'p_${p['id']}',
                                    child: Text('${p['title']} (Property)'),
                                  ),
                                ),
                              if (_hotels.isNotEmpty)
                                ..._hotels.map(
                                  (h) => DropdownMenuItem<String>(
                                    value: 'h_${h['id']}',
                                    child: Text('${h['title']} (Hotel)'),
                                  ),
                                ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedListingId = val;
                              });
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Urgency
                    _SectionLabel(label: 'Urgency Level', isDark: isDark),
                    const SizedBox(height: 12),
                    Row(
                      children: _urgencyOptions.map((opt) {
                        final isSelected = _selectedUrgency == opt['value'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedUrgency = opt['value'] as String,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: EdgeInsets.only(
                                right: opt['value'] == 'NORMAL' ? 8 : 0,
                                left: opt['value'] == 'URGENT' ? 8 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (opt['bg'] as Color)
                                    : (isDark
                                          ? theme.cardColor
                                          : const Color(0xFFF8F8F8)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? (opt['color'] as Color).withOpacity(0.6)
                                      : (isDark
                                            ? Colors.white12
                                            : const Color(0xFFE5E7EB)),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (opt['color'] as Color)
                                              .withOpacity(0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    opt['icon'] as IconData,
                                    color: isSelected
                                        ? (opt['color'] as Color)
                                        : (isDark
                                              ? Colors.white38
                                              : const Color(0xFF9CA3AF)),
                                    size: 26,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    opt['label'] as String,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: isSelected
                                          ? (opt['color'] as Color)
                                          : (isDark
                                                ? Colors.white60
                                                : const Color(0xFF6B7280)),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Budget
                    _SectionLabel(label: 'Budget', isDark: isDark),
                    const SizedBox(height: 8),
                    _StyledField(
                      controller: _budgetCtrl,
                      hint: 'e.g. 250',
                      isDark: isDark,
                      theme: theme,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: Icon(
                        Icons.attach_money_rounded,
                        size: 20,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFF9CA3AF),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Budget is required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        if (double.parse(v.trim()) <= 0) {
                          return 'Budget must be positive';
                        }
                        return null;
                      },
                      maxLines: 1,
                    ),

                    const SizedBox(height: 36),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: theme.colorScheme.primary
                              .withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Create Job'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 8,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF38CAC7), Color(0xFF27B9B6), Color(0xFF119C99)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text('Create New Job'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.isDark,
    required this.theme,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final ThemeData theme;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : const Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: isDark ? theme.cardColor : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}
