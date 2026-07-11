import 'dart:async';
import 'package:flutter/material.dart';
import '../login/login.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // يتم استدعاء المؤقت كل 100 مللي ثانية
    // للوصول إلى 3 ثواني (3000 مللي ثانية)، نحتاج إلى 30 خطوة
    // لذلك نزيد التقدم بمقدار 0.0333... في كل خطوة (1.0 / 30 ≈ 0.0333)
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) {
        setState(() {
          progress += (1.0 / 30.0);


          if (progress >= 1.0) {
            progress = 1.0;
            timer.cancel();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/car2.jpg',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.height * 0.8,
            ),
            const SizedBox(height: 20),
            const Text(
              'WELCOME TO SARC OP ROOM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
