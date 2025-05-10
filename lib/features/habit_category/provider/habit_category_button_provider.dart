import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for storing selected category IDs in the button
final categoryButtonProvider = StateNotifierProvider<CategoryButtonNotifier, List<String>?>((ref) {
  return CategoryButtonNotifier();
});

/// Notifier for managing the selected category IDs
class CategoryButtonNotifier extends StateNotifier<List<String>?> {
  CategoryButtonNotifier() : super(null);

  /// Set the selected category IDs
  void setSelectedCategories(List<String> categoryIds) {
    state = categoryIds;
  }

  /// Add a category ID to the selection
  void addCategory(String categoryId) {
    final currentSelection = state ?? [];
    if (!currentSelection.contains(categoryId)) {
      state = [...currentSelection, categoryId];
    }
  }

  /// Remove a category ID from the selection
  void removeCategory(String categoryId) {
    final currentSelection = state ?? [];
    if (currentSelection.contains(categoryId)) {
      state = currentSelection.where((id) => id != categoryId).toList();
    }
  }

  /// Clear all selected categories
  void clearCategories() {
    state = [];
  }
}
