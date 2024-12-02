import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF31356E),
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
                  fit: BoxFit.cover,
                  width: 80, // Atur ukuran gambar
                  height: 80,
                ),
              ),
              Text(
                'Daftar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Buat Akun Untuk Melanjutkan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Nama Pengguna',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFeaebf0),
                  hintText: 'Masukan Nama pengguna Anda',
                  hintStyle: TextStyle(color: Color(0xFF8d90af)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                onChanged: (value) => controller.username.value = value,
              ),
              SizedBox(height: 10),
              Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFeaebf0),
                  hintText: 'Masukan Email Anda',
                  hintStyle: TextStyle(color: Color(0xFF8d90af)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                onChanged: (value) => controller.email.value = value,
              ),
              SizedBox(height: 10),
              Text(
                'Kata Sandi',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 5),
              Obx(() => TextField(
                    obscureText: !controller.passwordVisible.value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFeaebf0),
                      hintText: 'Masukan Kata Sandi Anda',
                      hintStyle: TextStyle(color: Color(0xFF8d90af)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      suffixIcon: IconButton(
                        icon: Icon(controller.passwordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    onChanged: (value) => controller.password.value = value,
                  )),
              SizedBox(height: 10),
              Text(
                'Konfirmasi Kata Sandi',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF31356E),
                ),
              ),
              SizedBox(height: 5),
              Obx(() => TextField(
                    obscureText: !controller.confirmPasswordVisible.value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFeaebf0),
                      hintText: 'Konfirmasi Kata Sandi Anda',
                      hintStyle: TextStyle(color: Color(0xFF8d90af)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      suffixIcon: IconButton(
                        icon: Icon(controller.confirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    onChanged: (value) =>
                        controller.confirmPassword.value = value,
                  )),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.register,
                  child: Text(
                    'Daftar',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
