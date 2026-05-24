import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/contract_service.dart';

import '../../../../shared/widgets/beneficiary_tile.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../../shared/widgets/glow_container.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'claim_screen.dart';
import '../widgets/add_beneficiary_sheet.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final WalletService _walletService = WalletService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _truncateAddress(String address) {
    if (address.isEmpty) return '';
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _showConnectWalletDialog() {
    final TextEditingController pkController = TextEditingController();
    bool showImportInput = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: AppColors.stroke),
              ),
              title: Text(
                showImportInput ? "Import Private Key" : "Connect Wallet",
                style: AppTextStyles.titleLarge,
              ),
              content: showImportInput
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Paste your raw Ethereum private key (64 hex characters) from MetaMask or Trust Wallet.",
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: pkController,
                          hintText: "Enter Private Key (e.g. 0xabc...)",
                          obscureText: true,
                        ),
                      ],
                    )
                  : Text(
                      "Choose a method to connect a Web3 wallet for this hackathon demo.",
                      style: AppTextStyles.bodyMedium,
                    ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: showImportInput
                      ? [
                          ElevatedButton(
                            onPressed: () async {
                              final pk = pkController.text.trim();
                              if (pk.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a private key"),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(context);
                              await _connect(isSimulated: false, privateKey: pk);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Import Wallet",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                showImportInput = false;
                                pkController.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.stroke),
                              foregroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Back",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      : [
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _connect(isSimulated: true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Connect Simulated Wallet",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _connect(isSimulated: false);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Generate New In-App Wallet",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                showImportInput = true;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.stroke),
                              foregroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Import MetaMask Private Key",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _connect({required bool isSimulated, String? privateKey}) async {
    try {
      final address = await _walletService.connectWallet(
        isSimulated: isSimulated,
        importPrivateKey: privateKey,
      );
      await _firestoreService.updateWalletAddress(_uid, address);

      // Log the activity
      await _firestoreService.addActivityLog(_uid, {
        'type': 'wallet_connected',
        'title': 'Wallet Connected',
        'description': isSimulated
            ? 'Connected simulated account (${_truncateAddress(address)})'
            : privateKey != null
                ? 'Imported private key wallet (${_truncateAddress(address)})'
                : 'Generated secure keypair (${_truncateAddress(address)})',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wallet Connected: ${_truncateAddress(address)}"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection failed: ${e.toString()}"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _disconnect() async {
    await _walletService.disconnectWallet();
    await _firestoreService.updateWalletAddress(_uid, "");
    
    // Log activity
    await _firestoreService.addActivityLog(_uid, {
      'type': 'wallet_disconnected',
      'title': 'Wallet Disconnected',
      'description': 'Disconnected active wallet address',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wallet Disconnected"),
          backgroundColor: AppColors.textSecondary,
        ),
      );
    }
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.stroke),
          ),
          title: Text("Deposit to Vault", style: AppTextStyles.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter amount of Sepolia ETH to lock into your inheritance vault smart contract.",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Amount (e.g. 0.05)",
                  hintStyle: AppTextStyles.bodyMedium,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.stroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
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
                final amount = amountController.text.trim();
                Navigator.pop(context);
                if (amount.isNotEmpty) {
                  await _deposit(amount);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Deposit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deposit(String amount) async {
    try {
      // Simulate/execute contract transaction
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      final txHash = await ContractService().depositFunds(double.parse(amount));
      
      if (mounted) {
        Navigator.pop(context); // Remove progress loader
      }

      await _firestoreService.updateVaultCreated(_uid, true);

      // Log the activity
      await _firestoreService.addActivityLog(_uid, {
        'type': 'deposit',
        'title': 'Deposit Completed',
        'description': 'Deposited $amount ETH to vault smart contract. Tx: ${txHash.substring(0, 8)}...',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deposited $amount ETH successfully!"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deposit failed: ${e.toString()}"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _simulateInactivity(bool currentStatus) async {
    final nextStatus = !currentStatus;
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      String txHash;
      if (nextStatus) {
        txHash = await ContractService().simulateInactivity();
      } else {
        txHash = await ContractService().resetInactivity();
      }

      if (mounted) {
        Navigator.pop(context); // Remove progress loader
      }

      await _firestoreService.updateInactivityStatus(_uid, nextStatus);

      await _firestoreService.addActivityLog(_uid, {
        'type': 'inactivity_simulated',
        'title': nextStatus ? 'Inactivity Triggered' : 'Inactivity Reset',
        'description': nextStatus
            ? 'Emergency protocol activated due to simulated inactivity. Tx: ${txHash.substring(0, 8)}...'
            : 'Vault restored to protected status by owner check-in. Tx: ${txHash.substring(0, 8)}...',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextStatus ? "Inactivity simulation active!" : "Vault status reset to normal"),
            backgroundColor: nextStatus ? AppColors.danger : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Action failed: ${e.toString()}"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getUserStream(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() ?? {};
          final walletAddress = userData['walletAddress'] as String? ?? '';
          final vaultCreated = userData['vaultCreated'] as bool? ?? false;
          final isInactive = userData['isInactive'] as bool? ?? false;
          final beneficiaries = userData['beneficiaries'] as List? ?? [];

          return Stack(
            children: [
              // GLOW EFFECTS
              Positioned(
                top: -80,
                right: -80,
                child: GlowContainer(size: 260, color: AppColors.primary),
              ),

              Positioned(
                bottom: 100,
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
                      Text("Digital Vault", style: AppTextStyles.heading2),
                      const SizedBox(height: 8),
                      Text(
                        "Secure and automate your crypto inheritance",
                        style: AppTextStyles.bodyMedium,
                      ),

                      const SizedBox(height: 30),

                      // VAULT STATUS & WALLET CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Vault Status", style: AppTextStyles.bodyMedium),
                                    const SizedBox(height: 10),
                                    Text(
                                      isInactive
                                          ? "INACTIVE"
                                          : vaultCreated
                                              ? "Protected"
                                              : "No Vault",
                                      style: AppTextStyles.heading3.copyWith(
                                        color: isInactive
                                            ? AppColors.danger
                                            : vaultCreated
                                                ? AppColors.success
                                                : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Vault Balance", style: AppTextStyles.bodyMedium),
                                    const SizedBox(height: 10),
                                    walletAddress.isNotEmpty
                                        ? FutureBuilder<double>(
                                            future: ContractService().getVaultBalance(),
                                            builder: (context, balanceSnapshot) {
                                              final bal = balanceSnapshot.data ?? 0.0;
                                              return Text(
                                                "${bal.toStringAsFixed(4)} ETH",
                                                style: AppTextStyles.heading3.copyWith(
                                                  color: AppColors.primary,
                                                ),
                                              );
                                            },
                                          )
                                        : Text(
                                            "0.0000 ETH",
                                            style: AppTextStyles.heading3.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                            if (walletAddress.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _showDepositDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: const Icon(LucideIcons.plus, size: 18),
                                  label: const Text(
                                    "Deposit Funds to Vault",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            const Divider(color: AppColors.stroke),
                            const SizedBox(height: 14),
                            Text(
                              "Connected Wallet",
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            if (walletAddress.isEmpty)
                              PrimaryButton(
                                text: "Connect Wallet",
                                onTap: _showConnectWalletDialog,
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _truncateAddress(walletAddress),
                                          style: AppTextStyles.titleSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        FutureBuilder<String>(
                                          future: _walletService.getBalanceFormatted(walletAddress),
                                          builder: (context, balanceSnapshot) {
                                            return Text(
                                              balanceSnapshot.data ?? "Fetching...",
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.unlink, color: AppColors.danger),
                                    onPressed: _disconnect,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // BENEFICIARIES HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Beneficiaries", style: AppTextStyles.titleLarge),
                          IconButton(
                            icon: const Icon(LucideIcons.userPlus, color: AppColors.primary),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => AddBeneficiarySheet(
                                  uid: _uid,
                                  existingBeneficiaries: beneficiaries,
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (beneficiaries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "No beneficiaries added yet.",
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: beneficiaries.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final b = beneficiaries[index] as Map<String, dynamic>;
                            final name = b['name'] as String? ?? 'Beneficiary';
                            final address = b['walletAddress'] as String? ?? '';
                            final alloc = b['allocationPercent'] as int? ?? 0;
                            
                            // Generate initials
                            final nameParts = name.trim().split(RegExp(r'\s+'));
                            final initials = nameParts.length > 1
                                ? (nameParts[0][0] + nameParts[1][0]).toUpperCase()
                                : nameParts[0].substring(0, nameParts[0].length >= 2 ? 2 : 1).toUpperCase();

                            final colorIndex = index % 2;
                            final progressColor = colorIndex == 0 ? AppColors.primary : AppColors.purple;

                            return BeneficiaryTile(
                              initials: initials,
                              name: name,
                              walletAddress: address,
                              allocation: "$alloc% Allocation",
                              progress: alloc / 100.0,
                              progressColor: progressColor,
                              onDelete: () async {
                                await _firestoreService.removeBeneficiary(_uid, b);
                                
                                // Sync on-chain
                                final updatedBeneficiaries = List.from(beneficiaries)
                                  ..removeWhere((item) => item['walletAddress'] == address);
                                final addresses = updatedBeneficiaries.map((x) => x['walletAddress'] as String).toList();
                                final allocations = updatedBeneficiaries.map((x) => x['allocationPercent'] as int).toList();

                                try {
                                  await ContractService().setBeneficiaries(addresses, allocations);
                                } catch (e) {
                                  debugPrint("On-chain sync failed: $e");
                                }

                                await _firestoreService.addActivityLog(_uid, {
                                  'type': 'beneficiary_removed',
                                  'title': 'Beneficiary Removed',
                                  'description': 'Removed $name from allocation',
                                });
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 30),

                      // EMERGENCY PROTOCOL
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Emergency Protocol",
                                  style: AppTextStyles.titleMedium,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isInactive
                                        ? AppColors.danger.withValues(alpha: 0.15)
                                        : AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isInactive ? "Inactive" : "Active",
                                    style: TextStyle(
                                      color: isInactive ? AppColors.danger : AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isInactive
                                  ? "The vault has been flagged as inactive. Beneficiaries are now eligible to claim their allocations."
                                  : "Auto-transfer triggers after inactivity verification.",
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _simulateInactivity(isInactive),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInactive ? AppColors.success : AppColors.danger,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(isInactive ? "Cancel Simulation" : "Simulate Inactivity"),
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
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(LucideIcons.unlock, size: 16),
                                    label: const Text("Claim Funds"),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // INACTIVITY TIMER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                LucideIcons.clock3,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Inactivity Timer",
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text("90 Days", style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ],
                        ),
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
                child: BottomNavbar(currentIndex: 1),
              ),
            ],
          );
        },
      ),
    );
  }
}
