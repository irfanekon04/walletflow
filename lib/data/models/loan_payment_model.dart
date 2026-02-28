import 'package:hive/hive.dart';

part 'loan_payment_model.g.dart';

@HiveType(typeId: 9)
class LoanPaymentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String loanId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  String? userId;

  LoanPaymentModel({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
    this.isSynced = false,
    this.userId,
  });

  LoanPaymentModel copyWith({
    String? id,
    String? loanId,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    bool? isSynced,
    String? userId,
  }) {
    return LoanPaymentModel(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanId': loanId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory LoanPaymentModel.fromJson(Map<String, dynamic> json) {
    return LoanPaymentModel(
      id: json['id'] as String,
      loanId: json['loanId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }
}
