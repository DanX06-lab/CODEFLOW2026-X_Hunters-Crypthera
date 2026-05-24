import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';

import '../../../../shared/widgets/activity_tile.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';

import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final String _uid;
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  bool _matchesFilter(String type) {
    if (_selectedFilter == "All") return true;
    if (_selectedFilter == "Transfers") {
      return type == 'deposit' || type == 'claim';
    }
    if (_selectedFilter == "Security") {
      return type == 'wallet_connected' ||
          type == 'wallet_disconnected' ||
          type == 'inactivity_simulated';
    }
    if (_selectedFilter == "Vault") {
      return type == 'beneficiary_added' ||
          type == 'beneficiary_removed' ||
          type == 'deposit';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("User session not found.")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // GLOW EFFECTS
          Positioned(
            top: -80,
            right: -80,
            child: GlowContainer(size: 240, color: AppColors.primary),
          ),

          Positioned(
            bottom: 120,
            left: -100,
            child: GlowContainer(size: 220, color: AppColors.purple),
          ),

          // MAIN CONTENT
          SafeArea(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.getActivityLogsStream(_uid),
              builder: (context, snapshot) {
                final logs = snapshot.data?.docs ?? [];
                final filteredLogs = logs.where((doc) {
                  final data = doc.data();
                  final type = data['type'] as String? ?? 'general';
                  return _matchesFilter(type);
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // HEADER
                      Text("Activity", style: AppTextStyles.heading2),
                      const SizedBox(height: 8),
                      Text(
                        "Track all vault and security activity",
                        style: AppTextStyles.bodyMedium,
                      ),

                      const SizedBox(height: 30),

                      // FILTERS
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilter("All"),
                            const SizedBox(width: 12),
                            _buildFilter("Transfers"),
                            const SizedBox(width: 12),
                            _buildFilter("Security"),
                            const SizedBox(width: 12),
                            _buildFilter("Vault"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ACTIVITIES LIST
                      if (filteredLogs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "No matching logs found.",
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredLogs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index].data();
                            final type = log['type'] as String? ?? 'general';
                            final title = log['title'] as String? ?? 'Activity';
                            final description = log['description'] as String? ?? '';
                            
                            IconData icon = LucideIcons.info;
                            Color iconColor = AppColors.primary;
                            if (type == 'deposit') {
                              icon = LucideIcons.arrowDownLeft;
                              iconColor = AppColors.success;
                            } else if (type == 'claim') {
                              icon = LucideIcons.arrowUpRight;
                              iconColor = AppColors.danger;
                            } else if (type == 'beneficiary_added') {
                              icon = LucideIcons.userPlus;
                              iconColor = AppColors.purple;
                            } else if (type == 'beneficiary_removed') {
                              icon = LucideIcons.userMinus;
                              iconColor = AppColors.danger;
                            } else if (type == 'wallet_connected') {
                              icon = LucideIcons.wallet;
                              iconColor = AppColors.success;
                            } else if (type == 'inactivity_simulated') {
                              icon = LucideIcons.alertTriangle;
                              iconColor = AppColors.danger;
                            }

                            return ActivityTile(
                              icon: icon,
                              iconColor: iconColor,
                              title: title,
                              subtitle: description,
                              time: "Just now", // In a real app we'd format a real timestamp
                            );
                          },
                        ),

                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),

          // FLOATING AI BUTTON
          Positioned(
            right: 26,
            bottom: 100,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AiAssistantScreen(),
                  ),
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.bot,
                  color: AppColors.background,
                  size: 28,
                ),
              ),
            ),
          ),

          // NAVBAR
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavbar(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(String filterText) {
    final isActive = _selectedFilter == filterText;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterText;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.stroke,
          ),
        ),
        child: Text(
          filterText,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isActive ? AppColors.background : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
