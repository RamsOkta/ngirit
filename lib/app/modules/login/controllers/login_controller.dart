import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs; // Observasi untuk menampilkan loader ketika login

  // Fungsi untuk login
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan Password tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Jika login berhasil, arahkan ke halaman dashboard (misalnya)
      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', e.message ?? 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  // Membersihkan controller saat tidak lagi digunakan
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
