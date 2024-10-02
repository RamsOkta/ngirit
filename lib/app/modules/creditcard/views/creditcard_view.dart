import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/creditcard_controller.dart';

class CreditcardView extends GetView<CreditcardController> {
  const CreditcardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 255, 255, 255), // Warna latar belakang biru gelap
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
                        // Teks "Kartu Kredit"
                        Text(
                          'Kartu Kredit',
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
                            Get.toNamed('/tambahcc');
                          },
                        ),
                      ],
                    ),
                  ),
                ), // Spasi di bawah gradient container
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() {
                    return ListView.builder(
                      itemCount: controller.creditCards.length,
                      shrinkWrap:
                          true, // Agar ListView tidak memakan seluruh ruang
                      physics:
                          NeverScrollableScrollPhysics(), // Matikan scroll ListView
                      itemBuilder: (context, index) {
                        final creditCard = controller.creditCards[index];
                        return _buildCreditCardItem(
                          creditCard['namaKartu'] ?? 'Nama Kartu',
                          creditCard['tanggalMulai'] ?? 'Tanggal Mulai',
                          'Rp. ${creditCard['limitKredit'] ?? '0'},00',
                          'Rp. 0,00', // Ganti dengan logika untuk sisa tagihan jika perlu
                          creditCard['ikonKartu'] ??
                              'assets/icons/default_icon.png', // Ganti dengan ikon default jika tidak ada
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget untuk membuat item kartu kredit
  Widget _buildCreditCardItem(String bankName, String date, String currentBill,
      String remainingBill, String iconPath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(iconPath), // Gunakan path ikon dari data
          radius: 25,
        ),
        title: Text(bankName),
        subtitle: Text('Tanggal Mulai: $date\nTagihan bulan ini: $currentBill'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sisa Tagihan'),
            Text(
              remainingBill,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
