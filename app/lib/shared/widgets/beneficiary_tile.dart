import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class BeneficiaryTile extends StatelessWidget {
  final String initials;
  final String name;
  final String allocation;
  final double progress;
  final Color progressColor;

  const BeneficiaryTile({
    super.key,
    required this.initials,
    required this.name,
    required this.allocation,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          // AVATAR
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progressColor.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.titleSmall.copyWith(color: progressColor),
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
        ],
      ),
    );
  }
}
