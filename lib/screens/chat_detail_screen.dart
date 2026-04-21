import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/chat_detail_controller.dart';
import 'package:superapp/modal/chat_item_modal.dart';
import 'package:superapp/services/listing_service.dart';

class ChatDetailScreen extends StatelessWidget {
  ChatDetailScreen({super.key});
  final chat = Get.arguments as ChatItem;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController(chat: chat));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          toolbarHeight: 120,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: controller.back,
          ),
          title: Text(
            controller.chat.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.02, 0.49, 1.0],
                colors: [
                  Color(0xFF38CAC7),
                  Color(0xFF27B9B6),
                  Color(0xFF119C99),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            if (chat.propertyData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PropertyCard(
                  onTap: controller.goTOReview,
                  accent: theme.colorScheme.primary,
                  propertyData: chat.propertyData!,
                ),
              ),

            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                final msgs = controller.messages;
                return ListView.builder(
                  controller: controller.scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    return _ChatBubble(
                      fromMe: m.fromMe,
                      text: m.text,
                      time: m.time,
                      accent: theme.colorScheme.primary,
                    );
                  },
                );
              }),
            ),

            _ComposerBar(
              onAdd: controller.onAddTap,
              messageCtrl: controller.messageCtrl,
              onSend: controller.sendMessage,
              onCamera: controller.onCameraTap,
              onMic: controller.onMicTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.accent,
    required this.propertyData,
    required this.onTap,
  });

  final Color accent;
  final Map<String, dynamic> propertyData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = propertyData['title'] ?? 'Property';
    final address = propertyData['address'] ?? '';
    final price = propertyData['price'];
    final propertyId = propertyData['id'] as int?;

    String priceStr = '\$0';
    if (price != null) {
      double priceValue = 0;
      if (price is num) {
        priceValue = price.toDouble();
      } else if (price is String) {
        priceValue = double.tryParse(price) ?? 0;
      }

      if (priceValue > 0) {
        if (priceValue >= 1000000) {
          priceStr = '\$${(priceValue / 1000000).toStringAsFixed(1)}M';
        } else if (priceValue >= 1000) {
          priceStr = '\$${(priceValue / 1000).toStringAsFixed(0)}K';
        } else {
          priceStr = '\$${priceValue.toStringAsFixed(0)}';
        }
      }
    }

    final imageUrl = propertyId != null
        ? ListingService.propertyImageUrl(propertyId, 0)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.55), width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 85,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 85,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Color(0xFF9AA0AF),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF9AA0AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceStr,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFFC107),
                            ),
                            SizedBox(width: 4),
                            Text('4.8'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.fromMe,
    required this.text,
    required this.time,
    required this.accent,
  });

  final bool fromMe;
  final String text;
  final String time;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bubbleColor = fromMe ? accent : theme.colorScheme.background;
    final textColor = fromMe
        ? theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)
        : const Color(0xFF1D2330);
    final timeColor = fromMe
        ? Colors.white.withOpacity(0.85)
        : const Color(0xFF9AA0AF);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(fromMe ? 14 : 6),
      bottomRight: Radius.circular(fromMe ? 6 : 14),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        left: fromMe ? 52 : 0,
        right: fromMe ? 0 : 52,
      ),
      child: Align(
        alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            border: Border.all(color: theme.colorScheme.primary),
          ),
          child: Column(
            crossAxisAlignment: fromMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  //  color: textColor,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: timeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.messageCtrl,
    required this.onSend,
    required this.onCamera,
    required this.onMic,
    required this.onAdd,
  });

  final TextEditingController messageCtrl;
  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onMic;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/message_add.png',
              width: 20,
              height: 20,
              color: theme.colorScheme.primary,
            ),
          ),

          // const SizedBox(width: 5),
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                controller: messageCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                cursorColor: theme.colorScheme.primary,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/message_chat.png',
                      width: 20,
                      height: 20,
                      color: theme.colorScheme.primary,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  hintText: 'Message...'.tr,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/message_camra.png',
              width: 20,
              height: 20,
              color: theme.colorScheme.primary,
            ),
          ),

          // const SizedBox(width: 5),
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/message_mic.png',
              width: 20,
              height: 20,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
