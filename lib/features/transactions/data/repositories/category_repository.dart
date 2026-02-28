import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final _uuid = const Uuid();

  Box<CategoryModel> get _box => Hive.box<CategoryModel>('categories');

  List<CategoryModel> getAll() {
    return _box.values.toList();
  }

  List<CategoryModel> getByType(CategoryType type) {
    return _box.values
        .where((c) => c.type == type && !c.isHidden)
        .toList();
  }

  CategoryModel? getById(String id) {
    try {
      return _box.values.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<CategoryModel> create({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  }) async {
    final category = CategoryModel(
      id: _uuid.v4(),
      name: name,
      type: type,
      icon: icon ?? 'category',
      color: color ?? '#607D8B',
      isDefault: false,
      createdAt: DateTime.now(),
    );
    await _box.put(category.id, category);
    return category;
  }

  Future<CategoryModel> update(CategoryModel category) async {
    await _box.put(category.id, category);
    return category;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> initDefaultCategories() async {
    if (_box.isEmpty) {
      await _createDefaultCategories();
    }
  }

  Future<void> _createDefaultCategories() async {
    final defaultExpenseCategories = [
      {'name': 'Food', 'icon': 'restaurant', 'color': '#FF9800'},
      {'name': 'Transport', 'icon': 'directions_car', 'color': '#2196F3'},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#E91E63'},
      {'name': 'Bills', 'icon': 'receipt_long', 'color': '#9C27B0'},
      {'name': 'Entertainment', 'icon': 'movie', 'color': '#00BCD4'},
      {'name': 'Health', 'icon': 'medical_services', 'color': '#4CAF50'},
      {'name': 'Education', 'icon': 'school', 'color': '#FF5722'},
      {'name': 'Others', 'icon': 'more_horiz', 'color': '#607D8B'},
    ];

    final defaultIncomeCategories = [
      {'name': 'Salary', 'icon': 'work', 'color': '#4CAF50'},
      {'name': 'Freelance', 'icon': 'computer', 'color': '#2196F3'},
      {'name': 'Business', 'icon': 'business', 'color': '#9C27B0'},
      {'name': 'Investment', 'icon': 'trending_up', 'color': '#00BCD4'},
      {'name': 'Gift', 'icon': 'card_giftcard', 'color': '#E91E63'},
      {'name': 'Others', 'icon': 'more_horiz', 'color': '#607D8B'},
    ];

    for (final cat in defaultExpenseCategories) {
      final category = CategoryModel(
        id: _uuid.v4(),
        name: cat['name']!,
        type: CategoryType.expense,
        icon: cat['icon']!,
        color: cat['color']!,
        isDefault: true,
        createdAt: DateTime.now(),
      );
      await _box.put(category.id, category);
    }

    for (final cat in defaultIncomeCategories) {
      final category = CategoryModel(
        id: _uuid.v4(),
        name: cat['name']!,
        type: CategoryType.income,
        icon: cat['icon']!,
        color: cat['color']!,
        isDefault: true,
        createdAt: DateTime.now(),
      );
      await _box.put(category.id, category);
    }
  }
}
