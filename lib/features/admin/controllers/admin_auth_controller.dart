import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AdminAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isChecking = true.obs;
  final RxBool isAdminUser = false.obs;
  final RxBool isSigningIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) async {
      currentUser.value = user;
      await _resolveRole(user);
    });
  }

  Future<void> _resolveRole(User? user) async {
    try {
      isChecking.value = true;
      if (user == null) {
        isAdminUser.value = false;
        return;
      }

      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims ?? <String, dynamic>{};
      final isClaimAdmin = claims['admin'] == true;

      final doc = await _db.collection('users').doc(user.uid).get();
      final role = (doc.data()?['role'] ?? '').toString().toLowerCase();
      final isRoleAdmin = role == 'admin' || role == 'super_admin';

      isAdminUser.value = isClaimAdmin || isRoleAdmin;
    } catch (_) {
      isAdminUser.value = false;
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isSigningIn.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Unable to sign in';
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
