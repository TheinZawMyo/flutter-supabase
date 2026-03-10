import 'package:flutter/material.dart';
import 'package:flutter_supabase/constants/app_colors.dart';
import 'package:flutter_supabase/models/budget.dart';
import 'package:flutter_supabase/models/settings.dart';
import 'package:flutter_supabase/services/database_service.dart';
import 'package:flutter_supabase/utils/formatters.dart';
import 'package:flutter_supabase/add_budget_page.dart';
import 'package:flutter_supabase/transactions_page.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final DatabaseService _dbService = DatabaseService();
  List<BudgetModel> _budgets = [];
  Map<String, double> _spentAmounts = {};
  bool _isLoading = true;
  AppSettings? _settings;

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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final budgets = await _dbService.getBudgets();
      final settings = await _dbService.getSettings();

      Map<String, double> spent = {};
      for (var b in budgets) {
        spent[b.id] = await _dbService.getSpentAmount(b.id);
      }

      setState(() {
        _budgets = budgets;
        _spentAmounts = spent;
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      setState(() => _isLoading = false);
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
            // Header
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
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
                          'Budgets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Optional: Add a simple summary in header if desired
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _budgets.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _budgets.length,
                              itemBuilder: (context, index) {
                                final budget = _budgets[index];
                                final spent = _spentAmounts[budget.id] ?? 0;
                                return _buildBudgetCard(budget, spent);
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetPage()),
          );
          if (result == true) _loadData();
        },
        backgroundColor: AppColors.forestGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.dustyGreen,
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.sageGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your spending by creating a budget plan.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetModel budget, double spent) {
    final percent = (spent / budget.amount).clamp(0.0, 1.0);
    final isOver = spent > budget.amount;
    final remaining = (budget.amount - spent).clamp(0.0, budget.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionsPage(
                  budgetId: budget.id,
                  budgetName: budget.name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepestGreen,
                            ),
                          ),
                          Text(
                            budget.period.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.sageGreen,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddBudgetPage(budget: budget),
                            ),
                          );
                          if (result == true) _loadData();
                        } else if (val == 'delete') {
                          _confirmDelete(budget);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.formatCurrency(
                        spent,
                        code: _settings?.currencyCode,
                        symbol: _settings?.currencySymbol,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOver
                            ? Colors.redAccent
                            : AppColors.deepestGreen,
                      ),
                    ),
                    Text(
                      'of ${Formatters.formatCurrency(budget.amount, code: _settings?.currencyCode, symbol: _settings?.currencySymbol)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: AppColors.paleGreen,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOver ? Colors.redAccent : AppColors.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOver ? 'Over Budget' : 'Remaining',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOver ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(
                        isOver ? (spent - budget.amount) : remaining,
                        code: _settings?.currencyCode,
                        symbol: _settings?.currencySymbol,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isOver ? Colors.redAccent : AppColors.sageGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This will not delete the associated transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbService.deleteBudget(budget.id);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
