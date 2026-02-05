import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';

class RoleController extends GetxController {
  final Rx<UserRole> currentRole = UserRole.customer.obs;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  Future<void> setRole(UserRole role) async {
    currentRole.value = role;
    final String? uid = fa.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _usersRef.child(uid).update({
        'role': role == UserRole.rider ? 'driver' : 'customer',
        'updatedAt': ServerValue.timestamp,
      });
    }
  }

  bool get isRider => currentRole.value == UserRole.rider;
  bool get isCustomer => currentRole.value == UserRole.customer;

  Future<UserRole?> fetchRole() async {
    final String? uid = fa.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final DataSnapshot snap = await _usersRef.child(uid).child('role').get();
    final String? role = snap.value?.toString();
    if (role == null || role.isEmpty) return null;
    if (role == 'driver') {
      currentRole.value = UserRole.rider;
      return UserRole.rider;
    }
    currentRole.value = UserRole.customer;
    return UserRole.customer;
  }

  Future<void> ensureUserRecord() async {
    final fa.User? user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final DataSnapshot snap = await _usersRef.child(user.uid).get();
    if (snap.exists && snap.value is Map) return;
    await _usersRef.child(user.uid).set({
      'phone': user.phoneNumber,
      'role': null,
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<void> signOut() async {
    await fa.FirebaseAuth.instance.signOut();
    currentRole.value = UserRole.customer;
  }
}
