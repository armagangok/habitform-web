import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core.dart';
import '../../widgets/flushbar_widget.dart';

const _privacyPolicyLink = "https://docs.google.com/document/d/e/2PACX-1vQ76kvKNioMD6L4Y0JvxcBHB2AMr7tIZyN2O6WJeva1ZYkzybIFQsbLhRE3Qdj83ewC_ICzovvb8EmL/pub";
const _termsOfUseLink = "https://docs.google.com/document/d/e/2PACX-1vRVAZkWkWzZjyxwR4ZKMxIxIowwKJPNWEI9BZTrpfYIuZlvwPUW9ZPNwU76V4yiOmw_ORaLlLuXXVjz/pub";
const _twitterArmagan = "https://x.com/armaganrun";
const _twitterPomoDone = "https://x.com/HabitRise";

class UrlLauncherHelper {
  const UrlLauncherHelper._();

  static Future<void> requestEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'appsweatmobile@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Support',
      }),
    );

    try {
      final response = await launchUrl(emailLaunchUri);
      LogHelper.shared.debugPrint("$response");
      if (response) return;
      AppFlushbar.shared.warningFlushbar(LocaleKeys.errors_try_again.tr());
    } on PlatformException catch (e) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.errors_try_again.tr());
    }
  }

  static Future<void> goToAppMarketPage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? "com.appsweat.pomodoro_app" : '6657948266';
      final url = Uri.parse(
        Platform.isAndroid ? "market://details?id=$appId" : "https://apps.apple.com/app/id$appId",
      );
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static Future<void> openPrivacyPolicy() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await launchUrl(
        Uri.parse(_privacyPolicyLink),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static Future<void> openTermsOfUse() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await launchUrl(
        Uri.parse(_termsOfUseLink),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static Future<void> openTwitter() async {
    try {
      await launchUrl(
        Uri.parse(_twitterArmagan),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }

  static Future<void> openPomoDoneTwitter() async {
    try {
      await launchUrl(
        Uri.parse(_twitterPomoDone),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }
}
