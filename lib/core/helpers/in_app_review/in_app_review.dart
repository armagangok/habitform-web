import 'package:in_app_review/in_app_review.dart';

import '../../constants/debug_constants.dart';
import '../../core.dart';

final class InAppReviewHelper {
  InAppReviewHelper._();
  static final shared = InAppReviewHelper._();

  Future<void> requestReview() async {
    if (KDebug.rateDebugMode) return;

    try {
      final isAvailable = await InAppReview.instance.isAvailable();

      LogHelper.shared.debugPrint('InAppReviewHelper: $isAvailable');
      if (isAvailable) {
        await InAppReview.instance.requestReview();
      }
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }

  // void openStoreListing() {
  //   try {
  //     InAppReview.instance.openStoreListing(appStoreId: "6657948266");
  //   } catch (e) {
  //     LogHelper.shared.debugPrint('$e');
  //   }
  // }
}
