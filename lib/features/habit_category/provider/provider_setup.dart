import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '/core/core.dart';
import '../model/habit_category_model.dart';
import '../service/habit_category_service.dart';
import 'habit_category_provider.dart';

Future<List<Override>> setupHabitCategoryProviders() async {
  // Open the Hive box if it's not already open
  Box<HabitCategory> box;
  if (!Hive.isBoxOpen(HiveBoxes.habitCategoryBox)) {
    box = await Hive.openBox<HabitCategory>(HiveBoxes.habitCategoryBox);
  } else {
    box = Hive.box<HabitCategory>(HiveBoxes.habitCategoryBox);
  }

  // Create the service
  final habitCategoryService = HabitCategoryService(box);

  // Return the provider override
  return [
    habitCategoryServiceProvider.overrideWithValue(habitCategoryService),
  ];
}
