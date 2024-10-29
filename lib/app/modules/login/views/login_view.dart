import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart'; // Add this import
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  final RxBool _obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Kembali ke halaman sebelumnya
          },
        ),
        backgroundColor: Colors.transparent, // Buat AppBar transparan
        elevation: 0, // Hilangkan shadow AppBar
        foregroundColor: Color(0xFF31356E), // Atur warna ikon dan teks AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/login.png', // Ganti dengan path gambar Anda
                  fit: BoxFit.cover, // Atur ukuran gambar
                ),
              ),
              Text(
                'Masuk',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF31356E),
                ),
              ),
              Text(
                'Masuk Untuk Menggunakan Aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFeaebf0),
                    hintText: 'Masukan email Anda',
                    hintStyle: TextStyle(
                      color: Color(0xFF8d90af),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Password',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Obx(() => TextField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFeaebf0),
                        hintText: 'Masukan password Anda',
                        hintStyle: TextStyle(
                          color: Color(0xFF8d90af),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            _obscurePassword.value = !_obscurePassword.value;
                          },
                        ),
                      ),
                      obscureText: _obscurePassword.value,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
              ),
              SizedBox(height: 20),
              Obx(() => controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.login,
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF31356E),
                        ),
                      ),
                    )),
              SizedBox(height: 20),

              SizedBox(height: 5), // Jarak setelah opsi login

              // Teks untuk registrasi
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    children: [
                      TextSpan(text: "Tidak Memiliki Akun? "),
                      TextSpan(
                        text: "Registrasi",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(
                                '/register'); // Ganti dengan route yang sesuai
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20), // Jarak setelah teks registrasi
            ],
          ),
        ),
      ),
    );
  }
}
