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

  /// File path: assets/app/app_logo_light.png
  AssetGenImage get appLogoLight =>
      const AssetGenImage('assets/app/app_logo_light.png');

  /// File path: assets/app/habitrise_dark_transparent.png
  AssetGenImage get habitriseDarkTransparent =>
      const AssetGenImage('assets/app/habitrise_dark_transparent.png');

  /// File path: assets/app/habitrise_light_transparent.png
  AssetGenImage get habitriseLightTransparent =>
      const AssetGenImage('assets/app/habitrise_light_transparent.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        appLogoDark,
        appLogoLight,
        habitriseDarkTransparent,
        habitriseLightTransparent
      ];
}

class $AssetsIllustrationsGen {
  const $AssetsIllustrationsGen();

  /// File path: assets/illustrations/onboarding_greeting.jpeg
  AssetGenImage get onboardingGreeting =>
      const AssetGenImage('assets/illustrations/onboarding_greeting.jpeg');

  /// List of all assets
  List<AssetGenImage> get values => [onboardingGreeting];
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

  /// File path: assets/translations/tr-TR.json
  String get trTR => 'assets/translations/tr-TR.json';

  /// List of all assets
  List<String> get values => [enUS, trTR];
}

class Assets {
  Assets._();

  static const $AssetsAppGen app = $AssetsAppGen();
  static const $AssetsIllustrationsGen illustrations =
      $AssetsIllustrationsGen();
  static const $AssetsLottieGen lottie = $AssetsLottieGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
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
    bool gaplessPlayback = true,
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
