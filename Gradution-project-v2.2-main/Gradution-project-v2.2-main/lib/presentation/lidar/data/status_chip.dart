// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget statusChip(String status, Color fallback) {
  Color bg;
  Color fg;

  // Movement-log-derived labels look like "انطلاق (مريض) 14:32" — match by
  // the leading step word rather than the whole string, since it carries a
  // trailing timestamp that varies per case.
  if (status.startsWith('انطلاق')) {
    bg = Colors.blue.withOpacity(0.1);
    fg = Colors.blue;
  } else if (status.startsWith('وصول')) {
    bg = Colors.green.withOpacity(0.1);
    fg = Colors.green;
  } else if (status.startsWith('عودة')) {
    bg = Colors.amber.withOpacity(0.1);
    fg = Colors.amber.shade800;
  } else {
    bg = fallback.withOpacity(0.1);
    fg = fallback;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}
