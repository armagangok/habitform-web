import 'package:flutter_riverpod/flutter_riverpod.dart';

final categorySelectionProvider = StateNotifierProvider.autoDispose<CategorySelectionNotifier, Set<String>>((ref) {
  return CategorySelectionNotifier();
});

class CategorySelectionNotifier extends StateNotifier<Set<String>> {
  CategorySelectionNotifier() : super({});

  void toggleCategory(String categoryId) {
    final newState = Set<String>.from(state);
    if (newState.contains(categoryId)) {
      newState.remove(categoryId);
    } else {
      newState.add(categoryId);
    }
    state = newState;
  }

  void setCategories(Set<String> categories) {
    state = categories;
  }

  void clearSelection() {
    state = {};
  }
}
