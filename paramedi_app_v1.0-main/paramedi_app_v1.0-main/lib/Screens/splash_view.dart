import 'dart:async';
import 'package:flutter/material.dart';
import '../Screens/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // الانتقال بعد 3 ثوانٍ إلى صفحة تسجيل الدخول
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE52E2E), // اللون الأحمر المميز للواجهة
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              // صورة سيارة الإسعاف (قم باستبدال المسار بملف الأصول الخاص بك)
              ClipRRect(
                child: Image(
                  image: AssetImage('assets/images/car.png'),
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 30),
              // شريط التقدم اليدوي المقارب للتصميم
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: 0.6, // قيمة ثابتة تشبه لقطة الشاشة أو يمكنك جعلها متحركة
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    minHeight: 12,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // النص الإيجابي والمؤثر أسفل الشريط
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Every time you reach the point of collapse from exhaustion, remember those lives you saved and that smile you put on the face of the grieving mother after you rescued her son. We are proud of you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}