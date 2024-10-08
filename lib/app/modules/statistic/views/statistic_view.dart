import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controllers/statistic_controller.dart';

class StatisticView extends GetView<StatisticController> {
  final StatisticController controller = Get.put(StatisticController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Curved top app bar with dark color
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFF1E2147),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
          ),
          // Positioned 'Statistik' title
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Statistik',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          // Positioned Month Section (keeps your original design)
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Expanded(
                    child: Obx(
                        () => buildMonthContainer(controller.previousMonth)),
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: Obx(() =>
                        buildMonthContainer(controller.selectedMonth, true)),
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: Obx(() => buildMonthContainer(controller.nextMonth)),
                  ),
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
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.only(top: 160, left: 16, right: 16),
            child: SingleChildScrollView(
              // Allow scrolling
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  // 'Pemasukan dan Pengeluaran' bar chart
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemasukan dan Pengeluaran',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Obx(() {
                          double totalIncome = controller.income
                              .reduce((a, b) => a + b)
                              .toDouble();
                          double totalExpense = controller.expense
                              .reduce((a, b) => a + b)
                              .toDouble();

                          return SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: totalIncome,
                                        color: Colors.green,
                                        width: 50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: totalExpense,
                                        color: Colors.red,
                                        width: 50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ],
                                  ),
                                ],
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        if (value == 0) {
                                          return Text('Pemasukan');
                                        } else if (value == 1) {
                                          return Text('Pengeluaran');
                                        }
                                        return Text('');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 10),
                        // Add labels and values below the bar chart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Rp. 100.000,00',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Pemasukan'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Rp. 10.000,00',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Pengeluaran'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Rp. 10.000.000,00',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Saldo'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 'Pengeluaran Berdasarkan Kategori' pie chart
                  Text(
                    'Pengeluaran Berdasarkan Kategori',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10), // Reduced spacing
                  Container(
                    height: 200,
                    padding: EdgeInsets.all(16), // Added padding for neatness
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white, width: 2), // White border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: 40,
                            title: '40%',
                            radius: 50,
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: 30,
                            title: '30%',
                            radius: 50,
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: 30,
                            title: '30%',
                            radius: 50,
                          ),
                        ],
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ],
              ),
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
