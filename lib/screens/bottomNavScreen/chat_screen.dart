import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/chat_controller.dart';
import 'package:superapp/modal/chat_item_modal.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();
  final controller = Get.put(ChatsController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Chats'.tr,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                // color: const Color(0xFF111111),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: TextFormField(
                controller: _searchController,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search peoples...'.tr,
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Obx(() {
              final items = controller.filteredChats;

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 76,
                  endIndent: 16,
                  color: Color(0xFFEFEFEF),
                ),
                itemBuilder: (context, index) {
                  final chat = items[index];
                  return _ChatTile(
                    chat: chat,
                    accent: theme.colorScheme.primary,
                    onTap: () => controller.onChatTap(chat),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.accent,
    required this.onTap,
  });

  final ChatItem chat;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool muted = chat.message.isEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(chat.avatarUrl),
              backgroundColor: const Color(0xFFEDEDED),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      // color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatusIcon(status: chat.status, accent: accent),
                      if (chat.status != MessageStatus.none)
                        const SizedBox(width: 6),

                      if (chat.isVoice) ...[
                        const Icon(
                          Icons.mic,
                          size: 16,
                          color: Color(0xFFB0B0B0),
                        ),
                        const SizedBox(width: 6),
                      ],

                      if (chat.isPhoto) ...[
                        const Icon(
                          Icons.photo_camera,
                          size: 16,
                          color: Color(0xFFB0B0B0),
                        ),
                        const SizedBox(width: 6),
                      ],

                      Expanded(
                        child: Text(
                          chat.isPhoto ? 'Photo' : chat.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: muted
                              ? theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFFB0B0B0),
                                )
                              : theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFF8A8A8A),
                                  height: 1.2,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    color: const Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 8),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.accent});

  final MessageStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.none:
        return const SizedBox.shrink();

      case MessageStatus.sent:
        return const Icon(Icons.check, size: 16, color: Color(0xFFB0B0B0));

      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 16, color: Color(0xFFB0B0B0));

      case MessageStatus.read:
        return Icon(Icons.done_all, size: 16, color: accent);
    }
  }
}
