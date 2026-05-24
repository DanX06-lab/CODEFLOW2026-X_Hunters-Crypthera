import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class BeneficiaryTile extends StatelessWidget {
  final String initials;
  final String name;
  final String allocation;
  final double progress;
  final Color progressColor;
  final String? walletAddress;
  final VoidCallback? onDelete;

  const BeneficiaryTile({
    super.key,
    required this.initials,
    required this.name,
    required this.allocation,
    required this.progress,
    required this.progressColor,
    this.walletAddress,
    this.onDelete,
  });

  String _truncateAddress(String address) {
    if (address.isEmpty) return '';
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          // AVATAR
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progressColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.titleSmall.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleSmall),

                if (walletAddress != null && walletAddress!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _truncateAddress(walletAddress!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Text(allocation, style: AppTextStyles.bodySmall),

                const SizedBox(height: 10),

                // PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.stroke,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
              ],
            ),
          ),

          if (onDelete != null) ...[
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20),
              color: AppColors.danger.withValues(alpha: 0.8),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}
