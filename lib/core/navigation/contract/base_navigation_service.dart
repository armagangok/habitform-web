abstract class INavigationService {
  Future<void> navigateTo({required String path, Object? data});
  Future<void> navigateAndClear({required String path, Object? data});
  void pop();
}
