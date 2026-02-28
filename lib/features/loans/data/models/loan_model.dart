import 'package:hive/hive.dart';

part 'loan_model.g.dart';

@HiveType(typeId: 7)
enum LoanType {
  @HiveField(0)
  lent,
  @HiveField(1)
  owed,
}

@HiveType(typeId: 8)
class LoanModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  LoanType type;

  @HiveField(2)
  String personName;

  @HiveField(3)
  double originalAmount;

  @HiveField(4)
  double remainingAmount;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? note;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  String? userId;

  LoanModel({
    required this.id,
    required this.type,
    required this.personName,
    required this.originalAmount,
    required this.remainingAmount,
    required this.date,
    this.note,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
  });

  double get paidAmount => originalAmount - remainingAmount;
  double get amount => originalAmount;
  set amount(double value) => originalAmount = value;

  LoanModel copyWith({
    String? id,
    LoanType? type,
    String? personName,
    double? originalAmount,
    double? remainingAmount,
    DateTime? date,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
  }) {
    return LoanModel(
      id: id ?? this.id,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      date: date ?? this.date,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'personName': personName,
      'originalAmount': originalAmount,
      'remainingAmount': remainingAmount,
      'date': date.toIso8601String(),
      'note': note,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      type: LoanType.values[json['type'] as int],
      personName: json['personName'] as String,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }
}
