import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/masuk_controller.dart';

class MasukView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar di tengah
              Container(
                height: 200, // Atur tinggi gambar
                width: 400, // Atur lebar gambar
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/logo.png'), // Ganti dengan path gambar Anda
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nama aplikasi
              Row(
                children: [
                  // Widget gambar
                  Image.asset(
                    'assets/images/ngirit.png', // Ganti dengan path gambar Anda
                    fit: BoxFit.contain, // Atur lebar gambar sesuai kebutuhan
                  ),
                  const SizedBox(width: 10), // Jarak antara gambar dan teks
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ngirit',
                      style: TextStyle(
                        fontFamily: 'Lilita One',
                        fontSize: 32, // Atur ukuran font
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF31356E),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selamat Datang di Perjalanan Menabung Anda',
                  style: TextStyle(
                    fontFamily: 'Lilita One',
                    fontSize: 32,
                    color: Color(0xFF31356E),
                  ),
                ),
              ), // Sub judul
              const SizedBox(height: 10),

              // Teks placeholder
              Text(
                'Kelola Uang Anda Lebih Mudah.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // Tombol login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman login
                    Get.toNamed('/login');
                  },
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter', // Menggunakan font Inter
                      color: Colors.white,
                      fontWeight: FontWeight.bold, // Atur warna teks
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        Color(0xFF31356E), // Atur warna background tombol
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol register
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi ke halaman register
                    Get.toNamed('/register');
                  },
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter', // Menggunakan font Inter
                      color:
                          Color(0xFF31356E), // Warna teks sesuai warna border
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        Colors.transparent, // Warna background transparan
                    side: BorderSide(
                      color: Color(0xFF31356E), // Warna border
                      width: 2, // Ketebalan border
                    ),
                    elevation: 0, // Menghilangkan efek bayangan
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
