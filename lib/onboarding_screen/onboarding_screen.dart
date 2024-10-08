import 'package:flutter/material.dart';
import 'package:ngirit/app/modules/masuk/views/masuk_view.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  // List berisi data onboarding (gambar dan teks)
  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding_image.png",
      "title": "Welcome to your\nsaving journey",
      "subtitle": "Together, we'll make saving easy\nand rewarding",
    },
    {
      "image": "assets/images/onboarding_image2.png",
      "title": "Welcome to your\nsaving journey",
      "subtitle": "Together, we'll make saving easy\nand rewarding",
    },
    {
      "image": "assets/images/onboarding_image1.png",
      "title": "Welcome to your\nsaving journey",
      "subtitle": "Together, we'll make saving easy\nand rewarding",
    },
  ];

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
              child: Image.asset(onboardingData[currentIndex]["image"]!),
            ),
            // Mengurangi jarak antara gambar dan teks
            SizedBox(height: 10),
            Text(
              onboardingData[currentIndex]["title"]!,
              style: TextStyle(
                fontFamily: 'LilitaOne',
                fontSize: 32, // Adjust as needed
                color: Colors.indigo.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8), // Mengurangi jarak antara title dan subtitle
            Text(
              onboardingData[currentIndex]["subtitle"]!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Add space between the text and dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(currentIndex == index),
              ),
            ),
            Spacer(), // This spacer separates the dots from the buttons below
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol SKIP dengan warna dan ketebalan teks yang bisa diatur
                TextButton(
                  onPressed: () {
                    // Skip button langsung ke halaman berikutnya
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
                      color: const Color.fromRGBO(
                          49, 53, 110, 1), // Warna teks bisa diubah
                      fontWeight: FontWeight.w600, // Ketebalan teks
                    ),
                  ),
                ),
                // Tombol NEXT dengan pengaturan kotak, warna teks, ketebalan teks, dan lengkungan
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(49, 53, 110, 1),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Ketebalan teks
                    ), // Warna teks
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Lengkungan kotak
                    ),
                  ),
                  onPressed: () {
                    // Jika ini halaman terakhir, lanjut ke NextScreen
                    if (currentIndex == onboardingData.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MasukView(),
                        ),
                      );
                    } else {
                      setState(() {
                        currentIndex++;
                      });
                    }
                  },
                  child: Text(currentIndex == onboardingData.length - 1
                      ? 'FINISH'
                      : 'NEXT'),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat indikator titik
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

class NextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Screen'),
      ),
      body: Center(
        child: Text(
          'This is the next screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
