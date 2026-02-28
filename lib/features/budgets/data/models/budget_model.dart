import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 6)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  int month;

  @HiveField(4)
  int year;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  String? userId;

  double spent = 0.0;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
  });

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }
}
