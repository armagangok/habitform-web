import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the HabitCategoryPage selected categories state
final habitCategoryPageProvider = StateNotifierProvider.autoDispose<HabitCategoryPageNotifier, HabitCategoryPageState>(
  (ref) => HabitCategoryPageNotifier(),
);

/// State class for HabitCategoryPage
class HabitCategoryPageState {
  final List<String> selectedCategoryIds;
  final String? selectedIconString;

  HabitCategoryPageState({
    this.selectedCategoryIds = const [],
    this.selectedIconString,
  });

  HabitCategoryPageState copyWith({
    List<String>? selectedCategoryIds,
    String? selectedIconString,
    bool clearIconString = false,
  }) {
    return HabitCategoryPageState(
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      selectedIconString: clearIconString ? null : (selectedIconString ?? this.selectedIconString),
    );
  }
}

/// Notifier to manage HabitCategoryPage state
class HabitCategoryPageNotifier extends StateNotifier<HabitCategoryPageState> {
  HabitCategoryPageNotifier() : super(HabitCategoryPageState());

  /// Initialize with given category IDs
  void initSelectedCategories(List<String>? categoryIds) {
    if (categoryIds != null && categoryIds.isNotEmpty) {
      state = state.copyWith(selectedCategoryIds: categoryIds);
    }
  }

  /// Toggle category selection based on allowMultiple parameter
  void toggleCategorySelection(String categoryId, bool allowMultiple) {
    final currentSelected = state.selectedCategoryIds;

    if (allowMultiple) {
      // Toggle selection
      if (currentSelected.contains(categoryId)) {
        state = state.copyWith(
          selectedCategoryIds: currentSelected.where((id) => id != categoryId).toList(),
        );
      } else {
        state = state.copyWith(
          selectedCategoryIds: [...currentSelected, categoryId],
        );
      }
    } else {
      // Single selection mode
      if (currentSelected.contains(categoryId) && currentSelected.length == 1) {
        state = state.copyWith(selectedCategoryIds: []);
      } else {
        state = state.copyWith(selectedCategoryIds: [categoryId]);
      }
    }
  }

  /// Set the selected icon for category creation
  void setSelectedIcon(String iconString) {
    state = state.copyWith(selectedIconString: iconString);
  }

  /// Clear the selected icon
  void clearSelectedIcon() {
    state = state.copyWith(clearIconString: true);
  }
}
