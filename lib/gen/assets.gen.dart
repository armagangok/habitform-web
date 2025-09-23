// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsAnimationsGen {
  const $AssetsAnimationsGen();

  /// File path: assets/animations/astronout.json
  String get astronout => 'assets/animations/astronout.json';

  /// File path: assets/animations/completion.json
  String get completion => 'assets/animations/completion.json';

  /// List of all assets
  List<String> get values => [astronout, completion];
}

class $AssetsAppGen {
  const $AssetsAppGen();

  /// File path: assets/app/app_logo_dark.png
  AssetGenImage get appLogoDark =>
      const AssetGenImage('assets/app/app_logo_dark.png');

  /// List of all assets
  List<AssetGenImage> get values => [appLogoDark];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/onboarding
  $AssetsImagesOnboardingGen get onboarding =>
      const $AssetsImagesOnboardingGen();
}

class $AssetsLottieGen {
  const $AssetsLottieGen();

  /// File path: assets/lottie/rocket_animation.json
  String get rocketAnimation => 'assets/lottie/rocket_animation.json';

  /// List of all assets
  List<String> get values => [rocketAnimation];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/en-US.json
  String get enUS => 'assets/translations/en-US.json';

  /// File path: assets/translations/fr-FR.json
  String get frFR => 'assets/translations/fr-FR.json';

  /// File path: assets/translations/it-IT.json
  String get itIT => 'assets/translations/it-IT.json';

  /// File path: assets/translations/tr-TR.json
  String get trTR => 'assets/translations/tr-TR.json';

  /// File path: assets/translations/zh-Hans.json
  String get zhHans => 'assets/translations/zh-Hans.json';

  /// List of all assets
  List<String> get values => [enUS, frFR, itIT, trTR, zhHans];
}

class $AssetsImagesOnboardingGen {
  const $AssetsImagesOnboardingGen();

  /// File path: assets/images/onboarding/aristoteles.png
  AssetGenImage get aristoteles =>
      const AssetGenImage('assets/images/onboarding/aristoteles.png');

  /// File path: assets/images/onboarding/badHabits.png
  AssetGenImage get badHabits =>
      const AssetGenImage('assets/images/onboarding/badHabits.png');

  /// File path: assets/images/onboarding/orangeFruit.png
  AssetGenImage get orangeFruit =>
      const AssetGenImage('assets/images/onboarding/orangeFruit.png');

  /// File path: assets/images/onboarding/smallSteps.png
  AssetGenImage get smallSteps =>
      const AssetGenImage('assets/images/onboarding/smallSteps.png');

  /// File path: assets/images/onboarding/waterTree.png
  AssetGenImage get waterTree =>
      const AssetGenImage('assets/images/onboarding/waterTree.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [aristoteles, badHabits, orangeFruit, smallSteps, waterTree];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsAnimationsGen animations = $AssetsAnimationsGen();
  static const $AssetsAppGen app = $AssetsAppGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLottieGen lottie = $AssetsLottieGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

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
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
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

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
