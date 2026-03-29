/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsAppGen {
  const $AssetsAppGen();

  /// File path: assets/app/app_logo_dark.png
  AssetGenImage get appLogoDark =>
      const AssetGenImage('assets/app/app_logo_dark.png');

  /// List of all assets
  List<AssetGenImage> get values => [appLogoDark];
}

class $AssetsScreenshotsGen {
  const $AssetsScreenshotsGen();

  /// File path: assets/screenshots/cloud_sync.png
  AssetGenImage get cloudSync =>
      const AssetGenImage('assets/screenshots/cloud_sync.png');

  /// File path: assets/screenshots/customize.png
  AssetGenImage get customize =>
      const AssetGenImage('assets/screenshots/customize.png');

  /// File path: assets/screenshots/difficulty_goal.png
  AssetGenImage get difficultyGoal =>
      const AssetGenImage('assets/screenshots/difficulty_goal.png');

  /// File path: assets/screenshots/export_import.png
  AssetGenImage get exportImport =>
      const AssetGenImage('assets/screenshots/export_import.png');

  /// File path: assets/screenshots/habit_map.png
  AssetGenImage get habitMap =>
      const AssetGenImage('assets/screenshots/habit_map.png');

  /// File path: assets/screenshots/habit_probability.png
  AssetGenImage get habitProbability =>
      const AssetGenImage('assets/screenshots/habit_probability.png');

  /// File path: assets/screenshots/home_widget.png
  AssetGenImage get homeWidget =>
      const AssetGenImage('assets/screenshots/home_widget.png');

  /// File path: assets/screenshots/share.png
  AssetGenImage get share =>
      const AssetGenImage('assets/screenshots/share.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        cloudSync,
        customize,
        difficultyGoal,
        exportImport,
        habitMap,
        habitProbability,
        homeWidget,
        share
      ];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/ar-SA.json
  String get arSA => 'assets/translations/ar-SA.json';

  /// File path: assets/translations/en-US.json
  String get enUS => 'assets/translations/en-US.json';

  /// File path: assets/translations/es-ES.json
  String get esES => 'assets/translations/es-ES.json';

  /// File path: assets/translations/fi-FI.json
  String get fiFI => 'assets/translations/fi-FI.json';

  /// File path: assets/translations/fr-FR.json
  String get frFR => 'assets/translations/fr-FR.json';

  /// File path: assets/translations/it-IT.json
  String get itIT => 'assets/translations/it-IT.json';

  /// File path: assets/translations/ja-JP.json
  String get jaJP => 'assets/translations/ja-JP.json';

  /// File path: assets/translations/tr-TR.json
  String get trTR => 'assets/translations/tr-TR.json';

  /// File path: assets/translations/zh-Hans.json
  String get zhHans => 'assets/translations/zh-Hans.json';

  /// List of all assets
  List<String> get values =>
      [arSA, enUS, esES, fiFI, frFR, itIT, jaJP, trTR, zhHans];
}

class Assets {
  Assets._();

  static const String aEnv = '.env';
  static const $AssetsAppGen app = $AssetsAppGen();
  static const $AssetsScreenshotsGen screenshots = $AssetsScreenshotsGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
