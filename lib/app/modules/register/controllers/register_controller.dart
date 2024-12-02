import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController extends GetxController {
  var username = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  var passwordVisible = false.obs;
  var confirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (password.value == confirmPassword.value) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );

        // Simpan data pengguna ke koleksi 'users'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': username.value,
          'email': email.value,
        });

        // Simpan data akun default ke koleksi 'accounts' dengan user_id
        await FirebaseFirestore.instance.collection('accounts').add({
          'nama_akun': 'DefaultAcc',
          'saldo_awal': '0 ',
          'icon': 'assets/icons/default_icon.png', // Simpan sebagai string
          'user_id': userCredential.user!.uid,
        });

        print("User and account registered successfully");
        Get.snackbar("Success", "Registered successfully");

        // Navigasi ke halaman login setelah registrasi berhasil
        Get.offNamed(
            '/login'); // Ganti '/login' sesuai dengan route halaman login Anda
      } on FirebaseAuthException catch (e) {
        print("Registration failed: ${e.message}");
        Get.snackbar("Error", e.message ?? "Registration failed");
      }
    } else {
      print("Passwords do not match");
      Get.snackbar("Error", "Passwords do not match");
    }
  }
}
