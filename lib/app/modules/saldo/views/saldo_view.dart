import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/saldo_controller.dart';

class SaldoView extends StatelessWidget {
  final SaldoController saldoController = Get.put(SaldoController());
  final TextEditingController saldoControllerText =
      TextEditingController(); // Controller untuk input saldo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2A61), // Warna latar belakang biru gelap
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Gradient Container menggantikan AppBar
                Container(
                  width: double.infinity,
                  height: 150, // Tinggi container untuk menutup area AppBar
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1B2247),
                        Color(0xFF4971BB),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Back
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Kembali ke halaman sebelumnya
                          },
                        ),
                        // Teks "Saldo Anda"
                        Text(
                          'Saldo Anda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Tombol tambah (+)
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            // Navigasi ke halaman tambah akun
                            Get.toNamed('/tambahakun');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30), // Ruang di bawah gradient

                // ListView.builder dalam Container untuk membatasi ukuran
                Container(
                  height: constraints.maxHeight -
                      180, // Mengurangi tinggi dari container atas
                  child: Obx(() => ListView.builder(
                        itemCount: saldoController.accounts.length,
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          var account = saldoController.accounts[index];

                          // Cek apakah path ikon merupakan URL atau path aset lokal
                          bool isNetworkImage =
                              account['icon'].startsWith('http');

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey[300],
                                        child: ClipOval(
                                          child: isNetworkImage
                                              ? Image.network(
                                                  account['icon'],
                                                  fit: BoxFit
                                                      .contain, // Menghindari zoom dan menjaga rasio gambar
                                                  width:
                                                      48, // Sama dengan 2 * radius
                                                  height:
                                                      48, // Sama dengan 2 * radius
                                                )
                                              : Image.asset(
                                                  account['icon'],
                                                  fit: BoxFit
                                                      .contain, // Menghindari zoom dan menjaga rasio gambar
                                                  width: 48,
                                                  height: 48,
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account[
                                                'nama_akun'], // Nama akun dari Firestore
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Saldo',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            'Rp. ${account['saldo_awal']}', // Menggunakan saldo sebagai String
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.grey),
                                        onPressed: () {
                                          // Tampilkan dialog untuk mengedit saldo
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              saldoControllerText.text =
                                                  account['saldo_awal'];
                                              return AlertDialog(
                                                title: Text('Edit Saldo'),
                                                content: TextField(
                                                  controller:
                                                      saldoControllerText,
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Masukkan Saldo'),
                                                  keyboardType: TextInputType
                                                      .number, // Mengizinkan input angka
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Tutup dialog
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Update'),
                                                    onPressed: () {
                                                      String newSaldo =
                                                          saldoControllerText
                                                              .text;
                                                      // Memperbarui saldo dengan ID akun yang sesuai
                                                      saldoController
                                                          .updateSaldo(
                                                              account['id'],
                                                              newSaldo);
                                                      Navigator.of(context)
                                                          .pop(); // Tutup dialog
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
