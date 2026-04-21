import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:superapp/modal/community_post_modal.dart';
import 'package:superapp/controllers/community_controller.dart';
import 'package:superapp/controllers/profile_controller.dart';
import '../../services/api_service.dart';

class ManageForumScreen extends StatefulWidget {
  const ManageForumScreen({super.key});

  @override
  State<ManageForumScreen> createState() => _ManageForumScreenState();
}

class _ManageForumScreenState extends State<ManageForumScreen> {
  List<CommunityPost> _myForums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyForums();
  }

  Future<void> _fetchMyForums() async {
    setState(() => _isLoading = true);
    try {
      final profileController = Get.find<ProfileController>();
      final token = profileController.token;
      final userId = profileController.userId;

      final baseUrl = ApiService.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/forums/my-forums/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _myForums = data.map((json) => CommunityPost.fromJson(json)).toList();
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load forums');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteForum(int forumId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Forum'.tr),
        content: Text('Are you sure you want to delete this forum?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final profileController = Get.find<ProfileController>();
      final token = profileController.token;

      final baseUrl = ApiService.baseUrl;
      final response = await http.delete(
        Uri.parse('$baseUrl/forums/$forumId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Success', 'Forum deleted successfully');
        _fetchMyForums();
        Get.find<CommunityController>().fetchForums();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete forum');
    }
  }

  void _showEditDialog(CommunityPost forum) {
    final titleController = TextEditingController(text: forum.message);
    final linkController = TextEditingController(text: forum.linkText ?? '');

    Get.dialog(
      AlertDialog(
        title: Text('Edit Forum'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Content'.tr),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: InputDecoration(labelText: 'Link (optional)'.tr),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => _updateForum(forum.forumId!, titleController.text, linkController.text),
            child: Text('Save'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _updateForum(int forumId, String content, String link) async {
    try {
      final profileController = Get.find<ProfileController>();
      final token = profileController.token;

      final baseUrl = ApiService.baseUrl;
      final response = await http.patch(
        Uri.parse('$baseUrl/forums/$forumId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          'link': link.isNotEmpty ? link : null,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.back();
        Get.snackbar('Success', 'Forum updated successfully');
        _fetchMyForums();
        Get.find<CommunityController>().fetchForums();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update forum');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, theme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _myForums.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 64, color: cs.onSurface.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('No forums yet'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myForums.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final forum = _myForums[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark(theme) ? Colors.white10 : const Color(0xFFF2F2F2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        forum.tabName,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, size: 20, color: cs.onSurface.withOpacity(0.6)),
                                      onPressed: () => _showEditDialog(forum),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      onPressed: () => _deleteForum(forum.forumId!),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  forum.message,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (forum.linkText != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '🔗 ${forum.linkText}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: cs.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.favorite_outline, size: 16, color: cs.onSurface.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text('${forum.likes}', style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
                                    const SizedBox(width: 16),
                                    Icon(Icons.chat_bubble_outline, size: 16, color: cs.onSurface.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text('${forum.replies}', style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
                                    const Spacer(),
                                    Text(
                                      forum.timeAgo,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.45),
                                      ),
                                    ),
                                  ],
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
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 20,
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Center(
              child: Text('Manage Forums'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  bool isDark(ThemeData theme) => theme.brightness == Brightness.dark;
}
