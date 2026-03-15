import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/category_model.dart';
import '../controllers/category_controller.dart';

class CategoryDialogs {
  static void showAddEditCategory(
    BuildContext context, {
    CategoryModel? category,
    required CategoryType initialType,
  }) {
    final theme = Theme.of(context);
    final categoryController = Get.find<CategoryController>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final Rx<CategoryType> selectedType = (category?.type ?? initialType).obs;
    final RxString selectedIcon = (category?.icon ?? 'category').obs;
    final RxString selectedColor = (category?.color ?? AppColors.categoryColors.first).obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category == null ? 'Add Category' : 'Edit Category',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SegmentedButton<CategoryType>(
                    segments: const [
                      ButtonSegment(
                        value: CategoryType.expense,
                        label: Text('EXPENSE'),
                      ),
                      ButtonSegment(
                        value: CategoryType.income,
                        label: Text('INCOME'),
                      ),
                    ],
                    selected: {selectedType.value},
                    onSelectionChanged: category == null ? (val) => selectedType.value = val.first : null,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: nameController,
                  label: 'Category Name',
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Icon',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: AppIcons.categoryIcons.length,
                    itemBuilder: (context, index) {
                      final iconName = AppIcons.categoryIcons.keys.elementAt(index);
                      final iconData = AppIcons.categoryIcons[iconName]!;
                      return Obx(() {
                        final isSelected = selectedIcon.value == iconName;
                        return InkWell(
                          onTap: () => selectedIcon.value = iconName,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Color',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: AppColors.categoryColors.length,
                    itemBuilder: (context, index) {
                      final hex = AppColors.categoryColors[index];
                      final color = AppColors.fromHex(hex);
                      return Obx(() {
                        final isSelected = selectedColor.value == hex;
                        return InkWell(
                          onTap: () => selectedColor.value = hex,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: AppStrings.save,
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      if (category == null) {
                        await categoryController.addCategory(
                          name: nameController.text,
                          type: selectedType.value,
                          icon: selectedIcon.value,
                          color: selectedColor.value,
                        );
                      } else {
                        final updated = category.copyWith(
                          name: nameController.text,
                          icon: selectedIcon.value,
                          color: selectedColor.value,
                        );
                        await categoryController.updateCategory(updated);
                      }
                      Get.back();
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
