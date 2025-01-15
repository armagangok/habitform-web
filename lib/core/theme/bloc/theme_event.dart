part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class InitializeThemeEvent extends ThemeEvent {}

class SwitchThemeEvent extends ThemeEvent {}

class SetDarkThemeEvent extends ThemeEvent {}

class SetLightThemeEvent extends ThemeEvent {}

class SetSystemThemeEvent extends ThemeEvent {}
