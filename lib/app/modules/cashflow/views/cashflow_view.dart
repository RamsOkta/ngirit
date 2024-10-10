import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';

import 'package:intl/intl.dart';
import '../controllers/cashflow_controller.dart';

class CashflowView extends GetView<CashflowController> {
  final CashflowController controller = Get.put(CashflowController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
          // Positioned Batas Pengeluaran text
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Arus Kas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          // Three dots button (overflow menu) positioned at the top-right corner
          Positioned(
            top: 30,
            right: 12,
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Show the bottom sheet menu
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white, // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20), // Rounded corners
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.search), // Search icon
                            title: Text('Pencarian'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.filter_list), // Filter icon
                            title: Text('Filter'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.date_range), // Date range icon
                            title: Text('Berdasarkan Periode'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Main content with Padding
          Padding(
            padding: const EdgeInsets.only(top: 90.0), // Adjusted top padding
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () => ListView(
                      children: [
                        // Expenses Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.expenses.length,
                          itemBuilder: (context, index) {
                            final expense = controller.expenses[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(Icons.arrow_downward,
                                    color: Colors.red),
                                title: Text(expense['nominal'].toString(),
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Deskripsi: ${expense['deskripsi']}'),
                                    Text('Kategori: ${expense['kategori']}'),
                                    Text('Akun: ${expense['akun']}'),
                                    Text('Tanggal: ${expense['tanggal']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Income Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20.0),
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.income.length,
                          itemBuilder: (context, index) {
                            final income = controller.income[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(Icons.arrow_upward,
                                    color: Colors.green),
                                title: Text(income['nominal'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Deskripsi: ${income['deskripsi']}'),
                                    Text('Kategori: ${income['kategori']}'),
                                    Text('Akun: ${income['akun']}'),
                                    Text('Tanggal: ${income['tanggal']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed Total Income and Expenses Section
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Pengeluaran',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red)),
                              Text(
                                  'Rp ${controller.totalExpenses.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Pemasukan',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.green)),
                              Text(
                                  'Rp ${controller.totalIncome.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                        ],
                      )),
                ),
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
          Get.toNamed('/tambahcc');
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
                onPressed: () {},
              ),
              SizedBox(width: 48), // Space for FloatingActionButton
              IconButton(
                icon: Icon(Icons.bar_chart, size: 30),
                onPressed: () {
                  Get.toNamed('/grafik');
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, size: 30),
                onPressed: () {
                  Get.toNamed('/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? selectedCategory;
