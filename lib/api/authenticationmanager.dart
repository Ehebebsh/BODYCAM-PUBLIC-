import 'dart:async';
import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

bool _lastLoginUpdated = false;

class UserAuthManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AndroidId _androidIdPlugin = AndroidId();
  late String _androidId;

  Future<void> init() async {
    await _initAndroidId();
    await _signInWithGoogleAndUpdateLastLoginIfNeeded();
  }

  Future<void> _initAndroidId() async {
    try {
      _androidId = await _androidIdPlugin.getId() ?? 'Unknown ID';
    } on PlatformException {
      _androidId = 'Failed to get Android ID.';
    }
  }

  Future<void> _signInWithGoogleAndUpdateLastLoginIfNeeded() async {
    if (_lastLoginUpdated) return;

    try {
      if (await _googleSignIn.isSignedIn()) {
        GoogleSignInAccount? user = _googleSignIn.currentUser;
        if (user != null) {
          await _updateLastLogin(user.id, 'realusers');
          _lastLoginUpdated = true;
        }
        await _signInWithGoogle();
      } else {
        User? user = _auth.currentUser;
        if (user != null) {
          await _updateLastLogin(_androidId, 'realusers');
          _lastLoginUpdated = true;
        }
        await _signInAnonymouslyIfNeeded();
      }
    } catch (e) {
    }
  }

  Future<void> _updateLastLogin(String id, String collection) async {
    String currentTimeISO = DateTime.now().toUtc().toIso8601String();
    String collectionPath = collection;
    String documentPath = id;

    try {
      await _firestore.collection(collectionPath).doc(documentPath).update({
        'lastLogin': currentTimeISO,
      });
    } catch (e) {
    }
  }

  Future<void> _signInWithGoogle() async {
    GoogleSignInAccount? user = await _googleSignIn.signIn();

    if (user != null) {
      GoogleSignInAuthentication googleAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await _updateLastLogin(_androidId, 'realusers');
        _lastLoginUpdated = true;
      }
    }
  }

  Future<void> _signInAnonymouslyIfNeeded() async {
    if (_auth.currentUser == null) {
      UserCredential userCredential = await _auth.signInAnonymously();
      String uid = userCredential.user?.uid ?? "N/A";

      try {
        await _saveUserDataToFirestore(_androidId);
      } catch (e) {
      }
    } else {
      String uid = _auth.currentUser!.uid;

      try {
        await _updateLastLogin(_androidId, 'users');
        _lastLoginUpdated = true;
      } catch (e) {
      }
    }
  }

  Future<void> _saveUserDataToFirestore(String? id) async {
    if (id != null) {
      String currentTimeISO = DateTime.now().toUtc().toIso8601String();
      String collectionPath = 'users';
      String documentPath = id;
      String uid = _auth.currentUser!.uid;

      await _firestore.collection(collectionPath).doc(documentPath).set({
        'id': id,
        'uid': uid,
        'firstLogin': currentTimeISO,
        'lastLogin': currentTimeISO,
      });
    }
  }
}
