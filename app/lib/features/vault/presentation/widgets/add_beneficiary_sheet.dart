import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/contract_service.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';


class AddBeneficiarySheet extends StatefulWidget {
  final String uid;
  final List<dynamic> existingBeneficiaries;

  const AddBeneficiarySheet({
    super.key,
    required this.uid,
    required this.existingBeneficiaries,
  });

  @override
  State<AddBeneficiarySheet> createState() => _AddBeneficiarySheetState();
}

class _AddBeneficiarySheetState extends State<AddBeneficiarySheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _allocationController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _allocationController.dispose();
    super.dispose();
  }

  int _calculateTotalAllocation() {
    int total = 0;
    for (var b in widget.existingBeneficiaries) {
      final alloc = b['allocationPercent'] as int? ?? 0;
      total += alloc;
    }
    return total;
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final allocationStr = _allocationController.text.trim();

    if (name.isEmpty || address.isEmpty || allocationStr.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all fields.";
      });
      return;
    }

    // Address validation
    if (!address.startsWith("0x") || address.length != 42) {
      setState(() {
        _errorMessage = "Invalid EVM address. Must start with 0x and be 42 characters.";
      });
      return;
    }

    // Allocation validation
    final allocation = int.tryParse(allocationStr);
    if (allocation == null || allocation <= 0 || allocation > 100) {
      setState(() {
        _errorMessage = "Allocation must be a percentage between 1 and 100.";
      });
      return;
    }

    final currentTotal = _calculateTotalAllocation();
    if (currentTotal + allocation > 100) {
      setState(() {
        _errorMessage = "Total allocation cannot exceed 100%. Remaining: ${100 - currentTotal}%";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newBeneficiary = {
        'name': name,
        'walletAddress': address,
        'allocationPercent': allocation,
      };

      await _firestoreService.addBeneficiary(widget.uid, newBeneficiary);

      // On-chain sync
      final allBeneficiaries = [...widget.existingBeneficiaries, newBeneficiary];
      final addresses = allBeneficiaries.map((b) => b['walletAddress'] as String).toList();
      final allocations = allBeneficiaries.map((b) => b['allocationPercent'] as int).toList();

      try {
        await ContractService().setBeneficiaries(addresses, allocations);
      } catch (e) {
        debugPrint("On-chain beneficiary sync failed: $e");
      }
      
      // Log the activity
      await _firestoreService.addActivityLog(widget.uid, {
        'type': 'beneficiary_added',
        'title': 'Beneficiary Added',
        'description': 'Added $name ($allocation% allocation)',
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to add beneficiary: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // To prevent keyboard blocking inputs
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(26, 26, 26, 26 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.stroke,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Add Beneficiary",
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              "Allocate a percentage of your vault to a secure address.",
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            
            // Name Field
            Text("Full Name", style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "Enter Full Name",
              controller: _nameController,
            ),
            const SizedBox(height: 20),

            // Wallet Address Field
            Text("Wallet Address", style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "Enter 0x Address",
              controller: _addressController,
            ),
            const SizedBox(height: 20),

            // Allocation Field
            Text("Allocation Percentage (%)", style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "e.g. 25",
              controller: _allocationController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.errorText,
                ),
              ),

            const SizedBox(height: 10),
            PrimaryButton(
              text: _isLoading ? "Adding Beneficiary..." : "Confirm & Save",
              onTap: _isLoading ? () {} : _submit,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
