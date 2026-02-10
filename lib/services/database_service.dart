import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_supabase/models/transaction.dart';
import 'package:flutter_supabase/models/budget.dart';
import 'package:flutter_supabase/models/category.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Transactions
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .order('date', ascending: false);

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
}
