import 'package:flutter/material.dart';

/// Soft card shadow: blur 12, 6% black.
abstract final class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
