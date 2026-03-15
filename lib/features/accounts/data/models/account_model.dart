import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 0)
enum AccountType {
  @HiveField(0)
  cash,
  @HiveField(1)
  bank,
  @HiveField(2)
  mfs,
  @HiveField(3)
  card,
}

@HiveType(typeId: 1)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  AccountType type;

  @HiveField(3)
  double balance;

  @HiveField(4)
  double? creditLimit;

  @HiveField(5)
  String icon;

  @HiveField(6)
  String color;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  String? userId;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.creditLimit,
    this.icon = 'wallet',
    this.color = '#2196F3',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.userId,
  });

  double get availableBalance {
    if (type == AccountType.card && creditLimit != null) {
      return creditLimit! - balance;
    }
    return balance;
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    double? creditLimit,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'balance': balance,
      'creditLimit': creditLimit,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values[json['type'] as int],
      balance: (json['balance'] as num).toDouble(),
      creditLimit: json['creditLimit'] != null
          ? (json['creditLimit'] as num).toDouble()
          : null,
      icon: json['icon'] as String? ?? 'wallet',
      color: json['color'] as String? ?? '#2196F3',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }
}
