import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../data/models/category_model.dart';
import '../controllers/category_controller.dart';
import '../widgets/category_dialogs.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoryList(type: CategoryType.expense),
            _CategoryList(type: CategoryType.income),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => CategoryDialogs.showAddEditCategory(
            context,
            initialType: DefaultTabController.of(context).index == 0
                ? CategoryType.expense
                : CategoryType.income,
          ),
          icon: const Icon(Icons.add),
          label: const Text('New Category'),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final CategoryType type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final theme = Theme.of(context);

    return Obx(() {
      final categories = type == CategoryType.expense
          ? controller.expenseCategories
          : controller.incomeCategories;

      if (categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              const Text('No categories found'),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = AppColors.fromHex(category.color);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: theme.colorScheme.surfaceContainerLow,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.getIconData(category.icon),
                  color: color,
                ),
              ),
              title: Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: category.isDefault
                  ? Text(
                      'Default Category',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => CategoryDialogs.showAddEditCategory(
                      context,
                      category: category,
                      initialType: type,
                    ),
                  ),
                  if (!category.isDefault)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => _confirmDelete(context, controller, category),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryController controller,
    CategoryModel category,
  ) async {
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${category.name}"? This will not delete transactions using this category.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await controller.deleteCategory(category.id);
    }
  }
}
