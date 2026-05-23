import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  final String title;
  final String subtitle;
  final String time;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.15),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),

          const SizedBox(width: 14),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),

                const SizedBox(height: 4),

                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // TIME
          Text(time, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
