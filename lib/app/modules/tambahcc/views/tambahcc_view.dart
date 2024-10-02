  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import '../controllers/tambahcc_controller.dart';

  class TambahccView extends GetView<TambahccController> {
    const TambahccView({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor:
            Color.fromARGB(255, 245, 245, 245), // Warna latar belakang
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
                              Get.back(); // Kembali ke halaman sebelumnya
                            },
                          ),
                          // Teks "Tambah Kartu" di tengah
                          Expanded(
                            child: Center(
                              child: Text(
                                'Tambah Kartu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),

                  // Padding untuk menghindari konten tertutup oleh gradient container
                  SizedBox(height: 16),

                  // Konten halaman
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input Nama Kartu
                        Text('Nama Kartu',
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                        SizedBox(height: 8),
                        TextField(
                          onChanged: (value) =>
                              controller.namaKartu.value = value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Pilih Ikon
                        Text(
                          'Pilih Icon Akun:',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        Obx(() {
                          return GestureDetector(
                            onTap: () {
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            onChanged: (value) {
                                              controller.searchIcon(value);
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Cari Icon',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Obx(() {
                                            return GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    3, // Atur jumlah kolom sesuai kebutuhan
                                                childAspectRatio:
                                                    1.0, // Aspect ratio untuk setiap ikon
                                              ),
                                              itemCount:
                                                  controller.filteredIcons.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    controller
                                                            .selectedIcon.value =
                                                        controller
                                                            .filteredIcons[index];
                                                    controller.ikonKartu.value =
                                                        controller
                                                            .filteredIcons[index];
                                                    Get.back(); // Tutup bottom sheet
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          image: DecorationImage(
                                                            image: AssetImage(
                                                                controller
                                                                        .filteredIcons[
                                                                    index]),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        controller.iconLabels[
                                                            controller.icons
                                                                .indexOf(controller
                                                                        .filteredIcons[
                                                                    index])],
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                            fontSize: 12),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
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
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: controller
                                              .selectedIcon.value !=
                                          null
                                      ? AssetImage(controller.selectedIcon.value!)
                                      : null,
                                  child: controller.selectedIcon.value == null
                                      ? Icon(Icons.add,
                                          size: 32, color: Colors.black)
                                      : null,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  controller.selectedIcon.value != null
                                      ? 'Ikon Terpilih'
                                      : 'Pilih Icon Akun',
                                  style: TextStyle(
                                      color: const Color.fromARGB(255, 7, 7, 7)),
                                ),
                              ],
                            ),
                          );
                        }),

                        SizedBox(height: 16),

                        // Input Limit Kredit
                        Text('Limit Kredit',
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                        SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              controller.limitKredit.value = value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Rp. 0,00',
                          ),
                        ),
                        SizedBox(height: 16),

                        // Input Tanggal Mulai dan Berakhir
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mulai',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black)),
                                  SizedBox(height: 8),
                                  TextField(
                                    onChanged: (value) =>
                                        controller.tanggalMulai.value = value,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Tanggal 01',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Berakhir',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black)),
                                  SizedBox(height: 8),
                                  TextField(
                                    onChanged: (value) =>
                                        controller.tanggalBerakhir.value = value,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Tanggal 01',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Akun Pembayaran
                        Text('Akun Pembayaran',
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showAkunList(context),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.add,
                                    size: 32, color: Colors.black),
                              ),
                              SizedBox(width: 8),
                              Obx(() => Text(
                                  controller.akunPembayaran.value.isEmpty
                                      ? 'Pilih Akun Pembayaran'
                                      : controller.akunPembayaran.value,
                                  style: TextStyle(color: Colors.black))),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Tombol Buat Akun
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.simpanKartuKredit();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 16),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Buat Kartu'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // Menampilkan daftar akun
    void _showAkunList(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 300, // Set height sesuai kebutuhan
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.akunList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(controller.akunList[index]['nama_akun']),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(controller.akunList[index]['icon']),
                    ),
                    onTap: () {
                      controller.akunPembayaran.value =
                          controller.akunList[index]['nama_akun'];
                      Get.back(); // Menutup bottom sheet
                    },
                  );
                },
              );
            }),
          );
        },
      );
    }
  }
