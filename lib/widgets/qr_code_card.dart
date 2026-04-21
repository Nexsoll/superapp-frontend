import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeCard extends StatelessWidget {
  final String qrData;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const QrCodeCard({
    super.key,
    required this.qrData,
    this.onDownload,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2FC1BE).withOpacity(0.35)),
      ),

      child: Column(
        children: [
          // QR Code with background
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2FC1BE).withOpacity(0.3),
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 140,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF2FC1BE),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF2FC1BE),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text('Your Check-in QR Code'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
            ),
          ),
          const SizedBox(height: 8),
          Text('Show this code at the hotel reception'.tr,
            style: TextStyle(fontSize: 13, color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.download,
                iconWidget: SvgPicture.asset(
                  'assets/material-symbols_download-rounded.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1D2330),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Download',
                onTap: onDownload,
              ),
              const SizedBox(width: 16),
              _ActionButton(icon: Icons.share, label: 'Share', onTap: onShare),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.iconWidget,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),

        child: Row(
          children: [
            if (iconWidget != null)
              IconTheme(
                data: const IconThemeData(
                  color: Color(0xFF1D2330),
                  size: 18,
                ),
                child: iconWidget!,
              )
            else
              Icon(icon, size: 18, color: const Color(0xFF1D2330)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D2330),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
