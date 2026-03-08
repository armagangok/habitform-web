import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/habit_category_service.dart';
import 'habit_category_provider.dart';

Future<List<Override>> setupHabitCategoryProviders() async {
  // Create the service
  final habitCategoryService = HabitCategoryService();

  // Return the provider override
  return [
    habitCategoryServiceProvider.overrideWithValue(habitCategoryService),
  ];
}
