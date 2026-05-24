import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/contract_service.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/glow_container.dart';

class ClaimScreen extends StatefulWidget {
  const ClaimScreen({super.key});

  @override
  State<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> {
  final _addressController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();


  bool _isSearching = false;
  bool _isClaiming = false;
  String? _errorMessage;
  String? _successTxHash;

  // Located vault details
  Map<String, dynamic>? _foundVault;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _searchVault() async {
    final address = _addressController.text.trim().toLowerCase();
    if (address.isEmpty || !address.startsWith("0x") || address.length != 42) {
      setState(() {
        _errorMessage = "Please enter a valid 42-character EVM address starting with 0x.";
        _foundVault = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _foundVault = null;
      _successTxHash = null;
    });

    try {
      // Query users where isInactive is true
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isInactive', isEqualTo: true)
          .get();

      Map<String, dynamic>? matchedVault;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final beneficiaries = data['beneficiaries'] as List? ?? [];
        for (var b in beneficiaries) {
          final bAddress = b['walletAddress']?.toString().toLowerCase() ?? '';
          if (bAddress == address) {
            matchedVault = {
              'ownerUid': doc.id,
              'ownerName': data['fullName'] ?? 'Unknown User',
              'ownerWallet': data['walletAddress'] ?? '',
              'allocationPercent': b['allocationPercent'] as int? ?? 0,
              'beneficiaryName': b['name'] ?? 'Beneficiary',
              'beneficiaryAddress': bAddress,
              'allBeneficiaries': beneficiaries,
            };
            break;
          }
        }
        if (matchedVault != null) break;
      }

      setState(() {
        _isSearching = false;
        if (matchedVault != null) {
          _foundVault = matchedVault;
        } else {
          _errorMessage = "No inactive vault found allocating funds to this address.";
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = "Search failed: ${e.toString()}";
      });
    }
  }

  void _claimFunds() async {
    if (_foundVault == null) return;

    setState(() {
      _isClaiming = true;
      _errorMessage = null;
    });

    try {
      // Execute smart contract claim call
      final txHash = await ContractService().claimFunds();

      final ownerUid = _foundVault!['ownerUid'] as String;
      final beneficiaryName = _foundVault!['beneficiaryName'] as String;
      final allocationPercent = _foundVault!['allocationPercent'] as int;

      // 1. Log activity for the owner
      await _firestoreService.addActivityLog(ownerUid, {
        'type': 'claim',
        'title': 'Inheritance Claimed',
        'description': '$beneficiaryName claimed $allocationPercent% allocation. Tx: ${txHash.substring(0, 8)}...',
      });

      // 2. Remove beneficiary from list or set allocation to 0 to prevent double-claiming
      // For demo purposes, we will update the beneficiary list in Firestore to mark it as claimed
      final updatedBeneficiaries = (_foundVault!['allBeneficiaries'] as List).map((b) {
        if (b['walletAddress']?.toString().toLowerCase() == _foundVault!['beneficiaryAddress']) {
          return {
            ...b,
            'isClaimed': true,
          };
        }
        return b;
      }).toList();

      await FirebaseFirestore.instance.collection('users').doc(ownerUid).update({
        'beneficiaries': updatedBeneficiaries,
      });

      // Check if all beneficiaries have claimed, if so reset inactivity/vault status
      bool allClaimed = true;
      for (var b in updatedBeneficiaries) {
        if (b['isClaimed'] != true) {
          allClaimed = false;
          break;
        }
      }

      if (allClaimed) {
        await FirebaseFirestore.instance.collection('users').doc(ownerUid).update({
          'isInactive': false,
          'vaultCreated': false, // Vault reset
        });
      }

      setState(() {
        _isClaiming = false;
        _successTxHash = txHash;
      });
    } catch (e) {
      setState(() {
        _isClaiming = false;
        _errorMessage = "Claim failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // GLOW EFFECTS
          Positioned(
            top: -100,
            right: -100,
            child: GlowContainer(size: 280, color: AppColors.primary),
          ),
          Positioned(
            bottom: 120,
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
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.card,
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: const Icon(
                            LucideIcons.arrowLeft,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Claim inheritance", style: AppTextStyles.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            "Recover allocated vault assets",
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  if (_successTxHash != null) ...[
                    // SUCCESS UI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withValues(alpha: 0.15),
                            ),
                            child: const Icon(
                              LucideIcons.checkCircle,
                              color: AppColors.success,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text("Claim Successful!", style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          Text(
                            "Your inherited funds have been successfully transferred to your wallet on the Sepolia testnet.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.stroke),
                          const SizedBox(height: 14),
                          Text(
                            "Transaction Hash",
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            _successTxHash!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 30),
                          PrimaryButton(
                            text: "Return to Dashboard",
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // SEARCH AND INFO UI
                    Text(
                      "Enter Beneficiary Address",
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hintText: "Enter 0x Address",
                            controller: _addressController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isSearching ? null : _searchVault,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _isSearching
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    LucideIcons.search,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ],
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: AppTextStyles.errorText,
                      ),
                    ],

                    const SizedBox(height: 30),

                    if (_foundVault != null) ...[
                      // FOUND VAULT DETAILS
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.shieldAlert,
                                  color: AppColors.danger,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Vault Located",
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow("Vault Owner", _foundVault!['ownerName']),
                            const SizedBox(height: 12),
                            _buildInfoRow("Your Name", _foundVault!['beneficiaryName']),
                            const SizedBox(height: 12),
                            _buildInfoRow("Allocation", "${_foundVault!['allocationPercent']}%"),
                            const SizedBox(height: 12),
                            _buildInfoRow("Status", "Inactivity Verified (Claim Ready)"),
                            const SizedBox(height: 24),
                            const Divider(color: AppColors.stroke),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              text: _isClaiming ? "Executing Claim..." : "Claim Assets Now",
                              onTap: _isClaiming ? () {} : _claimFunds,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // INITIAL INSTRUCTION CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              LucideIcons.helpCircle,
                              color: AppColors.purple,
                              size: 32,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "How to claim?",
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Enter the exact EVM wallet address registered as a beneficiary. The system scans the network for verified inactivity triggers and displays your claimable allocation.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
