import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareTemplateConfig {
  final String id;
  final String title;
  final bool requiresPro;
  const ShareTemplateConfig({required this.id, required this.title, this.requiresPro = false});
}

class ShareTemplateState {
  final int selectedIndex;
  final List<ShareTemplateConfig> templates;

  const ShareTemplateState({required this.selectedIndex, required this.templates});

  ShareTemplateState copyWith({int? selectedIndex, List<ShareTemplateConfig>? templates}) {
    return ShareTemplateState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      templates: templates ?? this.templates,
    );
  }
}

class ShareTemplateNotifier extends Notifier<ShareTemplateState> {
  @override
  ShareTemplateState build() {
    return ShareTemplateState(
      selectedIndex: 0,
      templates: const [
        ShareTemplateConfig(id: 'calendar', title: 'Calendar'),
        ShareTemplateConfig(id: 'overview', title: 'Overview', requiresPro: true),
        ShareTemplateConfig(id: 'heatmap', title: 'Heatmap', requiresPro: true),
        ShareTemplateConfig(id: 'poster', title: 'Poster', requiresPro: true),
      ],
    );
  }

  void select(int index) {
    if (index < 0 || index >= state.templates.length) return;
    state = state.copyWith(selectedIndex: index);
  }

  String get selectedId => state.templates[state.selectedIndex].id;
}

final shareTemplateProvider = NotifierProvider<ShareTemplateNotifier, ShareTemplateState>(() {
  return ShareTemplateNotifier();
});
