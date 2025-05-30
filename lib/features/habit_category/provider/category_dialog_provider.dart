import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the category creation dialog state
final categoryDialogProvider = StateNotifierProvider.autoDispose<CategoryDialogNotifier, CategoryDialogState>(
  (ref) => CategoryDialogNotifier(),
);

/// State class for category creation dialog
class CategoryDialogState {
  final String? selectedIconString;
  final String categoryName;

  CategoryDialogState({
    this.selectedIconString,
    this.categoryName = '',
  });

  CategoryDialogState copyWith({
    String? selectedIconString,
    String? categoryName,
    bool clearIconString = false,
  }) {
    return CategoryDialogState(
      selectedIconString: clearIconString ? null : (selectedIconString ?? this.selectedIconString),
      categoryName: categoryName ?? this.categoryName,
    );
  }

  bool get isValid => categoryName.trim().isNotEmpty;
}

/// Notifier to manage category dialog state
class CategoryDialogNotifier extends StateNotifier<CategoryDialogState> {
  CategoryDialogNotifier() : super(CategoryDialogState());

  /// Set the category name
  void setCategoryName(String name) {
    state = state.copyWith(categoryName: name);
  }

  /// Set the selected icon
  void setSelectedIcon(String iconString) {
    state = state.copyWith(selectedIconString: iconString);
  }

  /// Reset the dialog state
  void resetState() {
    state = CategoryDialogState();
  }
}
