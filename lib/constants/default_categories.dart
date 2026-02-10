import 'package:flutter/material.dart';
import 'package:flutter_supabase/models/category.dart';

List<TransactionCategory> getDefaultCategories(String userId) {
  return [
    TransactionCategory(
      id: 'food',
      userId: userId,
      name: 'Food & Dining',
      icon: 'restaurant',
      color: Colors.orange,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'transport',
      userId: userId,
      name: 'Transportation',
      icon: 'directions_car',
      color: Colors.blue,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'shopping',
      userId: userId,
      name: 'Shopping',
      icon: 'shopping_bag',
      color: Colors.purple,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'entertainment',
      userId: userId,
      name: 'Entertainment',
      icon: 'movie',
      color: Colors.red,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'health',
      userId: userId,
      name: 'Health',
      icon: 'medical_services',
      color: Colors.green,
      type: CategoryType.expense,
    ),
    TransactionCategory(
      id: 'salary',
      userId: userId,
      name: 'Salary',
      icon: 'payments',
      color: Colors.teal,
      type: CategoryType.income,
    ),
    TransactionCategory(
      id: 'investment',
      userId: userId,
      name: 'Investment',
      icon: 'trending_up',
      color: Colors.indigo,
      type: CategoryType.income,
    ),
  ];
}
