import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // تكرار الحركة للأمام والخلف

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -30.0, // ارتفاع الارتداد
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceInOut, // تأثير الارتداد
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  0, _bounceAnimation.value), // تحريك الشعار للأعلى والأسفل
              child: Image.asset(
                'assets/images/logo.png', // اللوجو
                width: 300,
                height: 300,
              ),
            );
          },
        ),
      ),
    );
  }
}
