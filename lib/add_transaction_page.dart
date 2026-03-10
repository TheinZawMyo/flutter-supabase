import 'package:flutter/material.dart';
import 'package:flutter_supabase/constants/app_colors.dart';
import 'package:flutter_supabase/constants/category_icons.dart';
import 'package:flutter_supabase/constants/default_categories.dart';
import 'package:flutter_supabase/models/category.dart';
import 'package:flutter_supabase/models/transaction.dart';
import 'package:flutter_supabase/services/database_service.dart';
import 'package:flutter_supabase/utils/custom_snackbar.dart';
import 'package:flutter_supabase/utils/connectivity_utils.dart';
import 'package:flutter_supabase/models/budget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedBudgetId;
  final DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<TransactionCategory> _allCategories = [];
  List<BudgetModel> _budgets = [];
  bool _isCategoriesLoading = true;
  bool _isBudgetsLoading = true;

  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadCategories();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    try {
      final budgets = await _dbService.getBudgets();
      setState(() {
        _budgets = budgets;
        _isBudgetsLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      setState(() => _isBudgetsLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final customCategories = await _dbService.getCategories();
      final defaultCategories = getDefaultCategories(
        Supabase.instance.client.auth.currentUser?.id ?? '',
      );
      setState(() {
        _allCategories = [...defaultCategories, ...customCategories];
        _isCategoriesLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isCategoriesLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      if (_selectedCategoryId == null) {
        CustomSnackBar.show(
          context: context,
          message: 'Please select a category',
          type: SnackBarType.warning,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: user.id,
        budgetId: _selectedBudgetId,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      await _dbService.addTransaction(transaction);

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Transaction added successfully!',
          type: SnackBarType.success,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final message = ConnectivityUtils.isNoInternetError(e)
            ? 'No internet connection. Please check your network and try again.'
            : 'Error: ${e.toString()}';

        CustomSnackBar.show(
          context: context,
          message: message,
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _allCategories
        .where(
          (cat) =>
              cat.type ==
              (_type == TransactionType.income
                  ? CategoryType.income
                  : CategoryType.expense),
        )
        .toList();

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
            // Header
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
                    const Text(
                      'Add Transaction',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
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
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type Selector
                            Row(
                              children: [
                                Expanded(
                                  child: _TypeButton(
                                    title: 'Expense',
                                    icon: Icons.arrow_downward_rounded,
                                    isSelected:
                                        _type == TransactionType.expense,
                                    activeColor: const Color(
                                      0xFFBC4B51,
                                    ), // Muted Red/Earth
                                    onTap: () => setState(() {
                                      _type = TransactionType.expense;
                                      _selectedCategoryId = null;
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _TypeButton(
                                    title: 'Income',
                                    icon: Icons.arrow_upward_rounded,
                                    isSelected: _type == TransactionType.income,
                                    activeColor: AppColors.forestGreen,
                                    onTap: () => setState(() {
                                      _type = TransactionType.income;
                                      _selectedCategoryId = null;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            _buildLabel('Transaction Title'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _titleController,
                              hint: 'e.g. Weekly Grocery',
                              icon: Icons.edit_note,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Title is required'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            _buildLabel('Amount'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _amountController,
                              hint: '0.00',
                              icon: Icons.attach_money,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Amount is required';
                                }
                                if (double.tryParse(val) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            _buildLabel('Attach to Budget (Optional)'),
                            const SizedBox(height: 8),
                            _isBudgetsLoading
                                ? const LinearProgressIndicator()
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String?>(
                                        value: _selectedBudgetId,
                                        isExpanded: true,
                                        hint: const Text('None'),
                                        items: [
                                          const DropdownMenuItem<String?>(
                                            value: null,
                                            child: Text('No Budget'),
                                          ),
                                          ..._budgets.map(
                                            (b) => DropdownMenuItem<String?>(
                                              value: b.id,
                                              child: Text(b.name),
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) => setState(
                                          () => _selectedBudgetId = val,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 32),

                            _buildLabel('Category'),
                            const SizedBox(height: 16),
                            _isCategoriesLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: filteredCategories.map((cat) {
                                      final isSelected =
                                          _selectedCategoryId == cat.id;
                                      return GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedCategoryId = cat.id,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? cat.color
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.03,
                                                ),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: isSelected
                                                  ? cat.color
                                                  : Colors.grey[200]!,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                CategoryIcons.getIcon(cat.icon),
                                                size: 18,
                                                color: isSelected
                                                    ? Colors.white
                                                    : cat.color,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                cat.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF1E1E2D),
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                            const SizedBox(height: 48),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveTransaction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonBackground,
                                  foregroundColor: AppColors.buttonForeground,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'SAVE TRANSACTION',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
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
        color: Color(0xFF1E1E2D),
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
        style: const TextStyle(
          color: Color(0xFF1E1E2D),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.gradientEnd, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? activeColor : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
