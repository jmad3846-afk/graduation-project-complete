import 'package:flutter/material.dart';

class BaseInfoCard extends StatelessWidget {
  const BaseInfoCard({
    super.key,
    required this.primary,
    required this.secondary,
    required this.child,
  });

  final Color primary;
  final Color secondary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: Colors.black12),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: primary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: secondary),
              child: const SizedBox.shrink(),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

