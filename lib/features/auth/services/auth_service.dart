import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/helpers/logger/logger.dart';
import '../../../models/user/user_model.dart';

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'habitformdatabase',
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    await _updateUserData(credential.user);
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    await _updateUserData(credential.user);
    return credential;
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _updateUserData(credential.user);
    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _updateUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _updateUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Apple Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> linkWithEmailAndPassword(String email, String password) async {
    final user = _auth.currentUser;
    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.linkWithCredential(credential);
      await user.sendEmailVerification();
      await _updateUserData(user);
    }
  }

  Future<void> reauthenticateWithEmailPassword(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');
    await user.updateDisplayName(displayName);
    await user.reload();
    await _updateUserData(_auth.currentUser);
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');
    final userRef = _firestore.collection('users').doc(user.uid);
    try {
      await userRef.delete();
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error deleting Firestore user doc: $e');
    }
    await user.delete();
  }

  bool get hasEmailPasswordProvider {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  Future<void> _updateUserData(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      updatedAt: DateTime.now(),
    );

    try {
      final profileOnly = userModel.toJson()
        ..remove('isSubscribed')
        ..remove('subscriptionProductId')
        ..remove('subscriptionExpirationDate');
      await userRef.set(profileOnly, SetOptions(merge: true));
      LogHelper.shared.debugPrint('✅ User profile updated in Firestore for ${user.uid}');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error updating user data: $e');
    }
  }

  Stream<UserModel?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromJson(snapshot.data()!);
    });
  }
}
