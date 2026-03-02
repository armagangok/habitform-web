import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/translation_service.dart';

extension TranslationExtension on String {
  String trWithRef(WidgetRef ref) {
    final translationService = ref.read(translationServiceProvider);
    return translationService.translate(this);
  }
}
