import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

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
}
