/// Web build: no in-app billing SDK. Pro status comes from [purchaseProvider] (Firestore + cache).
class PurchaseService {
  const PurchaseService._();

  /// Reserved for native apps that linked a billing SDK user id; no-op on web.
  static Future<void> logIn(String firebaseUid) async {}
}
