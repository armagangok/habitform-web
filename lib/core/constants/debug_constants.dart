const _activeAllDebugMode = true;

abstract final class KDebug {
  // enables debug mode for print
  static const debugModeEnabled = _activeAllDebugMode;

  // reduces time for timer
  static const timerDebugEnabled = _activeAllDebugMode;

  // disables rate app dialog for timer
  static const rateDebugMode = _activeAllDebugMode;

  // adds some dummy text to controller
  // for testing the TextFields
  static const uiDebugMode = _activeAllDebugMode;

  // paywall widget will not be showing
  static const purchaseDebugMode = _activeAllDebugMode;
}
