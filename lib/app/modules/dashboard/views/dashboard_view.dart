import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

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
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.black,
        onPressed: () {
          _showModalBottomSheet(
              context); // Panggil fungsi untuk menampilkan bottom sheet
        },
        child: Icon(Icons.add, color: Colors.white, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, size: 30),
                onPressed: () {
                  Get.toNamed('/dashboard');
                },
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz, size: 30),
                onPressed: () {
                  Get.toNamed('/cashflow');
                },
              ),
              SizedBox(width: 48), // Space for FloatingActionButton
              IconButton(
                icon: Icon(Icons.bar_chart, size: 30),
                onPressed: () {
                  Get.toNamed('/statistic');
                },
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.bullseye, size: 30),
                onPressed: () {
                  Get.toNamed('/bataspengeluaran');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Mengatur tinggi BottomSheet
          widthFactor: 0.9, // Mengatur lebar BottomSheet
          child: Stack(
            children: [
              // Bagian atas dengan warna sesuai tab yang diklik
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 160, // Tinggi background termasuk tab
                child: Obx(() {
                  Color backgroundColor;
                  switch (controller.selectedTab.value) {
                    case 0:
                      backgroundColor =
                          Colors.red; // Warna merah untuk Pengeluaran
                      break;
                    case 1:
                      backgroundColor =
                          Colors.green; // Warna hijau untuk Pendapatan
                      break;
                    case 2:
                      backgroundColor =
                          Colors.blue; // Warna biru untuk Transfer
                      break;
                    default:
                      backgroundColor = Colors.red;
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.0)),
                    ),
                    child: Column(
                      children: [
                        // Tab items di bagian atas
                        Row(
                          children: [
                            _buildTabItem('Pengeluaran', Colors.red, 0),
                            _buildTabItem('Pendapatan', Colors.green, 1),
                            _buildTabItem('Transfer', Colors.blue, 2),
                          ],
                        ),
                        // Input angka "0,00" di dalam background color
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Spacer(), // Menggeser input ke kanan
                              Expanded(
                                child: TextField(
                                  controller:
                                      nominalController, // Menggunakan controller
                                  keyboardType: TextInputType.number,
                                  textAlign:
                                      TextAlign.right, // Teks sejajar kanan
                                  decoration: InputDecoration(
                                    hintText: '0,00',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 40,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
// Hilangkan koma yang tidak perlu di sini
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              // Konten BottomSheet
              Positioned.fill(
                top:
                    160, // Konten dimulai setelah header background dan input angka
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna latar belakang form
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Form Input berdasarkan tab yang dipilih
                        Obx(() {
                          switch (controller.selectedTab.value) {
                            case 0:
                              return _buildPengeluaranForm(context);
                            case 1:
                              return _buildPendapatanForm();
                            case 2:
                              return _buildTransferForm();
                            default:
                              return _buildPengeluaranForm(context);
                          }
                        }),
                        SizedBox(height: 20),
                        // Tombol Save di bagian bawah BottomSheet
                        // Tombol Save di bagian bawah BottomSheet
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () {
                              // Ambil nilai nominal dari nominalController sebagai String
                              String nominal = nominalController.text;

                              // Panggil fungsi untuk menyimpan data ke Firebase
                              controller.saveFormData(
                                  nominal); // Panggil saveFormData() dari controller
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.blue, // Warna tombol
                            ),
                            child: Text(
                              'Save',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Fungsi untuk membuat text field di dalam bottom sheet
  // Fungsi untuk membuat TabItem di dalam bottom sheet
  Widget _buildTabItem(String title, Color color, int index) {
    return Expanded(
      child: Obx(() {
        bool isSelected = controller.selectedTab.value == index;
        return GestureDetector(
          onTap: () {
            controller.selectedTab.value = index;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? color.withOpacity(0.8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white, // Selalu putih untuk teks
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Garis putih di bawah teks untuk tab yang dipilih
              if (isSelected)
                Container(
                  height: 3, // Ketebalan garis
                  width: 40, // Lebar garis
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna garis putih
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPengeluaranForm(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Supaya label di atas text field
      children: [
        // TextField untuk Deskripsi
        Text(
          'Deskripsi', // Label di atas input field
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              TextField(
                controller: deskripsiController, // Menggunakan controller
                decoration: InputDecoration(
                  hintText: 'Masukkan Deskripsi', // Placeholder
                  prefixIcon: Icon(Icons.edit), // Ikon di dalam field
                  border: OutlineInputBorder(
                    // Ganti menjadi OutlineInputBorder untuk border yang lebih baik
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10), // Padding agar rapi
                ),
                onChanged: (value) {
                  print(
                      'Deskripsi yang dimasukkan: $value'); // Debugging untuk melihat input
                },
              ),
              Divider(
                thickness: 1, // Tebal garis bawah
                color: Colors.grey, // Warna garis bawah
              ),
            ],
          ),
        ),

        // TextField untuk Kategori
        Text(
          'Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            _showKategoriBottomSheet(context); // Gunakan context di sini
          },
          child: AbsorbPointer(
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: controller.selectedKategori.value.isNotEmpty
                            ? controller.selectedKategori.value
                            : 'Pilih Kategori', // Placeholder
                        border: InputBorder.none, // Hilangkan outline border
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10), // Padding agar rapi
                      ),
                    ),
                    Divider(
                      thickness: 1, // Tebal garis bawah
                      color: Colors.grey, // Warna garis bawah
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // TextField untuk Akun
        Text(
          'Dibayar dengan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            _showAkunBottomSheet(context); // Gunakan context di sini
          },
          child: AbsorbPointer(
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: controller.selectedAkun.value.isNotEmpty
                            ? controller.selectedAkun.value
                            : 'Pilih Akun', // Placeholder
                        border: InputBorder.none, // Hilangkan outline border
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10), // Padding agar rapi
                      ),
                    ),
                    Divider(
                      thickness: 1, // Tebal garis bawah
                      color: Colors.grey, // Warna garis bawah
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // TextField untuk Tanggal
        Text(
          'Tanggal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () async {
            // Tampilkan DatePicker saat pengguna mengetuk field tanggal
            DateTime? selectedDate = await showDatePicker(
              context: context, // Gunakan context di sini
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            // Jika pengguna memilih tanggal, simpan ke controller
            if (selectedDate != null) {
              controller.selectedDate.value =
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
            }
          },
          child: AbsorbPointer(
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: controller.selectedDate.value.isNotEmpty
                            ? controller.selectedDate.value
                            : 'Pilih Tanggal', // Placeholder
                        prefixIcon:
                            Icon(Icons.calendar_today), // Ikon di dalam field
                        border: InputBorder.none, // Hilangkan outline border
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10), // Padding agar rapi
                      ),
                    ),
                    Divider(
                      thickness: 1, // Tebal garis bawah
                      color: Colors.grey, // Warna garis bawah
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPendapatanForm() {
    return Column(
      children: [
        _buildTextField('Deskripsi', Icons.edit),
        _buildTextField('Kategori', Icons.list),
        _buildTextField('Dibayar dengan', Icons.wallet_giftcard),
        _buildTextField('Tanggal', Icons.calendar_today),
      ],
    );
  }

  Widget _buildTransferForm() {
    return Column(
      children: [
        _buildTextField('Deskripsi', Icons.edit),
        _buildTextField('Kategori', Icons.list),
        _buildTextField('Dibayar dengan', Icons.wallet_giftcard),
        _buildTextField('Tanggal', Icons.calendar_today),
      ],
    );
  }

// Fungsi untuk membuat text field di dalam bottom sheet

  Widget _buildTextField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label untuk field input
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          // TextField tanpa border dengan logo di dalam
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey),
              hintText: 'Masukkan $label',
              border: InputBorder.none, // Hilangkan outline/border
              contentPadding: EdgeInsets.symmetric(
                  vertical: 10), // Padding agar terlihat lebih rapi
            ),
          ),

          Divider(
            thickness: 1, // Tebal garis
            color: Colors.grey, // Warna garis pembatas
          ),
        ],
      ),
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

  void _showAkunBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> akunList = [
      {'nama_akun': 'BNI', 'icon': 'assets/icons/bni.jpg'},

      // Akun lainnya...
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 300,
          child: Obx(() {
            if (controller.accounts.isEmpty) {
              return Center(
                child: Text('Tidak ada akun tersedia'),
              );
            } else {
              return ListView.builder(
                itemCount: controller.accounts.length,
                itemBuilder: (context, index) {
                  var akun = controller.accounts[index];

                  return ListTile(
                    leading: Icon(
                        Icons.account_balance_wallet), // Ikon bisa disesuaikan

                    title: Text(akun['nama_akun']),

                    subtitle: Text('Saldo: ${akun['saldo_awal']}'),

                    onTap: () {
                      // Update selected akun

                      controller.selectedAkun.value = akun['nama_akun'];

                      Navigator.pop(context); // Tutup bottom sheet
                    },
                  );
                },
              );
            }
          }),
        );
      },
    );
  }

  // Fungsi buttomsheet kategori

  void _showKategoriBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> kategoriList = [
      {'labels': 'Makanan', 'icon': 'assets/icons/food.png'},
      {'labels': 'Transportasi', 'icon': 'assets/icons/car.png'},
      {'labels': 'Belanja', 'icon': 'assets/icons/shop.png'},
      {'labels': 'Hiburan', 'icon': 'assets/icons/cinema.png'},
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: kategoriList.map((kategori) {
                  return GestureDetector(
                    onTap: () {
                      // Simpan kategori yang dipilih di controller
                      controller.selectedKategori.value = kategori['labels'];
                      Navigator.pop(context); // Tutup bottom sheet
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30, // Ukuran icon
                          backgroundColor: Colors.grey[200],
                          child: Image.asset(
                            kategori['icon'], // Menampilkan gambar dari assets
                            width: 28, // Ukuran gambar
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          kategori['labels'], // Menggunakan 'labels' yang benar
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
