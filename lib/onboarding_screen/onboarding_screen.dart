import 'package:flutter/material.dart';
import 'package:ngirit/app/modules/masuk/views/masuk_view.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding_image.png",
      "title": "Selamat Datang di\nPerjalanan Hemat Anda",
      "subtitle":
          "Bersama-sama, Kami Akan Membuat Penghematan Menjadi Mudah\nDan Bermanfaat",
    },
    {
      "image": "assets/images/onboarding_image2.png",
      "title": "Bergabunglah Dengan Kami\nTabungan Cerdas",
      "subtitle": "Perjalanan FInansial Anda diMulai disini!",
    },
    {
      "image": "assets/images/onboarding_image1.png",
      "title": "Tetap Pada Jalur\nDengan Mudah",
      "subtitle": "Lacak Pengeluaran dan Capai Tujuan.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(onboardingData[index]["image"]!,
                          height: 200, fit: BoxFit.cover),
                      SizedBox(height: 10),
                      Text(
                        onboardingData[index]["title"]!,
                        style: TextStyle(
                          fontFamily: 'LilitaOne',
                          fontSize: 32,
                          color: Colors.indigo.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        onboardingData[index]["subtitle"]!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(currentIndex == index),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MasukView(),
                      ),
                    );
                  },
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromRGBO(49, 53, 110, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(49, 53, 110, 1),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (currentIndex == onboardingData.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MasukView(),
                        ),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(currentIndex == onboardingData.length - 1
                      ? 'SELESAI'
                      : 'LANJUT'),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildDot(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 12,
      width: isActive ? 24 : 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
