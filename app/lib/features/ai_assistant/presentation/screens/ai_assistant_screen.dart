import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../shared/widgets/glow_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web3dart/web3dart.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/services/contract_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final AiService _aiService = AiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: cleanText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String walletAddress = "";
      double walletBalance = 0.0;
      double vaultBalance = 0.0;
      List<Map<String, dynamic>> recentTxs = [];

      if (uid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() ?? {};
          walletAddress = data['walletAddress'] as String? ?? '';
          if (walletAddress.isNotEmpty) {
            final rawBal = await WalletService().getBalance(walletAddress);
            walletBalance = rawBal.getValueInUnit(EtherUnit.ether);
            vaultBalance = await ContractService().getVaultBalance();
          }
        }
        
        final logsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('activityLogs')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
            
        for (var doc in logsSnapshot.docs) {
          final logData = doc.data();
          recentTxs.add({
            'type': logData['type'] ?? 'general',
            'title': logData['title'] ?? '',
            'description': logData['description'] ?? '',
            'timestamp': logData['timestamp']?.toString() ?? '',
          });
        }
      }

      final reply = await _aiService.getResponse(
        cleanText,
        walletAddress: walletAddress,
        walletBalance: walletBalance,
        vaultBalance: vaultBalance,
        recentTransactions: recentTxs,
      );
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Error contacting AI Guardian: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    }
    _scrollToBottom();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
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
                          Text("AI Assistant", style: AppTextStyles.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            "Crypthera Intelligence",
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BODY (WELCOME CARD OR CHAT MESSAGES)
                Expanded(
                  child: _messages.isEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // AI CARD
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(26),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                      ),
                                      child: const Icon(
                                        LucideIcons.bot,
                                        color: AppColors.primary,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Text("Crypthera AI", style: AppTextStyles.heading3),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Analyze risks, monitor inactivity, and optimize your vault security intelligently.",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // SUGGESTED QUESTIONS
                              Text("Suggested Questions", style: AppTextStyles.titleLarge),
                              const SizedBox(height: 20),
                              _buildQuestionChip("How secure is my vault?"),
                              const SizedBox(height: 14),
                              _buildQuestionChip("Optimize inactivity timer"),
                              const SizedBox(height: 14),
                              _buildQuestionChip("Show beneficiary risk analysis"),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                          itemCount: _messages.length + (_isLoading ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return _buildLoadingBubble();
                            }
                            return _buildChatBubble(_messages[index]);
                          },
                        ),
                ),

                // INPUT BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 26),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            onSubmitted: _isLoading ? null : _sendMessage,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Ask Crypthera AI...",
                              hintStyle: AppTextStyles.bodyMedium,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => _sendMessage(_inputController.text),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(
                              LucideIcons.send,
                              color: AppColors.background,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 20),
          ),
          border: message.isUser ? null : Border.all(color: AppColors.stroke),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.stroke),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
