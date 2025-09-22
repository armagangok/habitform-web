import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';

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
      templates: [
        ShareTemplateConfig(id: 'calendar', title: LocaleKeys.share_templates_calendar.tr()),
        ShareTemplateConfig(id: 'overview', title: LocaleKeys.share_templates_overview.tr(), requiresPro: true),
        ShareTemplateConfig(id: 'heatmap', title: LocaleKeys.share_templates_heatmap.tr(), requiresPro: true),
        ShareTemplateConfig(id: 'poster', title: LocaleKeys.share_templates_poster.tr(), requiresPro: true),
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
