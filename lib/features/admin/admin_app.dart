import 'package:ecommerce_app/features/admin/controllers/admin_auth_controller.dart';
import 'package:ecommerce_app/features/admin/screens/login/admin_login_screen.dart';
import 'package:ecommerce_app/features/admin/screens/shell/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminAuthController());

    return GetMaterialApp(
      title: 'E-Commerce Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const AdminGate(),
    );
  }
}

class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AdminAuthController>();

    return Obx(() {
      if (auth.isChecking.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (auth.currentUser.value == null) {
        return const AdminLoginScreen();
      }

      if (!auth.isAdminUser.value) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 12),
                const Text('Admin access denied'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: auth.signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        );
      }

      return const AdminShell();
    });
  }
}
