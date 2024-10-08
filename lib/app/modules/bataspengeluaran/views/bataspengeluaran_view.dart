import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/bataspengeluaran_controller.dart';

class BataspengeluaranView extends GetView<BataspengeluaranController> {
  final BataspengeluaranController controller =
      Get.put(BataspengeluaranController());

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
              icon: Icon(Icons.add, color: Colors.white), // Change to plus icon
              onPressed: () {
                // Show the bottom sheet menu for category selection
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
                            leading: Icon(Icons
                                .shopping_cart), // Shopping icon for Belanja
                            title: Text('Belanja'),
                            onTap: () {
                              Navigator.pop(
                                  context); // Close the category selection sheet
                              _showValueLimitModal(context, 'Belanja');
                            },
                          ),
                          ListTile(
                            leading: Icon(
                                Icons.bathtub), // Bathtub icon for Alat Mandi
                            title: Text('Alat Mandi'),
                            onTap: () {
                              Navigator.pop(
                                  context); // Close the category selection sheet
                              _showValueLimitModal(context, 'Alat Mandi');
                            },
                          ),
                          ListTile(
                            leading: Icon(
                                Icons.fastfood), // Fast food icon for Makan
                            title: Text('Makan'),
                            onTap: () {
                              Navigator.pop(
                                  context); // Close the category selection sheet
                              _showValueLimitModal(context, 'Makan');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Main content with padding to move it down
          Padding(
            padding: const EdgeInsets.only(top: 100.0), // Adjusted top padding
            child: Column(
              children: [
                SizedBox(height: 30), // Space before month section
                // Month section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Padding lebih besar
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Grouped transactions
                          Obx(() {
                            final groupedTransactions =
                                controller.getGroupedTransactions();
                            return ListView.builder(
                              physics:
                                  NeverScrollableScrollPhysics(), // Prevent scrolling of inner list
                              shrinkWrap: true,
                              itemCount: groupedTransactions.keys.length,
                              itemBuilder: (context, index) {
                                String date =
                                    groupedTransactions.keys.elementAt(index);
                                List<Map<String, String>> transactions =
                                    groupedTransactions[date]!;

                                return buildTransactionGroup(
                                    date, transactions);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
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
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Month Container with Month on top and Year below
  Widget buildMonthContainer(String monthYear, [bool isCurrent = false]) {
    final parts = monthYear.split(" ");
    final month = parts[0]; // Month name
    final year = parts[1]; // Year

    return Container(
      width: 90, // Reduced fixed width to prevent overflow
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
          SizedBox(height: 2), // Space between month and year
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

  // Transaction Group by Date
  Widget buildTransactionGroup(
      String date, List<Map<String, String>> transactions) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Column(
            children: transactions.map((transaction) {
              // Gunakan nilai default untuk target dan progress
              String target = "900000"; // Misal target default adalah 50000
              double progress = double.parse(transaction["amount"]!) /
                  double.parse(
                      target); // Progress dihitung dari amount / target

              return buildTransactionItem(
                transaction["date"]!,
                transaction["description"]!,
                transaction["amount"]!,
                target,
                progress.clamp(0.0, 1.0), // Clamp progress antara 0 hingga 1
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Transaction Card Item
  Widget buildTransactionItem(String date, String description, String amount,
      String target, double progress) {
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
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 24,
                child: Icon(Icons.shopping_cart, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(date, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12), // Spacing between the row and the divider
          Divider(thickness: 1, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 12), // Spacing between the divider and the amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tersedia",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Rp ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        amount,
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
                  Text(
                    "Target",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    target,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                height: 80, // Adjust height as needed
                width: 20, // Adjust width as needed
                child: RotatedBox(
                  quarterTurns: -1, // Rotate to make it vertical
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? Colors.green
                          : Colors.blue, // Change color when full
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to show the value limit modal with input field
  void _showValueLimitModal(BuildContext context, String kategori) {
    TextEditingController jumlahController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan Batas Pengeluaran untuk $kategori'),
          content: TextField(
            controller: jumlahController,
            decoration: InputDecoration(labelText: 'Jumlah'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                double jumlah = double.tryParse(jumlahController.text) ?? 0.0;
                controller.addBatasPengeluaran(kategori, jumlah);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
