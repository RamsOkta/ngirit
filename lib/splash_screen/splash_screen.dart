import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ngirit/onboarding_screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0; // Initial opacity for animation
  late AnimationController _controller;
  double spinnerSize = 50; // Spinner size can be adjusted here

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for loading animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Speed of rotation
    )..repeat(); // Keep the animation looping

    // Trigger the opacity animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate to the next screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(22, 25, 59, 1), Colors.blue.shade700],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Opacity for logo
            AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 2), // Duration for fade-in effect
              child: Image.asset(
                'assets/images/splash_logo.png', // Replace with your logo
                height: 100.0,
              ),
            ),
            SizedBox(height: 20),
            // Spinner animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 6.28, // Full circle rotation
                  child: child,
                );
              },
              child: Container(
                width: spinnerSize, // Dynamically set size
                height: spinnerSize, // Dynamically set size
                child: CustomPaint(
                  painter: SpinnerPainter(spinnerSize), // Pass size here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw the spinner
class SpinnerPainter extends CustomPainter {
  final double spinnerSize; // Accept size from constructor

  SpinnerPainter(this.spinnerSize); // Constructor to accept spinner size

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Number of spokes (ticks) in the spinner
    int tickCount = 12;
    double angleStep = 2 * pi / tickCount;

    for (int i = 0; i < tickCount; i++) {
      double opacity = i / tickCount; // Varying opacity for fading effect
      paint.color = Colors.white.withOpacity(opacity);

      // Calculate start and end points for each tick based on spinner size
      double startX = size.width / 2 + spinnerSize * 0.3 * cos(i * angleStep);
      double startY = size.height / 2 + spinnerSize * 0.3 * sin(i * angleStep);
      double endX = size.width / 2 + spinnerSize * 0.4 * cos(i * angleStep);
      double endY = size.height / 2 + spinnerSize * 0.4 * sin(i * angleStep);

      // Draw each tick
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
