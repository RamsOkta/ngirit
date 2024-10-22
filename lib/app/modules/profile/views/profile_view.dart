import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Container dengan gradient yang sudah ada
          Container(
            width: double.infinity,
            height: 320,
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
                Stack(
                  children: [
                    // CircleAvatar dengan gambar profil
                    Obx(() {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: controller
                                .profilePictureUrl.value.isNotEmpty
                            ? NetworkImage(controller.profilePictureUrl.value)
                            : AssetImage('assets/images/default_profile.png')
                                as ImageProvider,
                        backgroundColor: Colors.white,
                      );
                    }),
                    // Icon edit gambar di atas CircleAvatar
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          // Menampilkan modal untuk pilih sumber gambar
                          _showImageSourceModal(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 18,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Menampilkan modal untuk edit profil
                    _showEditProfileModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
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
          // AppBar transparan
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
                  Get.back();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    // Aksi untuk settings
                  },
                ),
              ],
            ),
          ),
          // Konten lainnya
          Column(
            children: [
              SizedBox(height: 300),
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

  void _showEditProfileModal(BuildContext context) {
    usernameController.text = controller.username.value;
    passwordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _saveProfileChanges();
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take Profile Picture'),
              onTap: () {
                controller.uploadProfilePicture(fromCamera: true);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Select from Gallery'),
              onTap: () {
                controller.uploadProfilePicture(fromCamera: false);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveProfileChanges() {
    // Simpan username jika tidak kosong
    if (usernameController.text.isNotEmpty) {
      controller.updateUsername(usernameController.text);
    }

    // Simpan password jika tidak kosong
    if (passwordController.text.isNotEmpty) {
      controller.updatePassword(passwordController.text);
    }

    Get.back();
    Get.snackbar('Sukses', 'Perubahan profil berhasil disimpan');
  }

  // Fungsi untuk membuat ListTile
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
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          onTap: () {
            // Aksi ketika ListTile ditekan
          },
        ),
      ),
    );
  }
}
