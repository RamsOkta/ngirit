import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';

import 'package:intl/intl.dart';
import '../controllers/cashflow_controller.dart';

class CashflowView extends GetView<CashflowController> {
  final CashflowController controller = Get.put(CashflowController());

  // State variable to track if search is active
  final RxBool isSearchActive = false.obs; // Using GetX for reactivity
  final TextEditingController searchController =
      TextEditingController(); // Controller for the search input
  final RxList<String> selectedFilters =
      <String>[].obs; // For storing selected filters

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
              child: Obx(
                () => isSearchActive.value
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Smaller TextField to fit within the curve
                          Container(
                            width: 220, // Adjust width as necessary
                            height: 40, // Set a fixed height
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari barang...',
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search,
                                      color: Color.fromARGB(255, 218, 218,
                                          218)), // Search button on the right
                                  onPressed: () {
                                    controller
                                        .performSearch(searchController.text);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.times,
                                color: Color.fromARGB(
                                    255, 255, 255, 255)), // Cancel button
                            onPressed: () {
                              isSearchActive.value = false; // Cancel search
                              searchController.clear();
                              controller
                                  .performSearch(''); // Clear search input
                            },
                          ),
                        ],
                      )
                    : Text(
                        'Arus Kas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                        ),
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
                            onTap: () {
                              isSearchActive.value = true; // Activate search
                              Navigator.pop(context); // Close the bottom sheet
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.filter_list), // Filter icon
                            title: Text('Filter'),
                            onTap: () {
                              Navigator.pop(context); // Close the bottom sheet
                              _showFilterOptions(
                                  context); // Show filter options
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.date_range), // Date range icon
                            title: Text('Berdasarkan Periode'),
                            onTap: () {
                              Navigator.pop(context); // Close the bottom sheet
                              _showFilterOptions(
                                  context); // Close the bottom sheet
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
                      SizedBox(width: 3), // Reduced spacing
                      // Selected Month Container
                      Expanded(
                        child: Obx(() => buildMonthContainer(
                            controller.selectedMonth, true)),
                      ),
                      SizedBox(width: 3), // Reduced spacing
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

                // Financial summary section
                buildFinancialSummary(),
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
                  Get.toNamed('/statistic');
                },
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.bullseye, size: 30),
                onPressed: () {
                  Get.toNamed('/batas');
                },
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
              return buildTransactionItem(
                transaction["date"]!,
                transaction["description"]!,
                transaction["amount"]!,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Transaction Card Item
  Widget buildTransactionItem(String date, String description, String amount) {
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
      child: Row(
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
                Text(description,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(date, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Financial Summary Section
  Widget buildFinancialSummary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Text(
                    'Rp ${controller.income.value}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Text(
                'Pemasukan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Text(
                    'Rp ${controller.expense.value}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Text(
                'Pengeluaran',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Text(
                    'Rp ${controller.balance.value}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Text(
                'Saldo',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

// Show filter options in a dialog
  static void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Filter Options',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterSection('Jenis', [
                  {'title': 'Pendapatan', 'icon': Icons.attach_money},
                  {'title': 'Pengeluaran', 'icon': Icons.money_off},
                  {'title': 'Transfer', 'icon': Icons.swap_horiz},
                  {'title': 'Rilis Tetap', 'icon': Icons.lock_clock},
                  {'title': 'Angsuran', 'icon': Icons.schedule},
                ]),
                _buildFilterSection('Situasi', [
                  {'title': 'Terselesaikan', 'icon': Icons.check_circle},
                  {'title': 'Tertunda', 'icon': Icons.pause_circle_filled},
                ]),
                _buildFilterSection('Keseimbangan Keuangan', [
                  {'title': 'Pengeluaran Penting', 'icon': Icons.warning},
                  {'title': 'Pengeluaran Tidak Penting', 'icon': Icons.info},
                ]),
                _buildFilterSection('Akun', [
                  {'title': 'BRI', 'icon': Icons.account_balance},
                  {'title': 'BCA', 'icon': Icons.account_balance_wallet},
                  {'title': 'Mandiri', 'icon': Icons.business},
                  {'title': 'BNI', 'icon': Icons.local_atm},
                  {'title': 'BKK', 'icon': Icons.account_circle},
                ]),
                _buildFilterSection('Kartu Kredit', [
                  {'title': 'BRI Kredit', 'icon': Icons.credit_card},
                  {'title': 'BCA Kredit', 'icon': Icons.credit_card},
                  {'title': 'Mandiri Kredit', 'icon': Icons.credit_card},
                  {'title': 'BNI Kredit', 'icon': Icons.credit_card},
                  {'title': 'BKK Kredit', 'icon': Icons.credit_card},
                ]),
                _buildCategorySection(
                    context), // Kategori section at the bottom
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Terapkan', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Handle apply filters logic
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Batal',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Build a section of filter options
  static Widget _buildFilterSection(
      String title, List<Map<String, dynamic>> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue)),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: options.map((option) {
              return FilterButton(
                title: option['title'],
                icon: option['icon'],
              );
            }).toList(),
          ),
          Divider(color: Colors.grey.shade300, thickness: 1.5),
        ],
      ),
    );
  }

// Build Kategori Section (New Section)
  static Widget _buildCategorySection(BuildContext context) {
    // Define categories with icons
    List<Map<String, dynamic>> categories = [
      {'title': 'Makanan', 'icon': Icons.fastfood},
      {'title': 'Minuman', 'icon': Icons.local_drink},
      {'title': 'Alat Mandi', 'icon': Icons.bathtub},
      {'title': 'Wisata', 'icon': Icons.explore},
      {'title': 'Nongkrong', 'icon': Icons.coffee},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
          ),
          GestureDetector(
            onTap: () {
              _showCategorySelection(context, categories);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              margin: EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCategory ?? 'Pilih Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Show Kategori selection dialog (Updated Dialog)
  static void _showCategorySelection(
      BuildContext context, List<Map<String, dynamic>> categories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Pilih Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      selectedCategory = category['title'];
                      Navigator.of(context).pop();
                    },
                    child: FilterButton(
                      title: category['title'],
                      icon: category['icon'],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    ).then((value) {
      // Refresh UI after category selection
      (context as Element).markNeedsBuild();
    });
  }
}

// Filter button class for options like Jenis, Situasi, etc.
class FilterButton extends StatefulWidget {
  final String title;
  final IconData? icon; // Added icon parameter

  FilterButton({required this.title, this.icon});

  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon,
                  color: isSelected ? Colors.white : Colors.black87),
              SizedBox(width: 8), // Space between icon and text
            ],
            Text(
              widget.title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? selectedCategory;
