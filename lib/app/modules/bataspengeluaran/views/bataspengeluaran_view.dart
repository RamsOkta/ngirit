import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ngirit/app/modules/cashflow/views/cashflow_view.dart';
import '../controllers/bataspengeluaran_controller.dart';

class BataspengeluaranView extends GetView<BataspengeluaranController> {
  final BataspengeluaranController controller =
      Get.put(BataspengeluaranController());

  final TextEditingController nominalController = TextEditingController();
  final FocusNode deskripsiFocusNode = FocusNode();

  final FocusNode kategoriFocusNode = FocusNode();

  final FocusNode akunFocusNode = FocusNode();

  final FocusNode tanggalFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900, // Light blue
                  Colors.white, // Dark blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Upper curve design
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Color(0xFF1E2147),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
          ),
          // Positioned Arus Kas text or search field
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Batas Pengeluaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          // Plus button (overflow menu) positioned at the top-right corner
          Positioned(
            top: 30,
            right: 12,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white), // Plus icon
              onPressed: () async {
                // Panggil fungsi untuk mendapatkan kategori yang sudah ada
                List<String> existingCategories =
                    await controller.getExistingCategories();

                // Tampilkan modal dengan kategori yang belum dipilih
                showCategorySelection(context, existingCategories);
              },
            ),
          ),

          // Main content with padding to move it down
// Main content with padding to move it down
          Padding(
            padding: const EdgeInsets.only(top: 100.0), // Adjusted top padding
            child: Column(
              children: [
                SizedBox(height: 20), // Space before month section
                // Month section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Larger padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Month Button
                      IconButton(
                        icon: Icon(Icons.arrow_left),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: () {
                          controller.changeMonth(-1);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      // Previous Month Container
                      Expanded(
                        child: Obx(() =>
                            buildMonthContainer(controller.previousMonth)),
                      ),
                      SizedBox(width: 3),
                      // Selected Month Container
                      Expanded(
                        child: Obx(() => buildMonthContainer(
                            controller.selectedMonth, true)),
                      ),
                      SizedBox(width: 3),
                      // Next Month Container
                      Expanded(
                        child: Obx(
                            () => buildMonthContainer(controller.nextMonth)),
                      ),
                      // Next Month Button
                      IconButton(
                        icon: Icon(Icons.arrow_right),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: () {
                          controller.changeMonth(1);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Expanded list for cash flow content
                Expanded(
                  child: Obx(() {
                    // Group transactions by date in the view
                    Map<String, List<Map<String, dynamic>>>
                        groupedTransactions = {};

                    // Group the transactions by 'date'
                    for (var transaction in controller.transactions) {
                      String date = transaction['date']!;

                      // Add a new key if date is not already in groupedTransactions
                      if (!groupedTransactions.containsKey(date)) {
                        groupedTransactions[date] = [];
                      }

                      // Add transaction to the group based on date
                      groupedTransactions[date]!.add(transaction);
                    }

                    // Check if there are no transactions for the selected month
                    if (groupedTransactions.isEmpty) {
                      return Center(
                        child: Text(
                          "Anda Belum Ada Batas Limit Pengeluaran",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // Display grouped transactions using ListView.builder
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          physics:
                              NeverScrollableScrollPhysics(), // Prevent scrolling of inner list
                          shrinkWrap: true,
                          itemCount: groupedTransactions.keys.length,
                          itemBuilder: (context, index) {
                            String date =
                                groupedTransactions.keys.elementAt(index);
                            List<Map<String, dynamic>> transactions =
                                groupedTransactions[date]!;

                            return buildTransactionGroup(
                                date, transactions, controller);
                          },
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(
                    height:
                        10), // Spacer between transactions and financial summary
              ],
            ),
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
                                  controller: controller.selectedTab.value == 0
                                      ? controller.pengeluaranController
                                      : controller
                                          .pendapatanController, // Controller per tab
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // Hanya menerima angka
                                    NumberInputFormatter(), // Formatter angka dengan pemisah ribuan
                                  ],
                                ),
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
                              return _buildPendapatanForm(context);
                            default:
                              return _buildPengeluaranForm(context);
                          }
                        }),
                        SizedBox(height: 20),
                        // Tombol Save di bagian bawah BottomSheet
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            onPressed: () {
                              // Ambil nilai nominal dari controller yang sesuai
                              String nominal = controller.selectedTab.value == 0
                                  ? controller.pengeluaranController.text
                                  : controller.pendapatanController.text;

                              // Panggil fungsi untuk menyimpan data ke Firebase
                              controller.saveFormData(nominal);

                              // Kosongkan form setelah data disimpan
                              controller
                                  .clearForm(controller.selectedTab.value);

                              // Tutup BottomSheet setelah menyimpan
                              Navigator.pop(context);
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
                              'Simpan',
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

  // Fungsi untuk membuat TabItem di dalam bottom sheet
  Widget _buildTabItem(String title, Color color, int index) {
    return Expanded(
      child: Obx(() {
        bool isSelected = controller.selectedTab.value == index;
        return GestureDetector(
          onTap: () {
            // Jika tab saat ini berbeda dari tab yang diklik, reset semua data form
            if (controller.selectedTab.value != index) {
              controller.resetFormData();
            }

            // Set selected tab dan kosongkan controller sesuai tab yang dipilih
            controller.selectedTab.value = index;

            if (index == 0) {
              controller.pengeluaranController
                  .clear(); // Bersihkan semua field di tab Pengeluaran
            } else if (index == 1) {
              controller.pendapatanController
                  .clear(); // Bersihkan semua field di tab Pendapatan
            }
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
                      color: Colors.white, // Teks selalu putih
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
    if (controller.selectedDates.value.isEmpty) {
      final today = DateTime.now();
      controller.selectedDates.value =
          "${today.day}-${today.month}-${today.year}";
    }

    return GestureDetector(
      onTap: () {
        // Menutup keyboard saat mengetuk di luar TextField
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField untuk Deskripsi Pendapatan
            Text(
              'Deskripsi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                focusNode: deskripsiFocusNode,
                controller: controller.deskripsiController,
                onChanged: (value) {
                  controller.deskripsi.value = value;
                },
                decoration: InputDecoration(
                  labelText: 'Masukkan Deskripsi',
                  prefixIcon: Icon(Icons.edit),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),

            // Field untuk Kategori Pendapatan (tanpa keyboard)
            Text(
              'Kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(
                    FocusNode()); // Menghapus fokus dari TextField
                _showKategoriBottomSheet(context);
              },
              child: AbsorbPointer(
                child: Obx(() {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: kategoriFocusNode,
                          controller: TextEditingController(
                            text: controller.selectedKategori.value,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                controller.selectedKategori.value.isNotEmpty
                                    ? controller.selectedKategori.value
                                    : 'Pilih Kategori',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Field untuk Masuk Saldo Ke (tanpa keyboard)
            Text(
              'Gunakan Akun',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(
                    FocusNode()); // Menghapus fokus dari TextField
                _showAkunBottomSheet(context);
              },
              child: AbsorbPointer(
                child: Obx(() {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: akunFocusNode,
                          controller: TextEditingController(
                            text: controller.selectedAkun.value,
                          ),
                          decoration: InputDecoration(
                            hintText: controller.selectedAkun.value.isNotEmpty
                                ? controller.selectedAkun.value
                                : 'Pilih Akun',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Field untuk Tanggal Pendapatan (tanpa keyboard)
            Text(
              'Tanggal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).requestFocus(
                    FocusNode()); // Menghapus fokus dari TextField
                DateTime? selectedDates = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDates != null) {
                  controller.selectedDates.value =
                      "${selectedDates.day}-${selectedDates.month}-${selectedDates.year}";
                }
              },
              child: AbsorbPointer(
                child: Obx(() {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: tanggalFocusNode,
                          controller: TextEditingController(
                            text: controller.selectedDates.value,
                          ),
                          decoration: InputDecoration(
                            hintText: controller.selectedDates.value.isNotEmpty
                                ? controller.selectedDates.value
                                : 'Pilih Tanggal',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendapatanForm(BuildContext context) {
    // Initialize the date with the current date if it's not already set
    if (controller.selectedDates.value.isEmpty) {
      final today = DateTime.now();
      controller.selectedDates.value =
          "${today.day}-${today.month}-${today.year}";
    }

    return GestureDetector(
      onTap: () {
        // Menutup keyboard saat mengetuk di luar TextField
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField untuk Deskripsi Pendapatan
            Text(
              'Deskripsi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                focusNode: deskripsiFocusNode,
                controller: controller.deskripsiController,
                onChanged: (value) {
                  controller.deskripsi.value = value;
                },
                decoration: InputDecoration(
                  labelText: 'Masukkan Deskripsi',
                  prefixIcon: Icon(Icons.edit),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),

            // Field untuk Kategori Pendapatan (tanpa keyboard)
            Text(
              'Kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(
                    FocusNode()); // Menghapus fokus dari TextField
                _showKategoriPendapatanBottomSheet(context);
              },
              child: AbsorbPointer(
                child: Obx(() {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: kategoriFocusNode,
                          controller: TextEditingController(
                            text: controller.selectedKategori.value,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                controller.selectedKategori.value.isNotEmpty
                                    ? controller.selectedKategori.value
                                    : 'Pilih Kategori',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Field untuk Masuk Saldo Ke (tanpa keyboard)
            Text(
              'Masuk Saldo Ke',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(
                    FocusNode()); // Menghapus fokus dari TextField
                _showAkunBottomSheet(context);
              },
              child: AbsorbPointer(
                child: Obx(() {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: akunFocusNode,
                          controller: TextEditingController(
                            text: controller.selectedAkun.value,
                          ),
                          decoration: InputDecoration(
                            hintText: controller.selectedAkun.value.isNotEmpty
                                ? controller.selectedAkun.value
                                : 'Pilih Akun',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Field untuk Tanggal Pendapatan (tanpa keyboard)
            Text(
              'Tanggal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).requestFocus(
                    FocusNode()); // Menghapus fokus dari TextField
                DateTime? selectedDates = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDates != null) {
                  controller.selectedDates.value =
                      "${selectedDates.day}-${selectedDates.month}-${selectedDates.year}";
                }
              },
              child: AbsorbPointer(
                child: Obx(() {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: tanggalFocusNode,
                          controller: TextEditingController(
                            text: controller.selectedDates.value,
                          ),
                          decoration: InputDecoration(
                            hintText: controller.selectedDates.value.isNotEmpty
                                ? controller.selectedDates.value
                                : 'Pilih Tanggal',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      {'nama_akun': 'BNI', 'icon': 'assets/icons/bni.jpg', 'isLocal': true},
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
            if (controller.accounts.isEmpty && controller.creditCards.isEmpty) {
              return Center(
                child: Text('Tidak ada akun atau kartu tersedia'),
              );
            } else {
              return ListView.builder(
                itemCount:
                    controller.accounts.length + controller.creditCards.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item;
                  bool isLocalAsset;

                  if (index < controller.accounts.length) {
                    item = controller.accounts[index];
                    isLocalAsset = item['isLocal'] ??
                        false; // Pastikan ada properti 'isLocal' pada setiap item

                    return ListTile(
                      leading: isLocalAsset
                          ? Image.asset(
                              item[
                                  'icon'], // Gunakan Image.asset untuk ikon lokal
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                // Jika ada error, tampilkan ikon default
                                return Image.asset(
                                  'assets/icons/default_icon.png',
                                  width: 40,
                                  height: 40,
                                );
                              },
                            )
                          : Image.network(
                              item[
                                  'icon'], // Gunakan Image.network jika bukan lokal
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                // Jika URL tidak valid, tampilkan ikon default
                                return Image.asset(
                                  'assets/icons/default_icon.png',
                                  width: 40,
                                  height: 40,
                                );
                              },
                            ),
                      title: Text(item['nama_akun']),
                      onTap: () {
                        controller.selectedAkun.value = item['nama_akun'];
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    // Menampilkan data kartu kredit
                    item = controller
                        .creditCards[index - controller.accounts.length];
                    return ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text(item['namaKartu']),
                      subtitle: Text('Limit: ${item['limitKredit']}'),
                      onTap: () {
                        controller.selectedAkun.value = item['namaKartu'];
                        Navigator.pop(context);
                      },
                    );
                  }
                },
              );
            }
          }),
        );
      },
    );
  }

// Fungsi buttomsheet kategori pengeluaran

  void _showKategoriBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> kategoriList = [
      {'labels': 'Makan', 'icon': 'assets/icons/makanan.png'},
      {'labels': 'Transport', 'icon': 'assets/icons/cars.png'},
      {'labels': 'Belanja', 'icon': 'assets/icons/shop2.png'},
      {'labels': 'Hiburan', 'icon': 'assets/icons/hiburan.png'},
      {'labels': 'Pendidikan', 'icon': 'assets/icons/pendidikan.png'},
      {'labels': 'Rumah Tangga', 'icon': 'assets/icons/rt.png'},
      {'labels': 'Investasi', 'icon': 'assets/icons/investasi.png'},
      {'labels': 'Kesehatan', 'icon': 'assets/icons/kesehatan.png'},
      {'labels': 'Liburan', 'icon': 'assets/icons/liburan.png'},
      {'labels': 'Perbaikan Rumah', 'icon': 'assets/icons/rumah.png'},
      {'labels': 'Pakaian', 'icon': 'assets/icons/outfit.png'},
      {'labels': 'Internet', 'icon': 'assets/icons/internet.png'},
      {'labels': 'Olahraga & Gym', 'icon': 'assets/icons/gym.png'},
      {'labels': 'Lainnya', 'icon': 'assets/icons/lainnya.png'},
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height:
              MediaQuery.of(context).size.height * 0.6, // 60% of screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap:
                        true, // Prevents GridView from expanding infinitely
                    physics:
                        NeverScrollableScrollPhysics(), // Disable GridView scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Number of columns in grid
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio:
                          0.7, // Adjusted for better space for text
                    ),
                    itemCount: kategoriList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final kategori = kategoriList[index];
                      return GestureDetector(
                        onTap: () {
                          // Simpan kategori yang dipilih di controller
                          controller.selectedKategori.value =
                              kategori['labels'];
                          Navigator.pop(context); // Tutup bottom sheet
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30, // Ukuran icon
                              backgroundColor: Colors.grey[200],
                              child: Image.asset(
                                kategori[
                                    'icon'], // Menampilkan gambar dari assets
                                width: 28, // Ukuran gambar
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 70, // Batasan lebar teks
                              child: Text(
                                kategori[
                                    'labels'], // Menggunakan 'labels' yang benar
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center, // Rata tengah
                                softWrap: true, // Mengizinkan pembungkusan teks
                                overflow:
                                    TextOverflow.visible, // Tidak overflow
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Fungsi buttomsheet kategori penghasilan
  void _showKategoriPendapatanBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> kategoriPendapatanList = [
      {'label': 'Gaji', 'icon': 'assets/icons/gaji.png'},
      {'label': 'Investasi', 'icon': 'assets/icons/investasi.png'},
      {'label': 'Bonus', 'icon': 'assets/icons/hadiah.png'},
      {'label': 'Uang Saku', 'icon': 'assets/icons/uangsaku.png'},
      {'label': 'Lainnya', 'icon': 'assets/icons/lainnya.png'},
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height:
              MediaQuery.of(context).size.height * 0.6, // 60% of screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap:
                        true, // Prevents GridView from expanding infinitely
                    physics:
                        NeverScrollableScrollPhysics(), // Disable GridView scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Number of columns in grid
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio:
                          0.7, // Adjusted for better space for text
                    ),
                    itemCount: kategoriPendapatanList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final kategori = kategoriPendapatanList[index];
                      return GestureDetector(
                        onTap: () {
                          // Simpan kategori yang dipilih di controller
                          controller.selectedKategori.value = kategori['label'];
                          Navigator.pop(context); // Tutup bottom sheet
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30, // Ukuran icon
                              backgroundColor: Colors.grey[200],
                              child: Image.asset(
                                kategori[
                                    'icon'], // Menampilkan gambar dari assets
                                width: 28, // Ukuran gambar
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 70, // Batasan lebar teks
                              child: Text(
                                kategori[
                                    'label'], // Menggunakan 'labels' yang benar
                                style: TextStyle(fontSize: 12),
                                textAlign: TextAlign.center, // Rata tengah
                                softWrap: true, // Mengizinkan pembungkusan teks
                                overflow:
                                    TextOverflow.visible, // Tidak overflow
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final List<Map<String, String>> categories = [
    {'labels': 'Makan', 'icon': 'assets/icons/makanan.png'},
    {'labels': 'Transport', 'icon': 'assets/icons/cars.png'},
    {'labels': 'Belanja', 'icon': 'assets/icons/shop2.png'},
    {'labels': 'Hiburan', 'icon': 'assets/icons/hiburan.png'},
    {'labels': 'Pendidikan', 'icon': 'assets/icons/pendidikan.png'},
    {'labels': 'Rumah Tangga', 'icon': 'assets/icons/rt.png'},
    {'labels': 'Investasi', 'icon': 'assets/icons/investasi.png'},
    {'labels': 'Kesehatan', 'icon': 'assets/icons/kesehatan.png'},
    {'labels': 'Liburan', 'icon': 'assets/icons/liburan.png'},
    {'labels': 'Perbaikan Rumah', 'icon': 'assets/icons/rumah.png'},
    {'labels': 'Pakaian', 'icon': 'assets/icons/outfit.png'},
    {'labels': 'Internet', 'icon': 'assets/icons/internet.png'},
    {'labels': 'Olahraga & Gym', 'icon': 'assets/icons/gym.png'},
    {'labels': 'Lainnya', 'icon': 'assets/icons/lainnya.png'},
  ];

  // Fungsi untuk menampilkan pilihan kategori
  void showCategorySelection(
      BuildContext context, List<String> existingCategories) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            // Tambahkan ini
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: categories.map((category) {
                  String label = category['labels']!;
                  String iconPath = category['icon']!;

                  return ListTile(
                    leading: Image.asset(iconPath, width: 24, height: 24),
                    title: Text(label),
                    enabled: !existingCategories.contains(label),
                    onTap: existingCategories.contains(label)
                        ? null
                        : () {
                            Navigator.pop(context);
                            _showValueLimitModal(context, label);
                          },
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  // Month Container with Month on top and Year below
  Widget buildMonthContainer(String monthYear, [bool isCurrent = false]) {
    final parts = monthYear.split(" ");
    final month = parts[0];
    final year = parts[1];

    return Container(
      width: 90,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: isCurrent ? Color(0xFF1E2147) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Color.fromARGB(255, 189, 189, 189).withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            year,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Create a NumberFormat for Rupiah
  final NumberFormat rupiahFormat = NumberFormat.currency(
    locale: 'id', // Indonesian locale
    symbol: 'Rp ', // Currency symbol for Rupiah
    decimalDigits: 0, // No decimal places
  );

// Transaction Group by Date
  Widget buildTransactionItem(
    String date,
    String amount,
    String category,
    BataspengeluaranController controller,
  ) {
    return StreamBuilder<double>(
      stream: controller.getTotalPengeluaran(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        double amountValue = snapshot.data ?? 0.0;

        return FutureBuilder<double>(
          future: controller.getBatasPengeluaran(category),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }

            double target = futureSnapshot.data ?? 0.0;
            double progress = amountValue / (target > 0 ? target : 1);

            // Find the appropriate icon based on the category
            String iconPath = 'assets/icons/default.png'; // Default icon
            for (var cat in categories) {
              if (cat['labels'] == category) {
                iconPath = cat['icon']!;
                break;
              }
            }
            double iconSize = 48; // Icon size

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Replace CircleAvatar with Image
                      Image.asset(
                        iconPath,
                        width: iconSize,
                        height: iconSize,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(date, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(
                              context, category, amountValue, target);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(thickness: 1, color: Colors.grey.withOpacity(0.5)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Digunakan",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                rupiahFormat.format(amountValue),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Target",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            rupiahFormat.format(target),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        height: 80,
                        width: 20,
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0 ? Colors.red : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    String category,
    double amountValue,
    double target,
  ) {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    controller.getBatasPengeluaran(category).then((limitAmount) {
      _amountController.text = currencyFormatter.format(limitAmount);

      showModalBottomSheet(
        context: context,
        isScrollControlled:
            true, // Allows the bottom sheet to resize with keyboard
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Adjust for keyboard
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Drag indicator at the top of the modal
                    Container(
                      height: 4,
                      width: 40,
                      margin: EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title text
                    Text(
                      'Edit Batas Pengeluaran',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),

                    // Input field directly below the amount display
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Rp 0,00',
                        hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Silakan masukkan jumlah';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Remove non-digit characters
                        String numericValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (numericValue.isNotEmpty) {
                          double jumlah = double.tryParse(numericValue) ?? 0.0;
                          // Update TextField with currency format
                          _amountController.value = TextEditingValue(
                            text: currencyFormatter.format(jumlah),
                            selection: TextSelection.collapsed(
                                offset:
                                    currencyFormatter.format(jumlah).length),
                          );
                        }
                      },
                    ),

                    // "Simpan" button at the bottom
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text('Batal',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Warna tombol
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Menghapus simbol sebelum parsing
                              String rawValue = _amountController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              double amount = double.tryParse(rawValue) ?? 0.0;

                              // Update transaksi
                              await controller.updateTransactionItem(
                                  category, amount);

                              // Tampilkan animasi sukses setelah transaksi disimpan
                              await controller.showSuccessAnimation(context);

                              // Tutup dialog atau pop halaman jika dibutuhkan
                              Navigator.of(context).pop();
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

// Widget untuk membangun grup transaksi berdasarkan tanggal
  Widget buildTransactionGroup(
    String date,
    List<Map<String, dynamic>> transactions,
    BataspengeluaranController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tanggal grup
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            date, // Menampilkan tanggal
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        // List transaksi di dalam grup
        Column(
          children: transactions.map((transaction) {
            return buildTransactionItem(
              transaction['date']!,
              transaction['amount'].toString(), // Mengubah nominal ke string
              transaction['category']!,
              controller, // Pass the controller
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showValueLimitModal(BuildContext context, String kategori) {
    TextEditingController jumlahController = TextEditingController();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to resize with keyboard
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjusts for keyboard
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag indicator at the top of the modal
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // "Nilai Batas" title
                Text(
                  'Nilai Batas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                // Input field directly below the value display
                SizedBox(height: 20),
                TextField(
                  controller: jumlahController,
                  decoration: InputDecoration(
                    hintText: 'Rp 0,00',
                    hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center, // Center-align input text
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    // Remove non-digit characters
                    String numericValue =
                        value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (numericValue.isNotEmpty) {
                      double jumlah = double.tryParse(numericValue) ?? 0.0;
                      // Update TextField with currency format
                      jumlahController.value = TextEditingValue(
                        text: currencyFormatter.format(jumlah),
                        selection: TextSelection.collapsed(
                            offset: currencyFormatter.format(jumlah).length),
                      );
                    }
                  },
                ),

                // "Simpan" button at the bottom
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      padding:
                          EdgeInsets.symmetric(vertical: 16), // Button height
                    ),
                    child:
                        Text('Simpan', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      // Parse and remove formatting symbols
                      String rawValue = jumlahController.text
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      double jumlah = double.tryParse(rawValue) ?? 0.0;

                      // Execute save action (e.g., controller function)
                      await controller.addBatasPengeluaran(kategori, jumlah);

                      // Show success animation
                      await controller.showSuccessAnimation(context);

                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
