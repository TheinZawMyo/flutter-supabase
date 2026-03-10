import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_supabase/models/transaction.dart';
import 'package:flutter_supabase/models/budget.dart';
import 'package:flutter_supabase/models/category.dart';
import 'package:flutter_supabase/models/settings.dart';
import 'package:flutter_supabase/constants/default_categories.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Transactions
  Future<List<TransactionModel>> getTransactions({String? budgetId}) async {
    var query = _client.from('transactions').select();

    if (budgetId != null) {
      query = query.eq('budget_id', budgetId);
    }

    final response = await query.order('date', ascending: false);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _client.from('transactions').insert(transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().match({'id': id});
  }

  // Budgets
  Future<List<BudgetModel>> getBudgets() async {
    final response = await _client.from('budgets').select();
    return (response as List).map((e) => BudgetModel.fromJson(e)).toList();
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _client.from('budgets').insert(budget.toJson());
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await _client.from('budgets').update(budget.toJson()).match({
      'id': budget.id,
    });
  }

  Future<void> deleteBudget(String id) async {
    await _client.from('budgets').delete().match({'id': id});
  }

  // Categories
  Future<List<TransactionCategory>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List)
        .map((e) => TransactionCategory.fromJson(e))
        .toList();
  }

  Future<void> addCategory(TransactionCategory category) async {
    await _client.from('categories').insert(category.toJson());
  }

  Future<List<TransactionCategory>> getAllCategories() async {
    final customCategories = await getCategories();
    final userId = _client.auth.currentUser?.id ?? '';
    final defaultCategories = getDefaultCategories(userId);
    return [...defaultCategories, ...customCategories];
  }

  // Settings
  Future<AppSettings> getSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _client
        .from('settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      final defaultSettings = AppSettings(
        userId: userId,
        currencyCode: 'MMK',
        currencySymbol: 'Ks',
      );
      await updateSettings(defaultSettings);
      return defaultSettings;
    }

    return AppSettings.fromJson(response);
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _client.from('settings').upsert(settings.toJson());
  }

  // Analytics Helpers
  Future<Map<String, double>> getTotals() async {
    final transactions = await getTransactions();
    double income = 0;
    double expenses = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expenses += tx.amount;
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  Future<Map<String, double>> getCategorySpends() async {
    final transactions = await getTransactions();
    final Map<String, double> categorySpends = {};

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        categorySpends[tx.categoryId] =
            (categorySpends[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    return categorySpends;
  }

  Future<double> getSpentAmount(String budgetId) async {
    final transactions = await getTransactions(budgetId: budgetId);
    double spent = 0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        spent += tx.amount;
      }
    }
    return spent;
  }
}
