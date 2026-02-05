import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';

class RoleController extends GetxController {
  final Rx<UserRole> currentRole = UserRole.customer.obs;

  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  bool get isRider => currentRole.value == UserRole.rider;
  bool get isCustomer => currentRole.value == UserRole.customer;

  /// -------------------------------
  /// Ensure user record exists
  /// -------------------------------
  Future<void> ensureUserRecord() async {
    final fa.User? user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DatabaseReference userRef = _usersRef.child(user.uid);
    final DataSnapshot snap = await userRef.get();

    debugPrint('--------------------------------');
    debugPrint('ensureUserRecord RAW VALUE: ${snap.value}');
    debugPrint('ensureUserRecord TYPE: ${snap.value.runtimeType}');
    debugPrint('--------------------------------');

    // If node missing OR corrupted (String / int / etc)
    if (!snap.exists || snap.value == null || snap.value is! Map) {
      debugPrint('ensureUserRecord: FIXING USER NODE');

      await userRef.set({
        'phone': user.phoneNumber,
        'role': null,
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  /// -------------------------------
  /// Fetch role safely
  /// -------------------------------
  Future<UserRole?> fetchRole() async {
    final String? uid = fa.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final DataSnapshot snap = await _usersRef.child(uid).get();

    debugPrint('--------------------------------');
    debugPrint('fetchRole RAW VALUE: ${snap.value}');
    debugPrint('fetchRole TYPE: ${snap.value.runtimeType}');
    debugPrint('--------------------------------');

    if (!snap.exists || snap.value == null) {
      debugPrint('fetchRole: SNAP DOES NOT EXIST');
      return null;
    }

    // 🔥 THIS IS THE KEY FIX
    if (snap.value is String) {
      debugPrint('fetchRole: VALUE IS STRING → RESETTING NODE');
      await _usersRef.child(uid).set({
        'phone': fa.FirebaseAuth.instance.currentUser?.phoneNumber,
        'role': "user",
        'createdAt': ServerValue.timestamp,
      });
      return null;
    }

    if (snap.value is! Map) {
      debugPrint('fetchRole: VALUE IS NOT MAP');
      return null;
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      snap.value as Map,
    );

    debugPrint('fetchRole PARSED MAP: $data');

    final String? role = data['role']?.toString();

    if (role == null || role.isEmpty) {
      debugPrint('fetchRole: ROLE IS NULL');
      return null;
    }

    if (role == 'driver') {
      currentRole.value = UserRole.rider;
      return UserRole.rider;
    }

    currentRole.value = UserRole.customer;
    return UserRole.customer;
  }

  /// -------------------------------
  /// Set role
  /// -------------------------------
  Future<void> setRole(UserRole role) async {
    final String? uid = fa.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    currentRole.value = role;

    await _usersRef.child(uid).update({
      'role': role == UserRole.rider ? 'driver' : 'customer',
      'updatedAt': ServerValue.timestamp,
    });

    debugPrint('setRole: ${role.name}');
  }

  /// -------------------------------
  /// Sign out
  /// -------------------------------
  Future<void> signOut() async {
    await fa.FirebaseAuth.instance.signOut();
    currentRole.value = UserRole.customer;
  }
}
