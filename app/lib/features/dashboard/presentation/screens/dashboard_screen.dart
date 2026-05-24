import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/contract_service.dart';

import '../../../../shared/widgets/activity_tile.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';
import '../../../../shared/widgets/stat_card.dart';

import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../vault/presentation/screens/claim_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('User session not found. Please log in again.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserStream(_uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data?.data() ?? {};
          final fullName = userData['fullName'] as String? ?? 'Crypthera User';
          final walletAddress = userData['walletAddress'] as String? ?? '';
          final vaultCreated = userData['vaultCreated'] as bool? ?? false;
          final isInactive = userData['isInactive'] as bool? ?? false;
          final beneficiaries = userData['beneficiaries'] as List? ?? [];

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestoreService.getActivityLogsStream(_uid),
            builder: (context, activitySnapshot) {
              final logs = activitySnapshot.data?.docs ?? [];
              final totalTransactions = logs.length;

              return Stack(
                children: [
                  // GLOW EFFECTS
                  Positioned(
                    top: -80,
                    right: -80,
                    child: GlowContainer(size: 260, color: AppColors.primary),
                  ),

                  Positioned(
                    bottom: 140,
                    left: -100,
                    child: GlowContainer(size: 240, color: AppColors.purple),
                  ),

                  // MAIN CONTENT
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),

                          // HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // LEFT TEXTS
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome Back,",
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fullName,
                                    style: AppTextStyles.heading2,
                                  ),
                                ],
                              ),

                              // PROFILE AVATAR
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(fullName),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // HERO CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Assets", style: AppTextStyles.bodyMedium),
                                const SizedBox(height: 12),
                                walletAddress.isNotEmpty
                                    ? FutureBuilder<double>(
                                        future: ContractService().getVaultBalance(),
                                        builder: (context, balanceSnapshot) {
                                          if (balanceSnapshot.connectionState == ConnectionState.waiting) {
                                            return Text("Loading...", style: AppTextStyles.heading2);
                                          }
                                          final bal = balanceSnapshot.data ?? 0.0;
                                          return Text(
                                            "${bal.toStringAsFixed(4)} ETH",
                                            style: AppTextStyles.heading2,
                                          );
                                        },
                                      )
                                    : Text(
                                        "\$0.00",
                                        style: AppTextStyles.heading2,
                                      ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isInactive
                                            ? AppColors.danger.withValues(alpha: 0.15)
                                            : vaultCreated
                                                ? AppColors.success.withValues(alpha: 0.15)
                                                : AppColors.textSecondary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isInactive
                                            ? "Vault Inactive"
                                            : vaultCreated
                                                ? "Vault Protected"
                                                : "Vault Not Created",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isInactive
                                              ? AppColors.danger
                                              : vaultCreated
                                                  ? AppColors.success
                                                  : AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isInactive)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const ClaimScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.danger,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        icon: const Icon(LucideIcons.unlock, size: 16),
                                        label: const Text(
                                          "Claim",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // OVERVIEW
                          Text("Overview", style: AppTextStyles.titleLarge),

                          const SizedBox(height: 20),

                          // STATS GRID
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: "Beneficiaries",
                                  value: beneficiaries.length.toString().padLeft(2, '0'),
                                  icon: LucideIcons.users,
                                  iconColor: AppColors.purple,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: "Transactions",
                                  value: totalTransactions.toString().padLeft(2, '0'),
                                  icon: LucideIcons.arrowLeftRight,
                                  iconColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: "AI Status",
                                  value: "Active",
                                  icon: LucideIcons.bot,
                                  iconColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: "Security",
                                  value: isInactive
                                      ? "Breached"
                                      : vaultCreated
                                          ? "Strong"
                                          : "Weak",
                                  icon: LucideIcons.shieldCheck,
                                  iconColor: isInactive
                                      ? AppColors.danger
                                      : vaultCreated
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // RECENT ACTIVITY
                          Text("Recent Activity", style: AppTextStyles.titleLarge),

                          const SizedBox(height: 18),

                          if (logs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  "No activity logged yet.",
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: logs.length > 3 ? 3 : logs.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final log = logs[index].data();
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
                                  time: "Just now", // In a real app we'd format the timestamp
                                );
                              },
                            ),

                          const SizedBox(height: 120),
                        ],
                      ),
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
                          MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
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
                    child: BottomNavbar(currentIndex: 0),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
