import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/helpers/hive/hive_helper.dart';
import '../../../core/helpers/logger/logger.dart';
import '../../../models/user/user_model.dart';

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'habitformdatabase',
  );

  Stream<User?> get authStateChanges => _auth.userChanges();

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
    try {
      await HiveHelper.shared.clearAllLocalData();
      await _auth.signOut();
      await GoogleSignIn.instance.signOut(); // Ensure Google sign-out as well
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error during sign out: $e');
      rethrow;
    }
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

  Future<void> updateProfilePhoto(String filePath) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');

    // 1. Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('user_photos').child('${user.uid}.jpg');
    final uploadTask = await storageRef.putFile(File(filePath));
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // 2. Update Auth Profile
    await user.updatePhotoURL(downloadUrl);
    await user.reload();

    // 3. Update Firestore
    await _updateUserData(_auth.currentUser);
  }

  Future<void> deleteProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');

    try {
      // 1. Delete from Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('user_photos').child('${user.uid}.jpg');
      await storageRef.delete();
    } catch (e) {
      // If file doesn't exist, we still want to clear the URL in Auth/Firestore
      LogHelper.shared.debugPrint('⚠️ Error deleting photo from Storage (might not exist): $e');
    }

    // 2. Clear Auth Profile photoURL
    await user.updatePhotoURL(null);
    await user.reload();

    // 3. Update Firestore
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
    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'No user logged in');
    }

    final uid = user.uid;
    final userRef = _firestore.collection('users').doc(uid);
    final habitsRef = userRef.collection('habits');

    try {
      // 1. Delete all habits in the subcollection
      final habitsSnapshot = await habitsRef.get();
      if (habitsSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in habitsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        LogHelper.shared.debugPrint('✅ Deleted ${habitsSnapshot.docs.length} habits for $uid');
      }

      // 2. Delete the user profile document
      await userRef.delete();
      LogHelper.shared.debugPrint('✅ Deleted user profile document for $uid');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error during Firestore data deletion for $uid: $e');
      // We still want to try deleting local data and the auth account
    }

    // 3. Clear local Hive data
    await HiveHelper.shared.clearAllLocalData();

    // 4. Delete the Firebase Auth user account
    await user.delete();
    LogHelper.shared.debugPrint('✅ Firebase Auth user deleted successfully for $uid');
  }

  bool get hasEmailPasswordProvider {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  bool get isSocialProvider {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com' || p.providerId == 'apple.com');
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
