import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
enum CategoryType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 5)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  CategoryType type;

  @HiveField(3)
  String icon;

  @HiveField(4)
  String color;

  @HiveField(5)
  bool isDefault;

  @HiveField(6)
  bool isHidden;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon = 'category',
    this.color = '#607D8B',
    this.isDefault = false,
    this.isHidden = false,
    required this.createdAt,
    this.userId,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    bool? isDefault,
    bool? isHidden,
    DateTime? createdAt,
    String? userId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values[json['type'] as int],
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? '#607D8B',
      isDefault: json['isDefault'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
    );
  }
}
