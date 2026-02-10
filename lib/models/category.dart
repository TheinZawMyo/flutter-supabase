import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class TransactionCategory {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final Color color;
  final CategoryType type;

  TransactionCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      icon: json['icon'],
      color: Color(int.parse(json['color'].replaceFirst('#', '0xFF'))),
      type: json['type'] == 'income'
          ? CategoryType.income
          : CategoryType.expense,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color':
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
      'type': type == CategoryType.income ? 'income' : 'expense',
    };
  }
}
