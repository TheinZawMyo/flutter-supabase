import 'package:flutter/material.dart';
import 'package:flutter_supabase/constants/app_colors.dart';
import 'package:flutter_supabase/models/budget.dart';
import 'package:flutter_supabase/services/database_service.dart';
import 'package:flutter_supabase/utils/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddBudgetPage extends StatefulWidget {
  final BudgetModel? budget;
  const AddBudgetPage({super.key, this.budget});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  BudgetPeriod _period = BudgetPeriod.monthly;
  bool _isSaving = false;
  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.budget?.name ?? '');
    _amountController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );
    _period = widget.budget?.period ?? BudgetPeriod.monthly;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final budget = BudgetModel(
        id: widget.budget?.id ?? const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        period: _period,
        createdAt: widget.budget?.createdAt ?? DateTime.now(),
      );

      if (widget.budget == null) {
        await _dbService.addBudget(budget);
      } else {
        await _dbService.updateBudget(budget);
      }

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message:
              'Budget ${widget.budget == null ? 'created' : 'updated'} successfully!',
          type: SnackBarType.success,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Error: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Text(
                      widget.budget == null ? 'New Budget' : 'Edit Budget',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Budget Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Monthly Allowance, Rent, etc.',
                          icon: Icons.label_important_outline,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Total Amount'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _amountController,
                          hint: '0.00',
                          icon: Icons.account_balance_wallet_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Amount is required';
                            if (double.tryParse(v) == null)
                              return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Budget Period'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildPeriodButton(BudgetPeriod.weekly, 'Weekly'),
                            const SizedBox(width: 12),
                            _buildPeriodButton(BudgetPeriod.monthly, 'Monthly'),
                            const SizedBox(width: 12),
                            _buildPeriodButton(BudgetPeriod.yearly, 'Yearly'),
                          ],
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveBudget,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    widget.budget == null
                                        ? 'CREATE BUDGET'
                                        : 'UPDATE BUDGET',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.deepestGreen,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.sageGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(BudgetPeriod period, String label) {
    bool isSelected = _period == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _period = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.forestGreen.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? AppColors.forestGreen : Colors.grey[200]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.forestGreen : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
