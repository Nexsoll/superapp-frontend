import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:superapp/controllers/community_controller.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/community_post_modal.dart';
import 'package:superapp/screens/admin/create_forum_screen.dart';
import 'package:superapp/screens/admin/manage_forum_screen.dart';
import '../../services/api_service.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, theme),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Community'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Connect with owners & staff'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Obx(
                      () => _TabsCard(
                        value: controller.tabIndex.value,
                        items: controller.tabs,
                        onChanged: controller.setTab,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      final list = controller.visiblePosts;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = list[index];
                          return _CommunityPostCard(
                            post: post,
                            isLiked: controller.isLiked(post.id),
                            onLike: () => controller.toggleLike(post.id),
                            onComment: () => _showCommentDialog(context, post),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
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
        bottom: 70,
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
          Expanded(
            child: Center(
              child: Text('Community'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Color(0xFF38CAC7)),
                title: Text('Create Forum'.tr),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateForumScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined, color: Color(0xFF38CAC7)),
                title: Text('Manage Forums'.tr),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageForumScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context, CommunityPost post) {
    final commentController = TextEditingController();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Comments'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: commentController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...'.tr,
                          hintStyle: TextStyle(
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                          filled: true,
                          fillColor: cs.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: cs.primary, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send, color: cs.primary),
                            onPressed: () async {
                              if (commentController.text.trim().isEmpty) return;
                              final controller = Get.find<CommunityController>();
                              await controller.addComment(post.id, commentController.text.trim());
                              commentController.clear();
                              controller.fetchForums();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchComments(post.forumId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Center(
                          child: Text('No comments yet'.tr,
                            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final user = comment['user'] as Map<String, dynamic>? ?? {};
                          final commentUserId = user['id'] as int? ?? 0;
                          final profileController = Get.find<ProfileController>();
                          final isOwnComment = commentUserId == profileController.userId;
                          final initial = (user['fullName'] ?? user['firstName'] ?? 'U')?.toString().substring(0, 1).toUpperCase() ?? 'U';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAvatar(user['avatar'], initial, user['id'] ?? 0),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            user['fullName'] ?? user['firstName'] ?? 'Unknown',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTimeAgo(comment['createdAt']),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: cs.onSurface.withOpacity(0.45),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment['content'] ?? '',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwnComment)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                    onPressed: () => _deleteComment(context, comment['id'], post.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchComments(int? forumId) async {
    if (forumId == null) return [];
    try {
      final profileController = Get.find<ProfileController>();
      final token = profileController.token;
      final baseUrl = ApiService.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/forums/$forumId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return (data['comments'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }
    return [];
  }

  Future<void> _deleteComment(BuildContext context, int commentId, String postId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Comment'.tr),
        content: Text('Are you sure you want to delete this comment?'.tr),
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
      final userId = profileController.userId;

      final baseUrl = ApiService.baseUrl;
      final response = await http.delete(
        Uri.parse('$baseUrl/forums/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.find<CommunityController>().fetchForums();
        Get.snackbar('Success', 'Comment deleted');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment');
    }
  }

  Color _getAvatarColor(dynamic id) {
    final colors = [
      const Color(0xFFE84D8A),
      const Color(0xFF13B07D),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF0EA5E9),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
    ];
    return colors[(id as int? ?? 0) % colors.length];
  }

  String _formatTimeAgo(dynamic dateStr) {
    if (dateStr == null) return 'Just now';
    try {
      final date = DateTime.parse(dateStr.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return 'Just now';
    }
  }

  Widget _buildAvatar(String? avatarUrl, String initial, dynamic userId) {
    final baseUrl = ApiService.baseUrl;
    
    String? proxyUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      // Extract filename from full URL or use as-is
      String filename = avatarUrl;
      if (avatarUrl.contains('storage.googleapis.com')) {
        // Extract the filename from the full URL
        final uri = Uri.parse(avatarUrl);
        filename = uri.pathSegments.last;
      }
      proxyUrl = '$baseUrl/listing/avatar-image/${Uri.encodeComponent(filename)}';
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(userId),
      ),
      child: ClipOval(
        child: proxyUrl != null
            ? Image.network(
                proxyUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitialAvatar(initial),
              )
            : _buildInitialAvatar(initial),
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.isLiked,
    required this.onLike,
    this.onComment,
  });

  final CommunityPost post;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final roleStyle = _roleChipStyle(post.role, cs);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFF2F2F2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostAvatar(post),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.name,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: roleStyle.bg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              post.role,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: roleStyle.fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              post.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
                color: cs.onSurface.withOpacity(0.78),
                fontWeight: FontWeight.w500,
              ),
            ),

            if (post.linkText != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _openLink(post.linkText!),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '🔗 ${post.linkText!}',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onLike,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        // iOS-style red (screenshot jaisa)
                        Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isLiked
                              ? Color(0xFFFF3B30)
                              : Color(0xFFA7B0B6), // dono states me red
                        ),

                        const SizedBox(width: 6),
                        Text(
                          '${post.likes}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onComment,
                  child: _IconCount(
                    icon: Icons.mode_comment_outlined,
                    count: post.replies,
                    label: 'replies',
                  ),
                ),
                SizedBox(width: 30),
                InkWell(
                  onTap: () {},
                  child: Image.asset('assets/share.png', height: 15, width: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _RoleStyle _roleChipStyle(String role, ColorScheme cs) {
    if (role.toLowerCase() == 'staff') {
      return const _RoleStyle(bg: Color(0xFFE8FBF4), fg: Color(0xFF13B07D));
    }
    return _RoleStyle(bg: cs.primary.withOpacity(0.14), fg: cs.primary);
  }

  Widget _buildPostAvatar(CommunityPost post) {
    final baseUrl = ApiService.baseUrl;
    final avatarUrl = post.userAvatarUrl;
    
    String? proxyUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      String filename = avatarUrl;
      if (avatarUrl.contains('storage.googleapis.com')) {
        final uri = Uri.parse(avatarUrl);
        filename = uri.pathSegments.last;
      }
      proxyUrl = '$baseUrl/listing/avatar-image/${Uri.encodeComponent(filename)}';
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: post.avatarColor,
      ),
      child: ClipOval(
        child: proxyUrl != null
            ? Image.network(
                proxyUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitial(post.initial),
              )
            : _buildInitial(post.initial),
      ),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    String link = url;
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
    }
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _IconCount extends StatelessWidget {
  const _IconCount({required this.icon, required this.count, this.label});

  final IconData icon;
  final int count;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.55)),
        const SizedBox(width: 6),
        Text(
          label == null ? '$count' : '$count $label',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _RoleStyle {
  final Color bg;
  final Color fg;
  const _RoleStyle({required this.bg, required this.fg});
}

class _TabsCard extends StatelessWidget {
  const _TabsCard({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final int value;
  final List<String> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: List.generate(items.length, (i) {
        final selected = i == value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 10),
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? cs.primary : theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? cs.primary
                        : (isDark ? Colors.white12 : const Color(0xFFE9EEF0)),
                  ),
                  boxShadow: isDark
                      ? null
                      : const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                ),
                child: Text(
                  items[i],
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : const Color(0xFF6B757C),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
