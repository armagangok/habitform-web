// import '../../core.dart';

// final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

// int number = 0;

// extension EasyString on String {
//   ThemeMode toThemeMode() {
//     switch (this) {
//       case "ThemeMode.dark":
//         return ThemeMode.dark;
//       case "ThemeMode.light":
//         return ThemeMode.light;
//       case "ThemeMode.system":
//         return ThemeMode.system;
//       default:
//         return ThemeMode.system;
//     }
//   }
// }

// class ThemeNotifier extends Notifier<ThemeMode> {
//   @override
//   build() {
//     final themeMode = HiveHelper.shared.getData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey);

//     if (themeMode == null) {
//       HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.dark.toString());
//       return ThemeMode.dark;
//     } else if (themeMode.toThemeMode() == ThemeMode.dark) {
//       return ThemeMode.dark;
//     } else if (themeMode.toThemeMode() == ThemeMode.light) {
//       return ThemeMode.light;
//     } else if (themeMode.toThemeMode() == ThemeMode.system) {
//       return ThemeMode.system;
//     } else {
//       return ThemeMode.system;
//     }
//   }

//   void switchThemeMode() {
//     switch (number) {
//       case 0:
//         HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.light.toString());

//         state = ThemeMode.light;
//         number = 1;
//       case 1:
//         HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.dark.toString());

//         state = ThemeMode.dark;
//         number = 2;
//       case 2:
//         HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.system.toString());

//         state = ThemeMode.system;
//         number = 0;
//     }
//   }

//   void setDark() {
//     HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.dark.toString());

//     state = ThemeMode.dark;
//     number = 2;
//   }

//   void setLight() {
//     HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.light.toString());

//     state = ThemeMode.light;
//     number = 2;
//   }

//   void setSystem() {
//     HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.system.toString());

//     state = ThemeMode.system;
//     number = 2;
//   }
// }
