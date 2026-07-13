// ignore_for_file: unused_import

import 'package:doc_app_2/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ambulance Management System',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto', 
      ),
      home: const SplashView(),
    );
  }
}