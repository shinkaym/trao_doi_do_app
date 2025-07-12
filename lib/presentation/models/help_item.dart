import 'package:flutter/material.dart';

class HelpItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;

  const HelpItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });
}
