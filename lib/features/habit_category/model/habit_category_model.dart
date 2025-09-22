import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/core.dart';

part 'habit_category_model.g.dart';

@HiveType(typeId: 9)
class HabitCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isDefault;

  @HiveField(3)
  final String? icon;

  HabitCategory({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.icon,
  });

  // Factory for default categories
  static List<HabitCategory> getDefaultCategories() {
    return [
      HabitCategory(id: 'daily', name: 'Daily Life', icon: 'houseUser', isDefault: true),
      HabitCategory(id: 'sports', name: 'Sports', icon: 'futbol', isDefault: true),
      HabitCategory(id: 'health', name: 'Health', icon: 'heartSolid', isDefault: true),
      HabitCategory(id: 'nutrition', name: 'Nutrition', icon: 'utensils', isDefault: true),
      HabitCategory(id: 'study', name: 'Study', icon: 'book', isDefault: true),
      HabitCategory(id: 'work', name: 'Work', icon: 'briefcase', isDefault: true),
      HabitCategory(id: 'art', name: 'Art', icon: 'palette', isDefault: true),
      HabitCategory(id: 'finances', name: 'Finances', icon: 'moneyBill', isDefault: true),
      HabitCategory(id: 'social', name: 'Social', icon: 'users', isDefault: true),
    ];
  }

  // Factory for creating custom categories
  factory HabitCategory.custom({
    required String name,
    required String icon,
  }) {
    return HabitCategory(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      isDefault: false,
    );
  }

  HabitCategory copyWith({
    String? id,
    String? name,
    bool? isDefault,
    String? icon,
  }) {
    return HabitCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      icon: icon ?? this.icon,
    );
  }

  /// Get the localized display name for the category
  /// For default categories, returns the localized name
  /// For custom categories, returns the original name
  String getDisplayName() {
    if (isDefault) {
      return _getLocalizedDefaultName(id);
    }
    return name;
  }

  /// Get localized name for default categories based on their ID
  String _getLocalizedDefaultName(String categoryId) {
    switch (categoryId) {
      case 'daily':
        return LocaleKeys.habit_category_default_categories_daily_life.tr();
      case 'sports':
        return LocaleKeys.habit_category_default_categories_sports.tr();
      case 'health':
        return LocaleKeys.habit_category_default_categories_health.tr();
      case 'nutrition':
        return LocaleKeys.habit_category_default_categories_nutrition.tr();
      case 'study':
        return LocaleKeys.habit_category_default_categories_study.tr();
      case 'work':
        return LocaleKeys.habit_category_default_categories_work.tr();
      case 'art':
        return LocaleKeys.habit_category_default_categories_art.tr();
      case 'finances':
        return LocaleKeys.habit_category_default_categories_finances.tr();
      case 'social':
        return LocaleKeys.habit_category_default_categories_social.tr();
      default:
        return name; // Fallback to original name
    }
  }
}
