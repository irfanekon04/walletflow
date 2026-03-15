import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../../../core/constants/app_constants.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepo = CategoryRepository();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> expenseCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> incomeCategories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() {
    isLoading.value = true;
    final all = _categoryRepo.getAll();
    categories.value = all;
    expenseCategories.value = all.where((c) => c.type == CategoryType.expense && !c.isHidden).toList();
    incomeCategories.value = all.where((c) => c.type == CategoryType.income && !c.isHidden).toList();
    isLoading.value = false;
  }

  Future<void> addCategory({
    required String name,
    required CategoryType type,
    required String icon,
    required String color,
  }) async {
    await _categoryRepo.create(
      name: name,
      type: type,
      icon: icon,
      color: color,
    );
    loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoryRepo.update(category);
    loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryRepo.delete(id);
    loadCategories();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  IconData getIconData(String iconName) {
    return AppIcons.categoryIcons[iconName] ?? Icons.category_outlined;
  }
}
