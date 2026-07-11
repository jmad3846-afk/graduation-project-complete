import 'package:flutter/material.dart';

class ReportHeader extends StatelessWidget {
  const ReportHeader({super.key, required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFF4040),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'New Emergency Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

