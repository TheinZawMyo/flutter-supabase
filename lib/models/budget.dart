enum BudgetPeriod { weekly, monthly, yearly }

class BudgetModel {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.period,
    required this.createdAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      period: _parsePeriod(json['period']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static BudgetPeriod _parsePeriod(String period) {
    switch (period) {
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'yearly':
        return BudgetPeriod.yearly;
      case 'monthly':
      default:
        return BudgetPeriod.monthly;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'period': period.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
