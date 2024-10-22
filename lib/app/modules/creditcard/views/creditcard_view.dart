import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/creditcard_controller.dart';

class CreditcardView extends GetView<CreditcardController> {
  const CreditcardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Gradient Container menggantikan AppBar
                Container(
                  width: double.infinity,
                  height: 150,
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
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          'Kartu Kredit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            Get.toNamed('/tambahcc');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() {
                    return ListView.builder(
                      itemCount: controller.creditCards.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final creditCard = controller.creditCards[index];

                        // Mengambil limitKredit sebagai angka
                        var limitKredit = creditCard['limitKredit'] != null
                            ? int.tryParse(
                                    creditCard['limitKredit'].toString()) ??
                                0
                            : 0;

                        return _buildCreditCardItem(
                          context,
                          creditCard['id'], // Ambil ID kartu dari data
                          creditCard['namaKartu'] ?? 'Nama Kartu',
                          creditCard['tanggalMulai'] ?? 'Tanggal Mulai',
                          NumberFormat.currency(
                            locale: 'id', // Menggunakan locale Indonesia
                            symbol: 'Rp ', // Simbol mata uang
                            decimalDigits: 0, // Tidak ada digit desimal
                          ).format(limitKredit), // Format limit kredit
                          'Rp. 0', // Ini bisa juga diformat jika perlu
                          creditCard['ikonKartu'] ??
                              'assets/icons/default_icon.png',
                          controller, // Kirimkan controller ke dalam _buildCreditCardItem
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

  //Widget untuk membuat item kartu kredit
  Widget _buildCreditCardItem(
    BuildContext context,
    String cardId,
    String bankName,
    String date,
    String currentBill,
    String remainingBill,
    String iconPath,
    CreditcardController controller,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(iconPath),
              radius: 25,
            ),
            title: Text(bankName),
            subtitle:
                Text('Tanggal Mulai: $date\nLimit Bulan Ini: $currentBill'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Untuk menyesuaikan ukuran Row
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditLimitDialog(
                        context, cardId, currentBill, controller);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, cardId, controller);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Fungsi untuk menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmationDialog(
      BuildContext context, String cardId, CreditcardController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus kartu kredit ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa menghapus
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                controller
                    .deleteCard(cardId); // Panggil fungsi delete di controller
                Navigator.of(context).pop(); // Tutup dialog setelah hapus
              },
              child: Text('Hapus'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

// Fungsi untuk menampilkan dialog edit limit
  void _showEditLimitDialog(BuildContext context, String cardId,
      String currentBill, CreditcardController controller) {
    // Ambil hanya angka dari currentBill
    String onlyNumbers = currentBill.replaceAll(
        RegExp(r'[^\d]'), ''); // Hapus semua karakter kecuali angka
    TextEditingController _limitController =
        TextEditingController(text: onlyNumbers);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Limit Bulan Ini'),
          content: TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Limit Bulan Ini',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa menyimpan
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lakukan penyimpanan limit baru
                String newLimit = _limitController.text;

                // Update limit di controller dengan format yang benar (Rp.)
                String formattedLimit = '$newLimit';
                controller.updateLimit(cardId,
                    formattedLimit); // Panggil fungsi update di controller

                Navigator.of(context).pop(); // Tutup dialog setelah penyimpanan
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
