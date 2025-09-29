import 'package:flutter/material.dart';
import 'screens/log_screen.dart';
import 'constants/index.dart';

void main() {
  runApp(const NotifySMSApp());
}

class NotifySMSApp extends StatelessWidget {
  const NotifySMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notify SMS',
      theme: AppTheme.lightTheme,
      home: const LogScreen(),
    );
  }
}
