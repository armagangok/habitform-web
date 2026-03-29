import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/flushbar_widget.dart';

class CopyHelper {
  const CopyHelper._();
  static const shared = CopyHelper._();

  Future<void> copyRCId(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      AppFlushbar.shared.warningFlushbar('Account ID is not available');
      return;
    }
    await Clipboard.setData(ClipboardData(text: uid));
    AppFlushbar.shared.successFlushbar('Account ID copied\nID: $uid');
  }
}
