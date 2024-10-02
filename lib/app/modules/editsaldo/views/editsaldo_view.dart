import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/editsaldo_controller.dart';

class EditsaldoView extends GetView<EditsaldoController> {
  const EditsaldoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Saldo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field for account name
            TextField(
              controller: controller.namaAkunController,
              decoration: const InputDecoration(
                labelText: 'Nama Akun',
              ),
            ),
            const SizedBox(height: 20),

            // Input field for saldo
            TextField(
              controller: controller.saldoAkunController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Saldo Awal',
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown or icon selector
            const Text('Pilih Ikon Akun:'),
            Obx(() => DropdownButton<IconData>(
                  value: controller.selectedIcon.value,
                  items: controller.icons.map((icon) {
                    return DropdownMenuItem<IconData>(
                      value: icon,
                      child: Icon(icon),
                    );
                  }).toList(),
                  onChanged: (icon) {
                    controller.selectedIcon.value = icon;
                  },
                )),

            const SizedBox(height: 40),

            // Save button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  controller.updateSaldo();
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
