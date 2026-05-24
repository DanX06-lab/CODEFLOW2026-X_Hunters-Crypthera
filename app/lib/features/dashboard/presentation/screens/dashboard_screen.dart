import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/contract_service.dart';
import '../../../../core/services/wallet_service.dart';

import '../../../../shared/widgets/activity_tile.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';
import '../../../../shared/widgets/stat_card.dart';

import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../vault/presentation/screens/claim_screen.dart';
import '../../../vault/presentation/screens/vault_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final WalletService _walletService = WalletService();
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
                                if (walletAddress.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  FutureBuilder<String>(
                                    future: _walletService.getBalanceFormatted(walletAddress),
                                    builder: (context, balanceSnapshot) {
                                      final bal = balanceSnapshot.data ?? "Fetching...";
                                      return Text(
                                        "Available Wallet: $bal",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ],
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
                                if (walletAddress.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Divider(color: AppColors.stroke),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showSendCryptoDialog(context, walletAddress),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      icon: const Icon(LucideIcons.send, size: 16),
                                      label: const Text(
                                        "Send Crypto",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 20),
                                  const Divider(color: AppColors.stroke),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const VaultScreen()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      icon: const Icon(LucideIcons.wallet, size: 16),
                                      label: const Text(
                                        "Connect Wallet",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
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
                                final timestamp = log['timestamp'];
                                
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
                                  time: _formatTimestamp(timestamp),
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

  void _showSendCryptoDialog(BuildContext context, String senderAddress) {
    final TextEditingController recipientController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    double? estimatedGas;
    bool isEstimatingGas = false;
    String? gasError;
    
    // Reactive calculations helper
    void triggerGasCalculation(String addressVal, String amountVal, StateSetter setDialogState) async {
      final amount = double.tryParse(amountVal) ?? 0.0;
      if (addressVal.length == 42 && addressVal.startsWith("0x") && amount > 0.0) {
        setDialogState(() {
          isEstimatingGas = true;
          gasError = null;
        });
        try {
          final fee = await _walletService.estimateGasFee(
            recipientAddress: addressVal,
            amount: amount,
          );
          final ethFee = fee.getValueInUnit(EtherUnit.ether);
          setDialogState(() {
            estimatedGas = ethFee;
            isEstimatingGas = false;
          });
        } catch (e) {
          setDialogState(() {
            isEstimatingGas = false;
            gasError = "Failed to estimate gas";
          });
        }
      } else {
        setDialogState(() {
          estimatedGas = null;
          isEstimatingGas = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.stroke),
              ),
              title: Text("Send Ethereum", style: AppTextStyles.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Transfer ETH directly from your connected wallet to another address.",
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: recipientController,
                    hintText: "Recipient Wallet Address (0x...)",
                    onChanged: (val) => triggerGasCalculation(val, amountController.text.trim(), setDialogState),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: amountController,
                    hintText: "Amount (ETH)",
                    keyboardType: TextInputType.number,
                    onChanged: (val) => triggerGasCalculation(recipientController.text.trim(), val, setDialogState),
                  ),
                  const SizedBox(height: 16),
                  
                  // Gas fee estimation widget
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Estimated Gas Fee", style: AppTextStyles.bodySmall),
                            if (isEstimatingGas)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            else if (gasError != null)
                              Text(gasError!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger))
                            else
                              Text(
                                estimatedGas != null ? "${estimatedGas!.toStringAsFixed(6)} ETH" : "N/A",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: estimatedGas != null ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final recipient = recipientController.text.trim();
                    final amountStr = amountController.text.trim();
                    final amount = double.tryParse(amountStr) ?? 0.0;
                    
                    if (recipient.length != 42 || !recipient.startsWith("0x")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid recipient address format."), backgroundColor: AppColors.danger),
                      );
                      return;
                    }
                    if (amount <= 0.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid transfer amount."), backgroundColor: AppColors.danger),
                      );
                      return;
                    }
                    
                    // Verify sufficient balance
                    final rawBal = await _walletService.getBalance(senderAddress);
                    if (!context.mounted) return;
                    final walletBal = rawBal.getValueInUnit(EtherUnit.ether);
                    final totalCost = amount + (estimatedGas ?? 0.00042);
                    if (walletBal < totalCost) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Insufficient funds for transfer + gas fee."), backgroundColor: AppColors.danger),
                      );
                      return;
                    }

                    // Open confirmation modal
                    Navigator.pop(context); // Close send input dialog
                    _showConfirmationModal(context, senderAddress, recipient, amount, estimatedGas ?? 0.00042);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmationModal(
    BuildContext context,
    String sender,
    String recipient,
    double amount,
    double gasFee,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.stroke),
          ),
          title: Text("Confirm Transaction", style: AppTextStyles.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Review transaction details before broadcasting:", style: AppTextStyles.bodyMedium),
              const SizedBox(height: 18),
              
              // TX details card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Column(
                  children: [
                    _buildTxDetailRow("From", _truncateAddress(sender)),
                    const Divider(color: AppColors.stroke),
                    _buildTxDetailRow("To", _truncateAddress(recipient)),
                    const Divider(color: AppColors.stroke),
                    _buildTxDetailRow("Amount", "${amount.toStringAsFixed(4)} ETH"),
                    const Divider(color: AppColors.stroke),
                    _buildTxDetailRow("Estimated Gas", "${gasFee.toStringAsFixed(6)} ETH"),
                    const Divider(color: AppColors.stroke),
                    _buildTxDetailRow("Total Debit", "${(amount + gasFee).toStringAsFixed(6)} ETH", highlight: true),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Return to send dialog
                _showSendCryptoDialog(context, sender);
              },
              child: Text("Back", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation modal
                _executeTransaction(context, recipient, amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Confirm & Sign"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTxDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: highlight ? AppColors.primary : Colors.white,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _executeTransaction(BuildContext context, String recipient, double amount) async {
    // Show pending dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                "Broadcasting transaction to Sepolia...",
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    try {
      final txHash = await _walletService.sendETH(
        recipientAddress: recipient,
        amount: amount,
      );

      if (context.mounted) {
        Navigator.pop(context); // Remove pending loader
        _showStatusModal(context, true, txHash, recipient, amount, null);
      }

      // Add to Firestore logs
      await _firestoreService.addActivityLog(_uid, {
        'type': 'claim', // Using 'claim' type to reuse layout, or we can use another type
        'title': 'Sent ETH',
        'description': 'Transferred ${amount.toStringAsFixed(4)} ETH to recipient ${_truncateAddress(recipient)}. Tx: ${txHash.substring(0, 10)}...',
      });
      
      // Update UI state to refresh FutureBuilders
      setState(() {});
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove pending loader
        _showStatusModal(context, false, "", recipient, amount, e.toString());
      }
    }
  }

  void _showStatusModal(
    BuildContext context,
    bool isSuccess,
    String txHash,
    String recipient,
    double amount,
    String? errorMsg,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.stroke),
          ),
          title: Text(
            isSuccess ? "Transfer Initiated" : "Transaction Failed",
            style: AppTextStyles.titleLarge.copyWith(
              color: isSuccess ? AppColors.success : AppColors.danger,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? LucideIcons.checkCircle : LucideIcons.xCircle,
                size: 64,
                color: isSuccess ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(height: 20),
              Text(
                isSuccess
                    ? "Your transfer of ${amount.toStringAsFixed(4)} ETH to ${_truncateAddress(recipient)} was broadcast successfully."
                    : "Something went wrong while executing the transaction:\n\n${errorMsg ?? 'Unknown network failure.'}",
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (isSuccess) ...[
                const SizedBox(height: 20),
                Text("Transaction Hash", style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    // Universal link to Sepolia Etherscan (normally url_launcher but we show visual click feedback)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Redirecting to Sepolia Etherscan for hash: ${txHash.substring(0, 10)}...")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            txHash,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.externalLink, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  String _truncateAddress(String address) {
    if (address.isEmpty) return '';
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    }
    return 'Just now';
  }
}
