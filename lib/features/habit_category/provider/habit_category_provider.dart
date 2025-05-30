import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/habit_category_model.dart';
import '../service/habit_category_service.dart';

/// Service provider
final habitCategoryServiceProvider = Provider<HabitCategoryService>((ref) {
  throw UnimplementedError('Initialize this provider with the service instance');
});

/// Provider for selected category IDs
final selectedCategoriesProvider = Provider<Set<String>>((ref) {
  return ref.watch(habitCategoryProvider).whenData((state) => state.selectedCategoryIds).value ?? {};
});

/// Main provider that handles both categories and selection
final habitCategoryProvider = StateNotifierProvider<HabitCategoryNotifier, AsyncValue<HabitCategoryState>>((ref) {
  return HabitCategoryNotifier(ref.watch(habitCategoryServiceProvider));
});

class HabitCategoryState {
  final List<HabitCategory> categories;
  final Set<String> selectedCategoryIds;

  const HabitCategoryState({
    required this.categories,
    this.selectedCategoryIds = const {},
  });

  HabitCategoryState copyWith({
    List<HabitCategory>? categories,
    Set<String>? selectedCategoryIds,
    bool? allowMultiple,
  }) {
    return HabitCategoryState(
      categories: categories ?? this.categories,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
    );
  }
}

class HabitCategoryNotifier extends StateNotifier<AsyncValue<HabitCategoryState>> {
  final HabitCategoryService _service;

  HabitCategoryNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _service.getCategories();
      state = AsyncValue.data(HabitCategoryState(categories: categories));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createCategory(String name, String icon) async {
    try {
      final category = HabitCategory.custom(name: name, icon: icon);
      await _service.createCategory(category);
      await loadCategories();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _service.deleteCategory(categoryId);
      await loadCategories();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCategory(String categoryId, String name, String icon) async {
    try {
      await _service.updateCategory(categoryId, name, icon);
      await loadCategories();
    } catch (e) {
      // Handle error
    }
  }

  void toggleCategorySelection(String categoryId) {
    state.whenData((currentState) {
      final newSelectedIds = Set<String>.from(currentState.selectedCategoryIds);

      if (newSelectedIds.contains(categoryId)) {
        newSelectedIds.remove(categoryId);
      } else {
        newSelectedIds.add(categoryId);
      }

      state = AsyncValue.data(currentState.copyWith(
        selectedCategoryIds: newSelectedIds,
      ));
    });
  }

  

  void setSelectedCategories(Set<String> categoryIds) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        selectedCategoryIds: categoryIds,
      ));
    });
  }
}
