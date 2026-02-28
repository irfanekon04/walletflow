import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String accountId;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String? categoryId;

  @HiveField(5)
  String? note;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String? toAccountId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  String? userId;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.categoryId,
    this.note,
    required this.date,
    this.toAccountId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
  });

  TransactionModel copyWith({
    String? id,
    String? accountId,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    String? toAccountId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      toAccountId: toAccountId ?? this.toAccountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.index,
      'amount': amount,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'toAccountId': toAccountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      type: TransactionType.values[json['type'] as int],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      toAccountId: json['toAccountId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }
}
