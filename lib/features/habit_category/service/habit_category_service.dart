import 'package:hive_flutter/hive_flutter.dart';

import '/core/core.dart';
import '../model/habit_category_model.dart';

abstract class HabitCategoryServiceInterface {
  Future<List<HabitCategory>> getCategories();
  Future<HabitCategory> createCategory(HabitCategory category);
  Future<void> deleteCategory(String categoryId);
  Future<void> updateCategory(String categoryId, String name, String icon);
}

class HabitCategoryService implements HabitCategoryServiceInterface {
  final Box<HabitCategory> _box;

  HabitCategoryService(this._box);

  static Future<HabitCategoryService> init() async {
    final box = await Hive.openBox<HabitCategory>(HiveBoxes.habitCategoryBox);
    return HabitCategoryService(box);
  }

  @override
  Future<List<HabitCategory>> getCategories() async {
    // Combine default categories with custom ones from storage
    final customCategories = _box.values.toList();
    return [
      ...HabitCategory.getDefaultCategories(),
      ...customCategories,
    ];
  }

  @override
  Future<HabitCategory> createCategory(HabitCategory category) async {
    await _box.put(category.id, category);
    return category;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final category = _box.get(categoryId);
    if (category == null) return;

    await _box.delete(categoryId);
  }

  @override
  Future<void> updateCategory(String categoryId, String name, String icon) async {
    final category = _box.get(categoryId);
    if (category == null) return;

    final updatedCategory = category.copyWith(
      name: name,
      icon: icon,
    );

    await _box.put(categoryId, updatedCategory);
  }
}
