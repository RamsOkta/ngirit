import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 256,
            decoration: BoxDecoration(
              color: Color(0xFF16193B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.white),
                        onPressed: () {
                          // Aksi tombol profile
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Obx(() {
                            return Text(
                              controller.username.value,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          // Aksi tombol notifikasi
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(height: 120),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kolom Saldo dengan Gradien
                      Container(
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF35478C),
                              Color(
                                  0xFFFFFFFF), // Menggunakan warna putih di akhir
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Saldo Anda',
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: Obx(() {
                                return IconButton(
                                  icon: Icon(controller.isSaldoVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: controller.toggleSaldoVisibility,
                                );
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Obx(() {
                                return Text(
                                  controller.isSaldoVisible.value
                                      ? 'Rp. ${controller.saldo.value}'
                                      : '******',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ),
                            Divider(),
                            Obx(() {
                              return Column(
                                children: controller.accounts.map((account) {
                                  String accountName =
                                      account['nama_akun']?.toString() ??
                                          'Unknown'; // Nama akun
                                  String amountString =
                                      account['saldo_awal']?.toString() ??
                                          '0'; // Saldo akun
                                  Color amountColor;

                                  // Memastikan saldo ditampilkan dengan benar dan warna sesuai
                                  try {
                                    int amount = int.parse(amountString);
                                    amountColor =
                                        amount >= 0 ? Colors.blue : Colors.red;
                                    amountString = 'Rp. $amountString';
                                  } catch (e) {
                                    amountColor = Colors.grey;
                                    amountString = 'Rp. 0';
                                  }

                                  String iconUrl =
                                      account['icon']?.toString() ??
                                          ''; // URL ikon

                                  // Membuat tile untuk setiap akun
                                  return _buildAccountTile(
                                    accountName,
                                    amountString,
                                    amountColor,
                                    iconUrl,
                                  );
                                }).toList(),
                              );
                            }),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: controller.manageAccounts,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Kelola Akun',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),

                      // Tambahkan kolom untuk Kartu Kredit dengan Gradien
                      Container(
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF35478C),
                              Color(0xFFFFFFFF), // Gradient dari biru ke putih
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bagian "Kartu Saya"
                              SizedBox(height: 8),
                              Text(
                                'Kartu Saya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Daftar kartu kredit yang diambil dari controller secara dinamis
                              Obx(() {
                                if (controller.creditCards.isEmpty) {
                                  return Text(
                                    'Belum ada kartu kredit terdaftar',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }

                                return Column(
                                  children: controller.creditCards.map((card) {
                                    String cardName =
                                        card['namaKartu'] ?? 'Unknown';
                                    String cardIcon = card['ikonKartu'] ??
                                        'assets/default_icon.png'; // ikonKartu dari Firebase atau lokal
                                    String limitKredit =
                                        card['limitKredit'] ?? '0';

                                    // Memeriksa apakah ikon berasal dari path lokal atau URL Firebase
                                    bool isLocalAsset =
                                        cardIcon.startsWith("assets/");

                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Icon kartu
                                            CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 30,
                                              child: isLocalAsset
                                                  ? Image.asset(
                                                      cardIcon,
                                                      width: 30,
                                                      height: 30,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        // Jika ada error, tampilkan ikon default
                                                        return Image.asset(
                                                          'assets/icons/default_icon.png',
                                                          width: 30,
                                                          height: 30,
                                                        );
                                                      },
                                                    )
                                                  : Image.network(
                                                      cardIcon,
                                                      width: 30,
                                                      height: 30,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        // Jika URL tidak valid, tampilkan ikon default
                                                        return Image.asset(
                                                          'assets/icons/default_icon.png',
                                                          width: 30,
                                                          height: 30,
                                                        );
                                                      },
                                                    ),
                                            ),
                                            SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cardName,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),

                                        // Informasi limit kredit
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 247, 245, 245),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tersedia',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Rp $limitKredit',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Faktur Saat Ini',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    '-Rp 5.000,00',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                      ],
                                    );
                                  }).toList(),
                                );
                              }),

                              // Tombol "Kelola Kartu"
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed('/creditcard');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 48, vertical: 16),
                                  ),
                                  child: Text(
                                    'Kelola Kartu',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Transfer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                label: 'Invoices',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: controller.selectedIndex.value,
            onTap: (index) {
              controller.selectedIndex.value = index;
              // Navigasi ke halaman yang sesuai berdasarkan index
              switch (index) {
                case 0:
                  Get.toNamed('/dashboard');
                  break;
                case 1:
                  Get.toNamed('/transfer');
                  break;
                case 2:
                  Get.toNamed('/invoices');
                  break;
                case 3:
                  Get.toNamed('/profile');
                  break;
              }
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/tambahcc');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAccountTile(String accountName, String amountString,
      Color amountColor, String iconPath) {
    // Periksa jika iconPath mengandung path lokal (contoh: "assets/icons/bni.jpg")
    bool isLocalAsset = iconPath.startsWith("assets/");

    return ListTile(
      leading: isLocalAsset
          ? Image.asset(
              iconPath, // Gunakan Image.asset untuk ikon lokal
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                // Jika ada error, tampilkan ikon default
                return Image.asset('assets/icons/default_icon.png',
                    width: 40, height: 40);
              },
            )
          : Image.network(
              iconPath, // Jika path bukan lokal, gunakan Image.network
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                // Jika URL tidak valid, tampilkan ikon default
                return Image.asset('assets/icons/default_icon.png',
                    width: 40, height: 40);
              },
            ),
      title: Text(accountName),
      subtitle: Text(amountString, style: TextStyle(color: amountColor)),
    );
  }
}
