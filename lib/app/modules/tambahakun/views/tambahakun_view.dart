import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tambahakun_controller.dart';

class TambahakunView extends StatelessWidget {
  final TambahakunController controller = Get.put(TambahakunController());

  @override
  Widget build(BuildContext context) {
    final account = Get.arguments;

    // Mengisi data jika ada
    if (account != null) {
      controller.namaAkun.value = account['nama_akun'] ?? '';
      controller.saldoAkun.value = account['saldo_awal']?.toString() ??
          ''; // Pastikan saldo diisi sebagai string
      controller.selectedIcon.value =
          controller.icons[controller.iconLabels.indexOf(account['icon'])];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Gradient Container menggantikan AppBar
                    Container(
                      width: double.infinity,
                      height: 150, // Tinggi container untuk menutup area AppBar
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1B2247), // Midnight Blue
                            Color(0xFF4971BB), // Steel Blue
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Padding untuk status bar
                          SizedBox(height: 50),

                          // Teks judul di tengah
                          Center(
                            child: Text(
                              'Tambah Akun',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30), // Ruang di bawah gradient

                    // Container untuk form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input Nama Akun
                          Text(
                            'Nama Akun',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            onChanged: (value) {
                              controller.namaAkun.value = value;
                            },
                            controller: TextEditingController(
                                text: controller.namaAkun.value),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 20),

                          // Pilih Icon Akun
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pilih Icon Akun:',
                                style: TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(Icons.account_balance_wallet),
                                onPressed: () {
                                  // Menampilkan bottom sheet untuk memilih icon
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.7, // Atur tinggi modal
                                        child: Column(
                                          children: [
                                            // TextField untuk pencarian
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextField(
                                                onChanged: (value) {
                                                  controller.searchIcon(value);
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'Cari Icon',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[200],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Obx(() {
                                                return ListView.builder(
                                                  itemCount: controller
                                                      .filteredIcons.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      leading: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                controller
                                                                        .filteredIcons[
                                                                    index]),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      title: Text(controller
                                                              .iconLabels[
                                                          controller.icons
                                                              .indexOf(controller
                                                                      .filteredIcons[
                                                                  index])]),
                                                      onTap: () {
                                                        controller.selectedIcon
                                                            .value = controller
                                                                .filteredIcons[
                                                            index];
                                                        Get.back(); // Tutup bottom sheet
                                                      },
                                                    );
                                                  },
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          // Menampilkan icon yang dipilih
                          Obx(() {
                            return controller.selectedIcon.value != null
                                ? Image.asset(controller.selectedIcon.value!,
                                    height: 40) // Menampilkan icon yang dipilih
                                : Container();
                          }),
                          SizedBox(height: 20),

                          // Input Saldo Awal Akun
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              controller.saldoAkun.value =
                                  value; // Simpan sebagai string
                            },
                            controller: TextEditingController(
                                text: controller.saldoAkun.value),
                            decoration: InputDecoration(
                              labelText: 'Saldo Akun',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 40),

                          // Button Buat Akun
                          ElevatedButton(
                            onPressed: () {
                              controller.tambahAkun();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF4971BB), // Warna tombol
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Buat Akun',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
