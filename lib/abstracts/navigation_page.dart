import 'package:flutter/material.dart';

abstract class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  String get route;
  String get name;
  IconData get icon;
}
