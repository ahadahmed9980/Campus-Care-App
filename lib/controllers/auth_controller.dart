import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import 'connectivity_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  AuthController(this._authService);

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;

  bool _checkOffline() {
    if (Get.isRegistered<ConnectivityController>()) {
      final conn = Get.find<ConnectivityController>();
      if (!conn.isConnected.value) {
        Get.snackbar(
          'No Internet Connection',
          'Your request cannot be processed right now. Please check your internet connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
        return true;
      }
    }
    return false;
  }

  Future<void> login({required String email, required String password}) async {
    if (_checkOffline()) return;
    try {
      isLoading.value = true;
      await _authService.login(email: email, password: password);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (_checkOffline()) return;
    try {
      isGoogleLoading.value = true;
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      Get.snackbar(
        'Google sign-in failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> registerStudent({
    required String fullName,
    required String studentId,
    required String department,
    required String semester,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (_checkOffline()) return;
    try {
      isLoading.value = true;
      await _authService.registerStudent(
        fullName: fullName,
        studentId: studentId,
        department: department,
        semester: semester,
        email: email,
        phone: phone,
        password: password,
      );
      Get.back();
      Get.snackbar(
        'Success',
        'Account registered successfully! Please login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF43A047),
      );
    } catch (e) {
      Get.snackbar(
        'Registration failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (_checkOffline()) return;
    try {
      isLoading.value = true;
      await _authService.sendPasswordReset(email);
    } catch (e) {
      Get.snackbar(
        'Reset failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_checkOffline()) return;
    try {
      isLoading.value = true;
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF43A047),
      );
    } catch (e) {
      Get.snackbar(
        'Password change failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Logout failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
