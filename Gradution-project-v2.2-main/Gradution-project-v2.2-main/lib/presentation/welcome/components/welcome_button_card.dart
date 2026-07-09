import 'package:flutter/material.dart';
import '../models/welcome_button_model.dart';

class WelcomeButtonCard extends StatelessWidget {
  final WelcomeButtonModel data;

  const WelcomeButtonCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: data.onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data.icon,
                size: 40,
                color: Colors.red[600],
              ),
              const SizedBox(height: 10),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
