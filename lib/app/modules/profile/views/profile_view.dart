import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Container yang menutup hingga ke AppBar
          Container(
            width: double.infinity,
            height:
                320, // Tinggi Container disesuaikan agar menutup bagian AppBar
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
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Menggunakan Obx untuk mengamati perubahan data pada controller
                Obx(() {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        controller.profilePictureUrl.value.isNotEmpty
                            ? NetworkImage(controller.profilePictureUrl.value)
                            : AssetImage('assets/default_profile.png')
                                as ImageProvider,
                    backgroundColor: Colors.white,
                  );
                }),
                SizedBox(height: 10),
                Obx(() {
                  return Text(
                    controller.username.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                SizedBox(
                    height:
                        20), // Spasi tambahan agar tombol tidak terlalu dekat
                ElevatedButton(
                  onPressed: () {
                    // Arahkan ke halaman edit profile
                    Get.toNamed('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white, // Background color
                  ),
                  child: Text(
                    'Edit Profil',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bagian atas AppBar dengan transparansi
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Aksi ketika tombol back ditekan
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    // Aksi ketika tombol settings ditekan
                  },
                ),
              ],
            ),
          ),
          // Isi konten lainnya (Profile dan ListTile)
          Column(
            children: [
              SizedBox(
                  height: 300), // Menyesuaikan agar konten di bawah Container
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildListTile('Kantor', Icons.account_balance),
                    _buildListTile('Kartu Kredit', Icons.credit_card),
                    _buildListTile('Kategori', Icons.category),
                    _buildListTile('Tags', Icons.label),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membuat ListTile dengan ikon dan teks
  Widget _buildListTile(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          onTap: () {
            // Aksi ketika ListTile ditekan
          },
        ),
      ),
    );
  }
}
