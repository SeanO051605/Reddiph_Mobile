import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'views/screens/portal_screen.dart';

void main() => runApp(const ReddiphApp());

class ReddiphApp extends StatelessWidget {
  const ReddiphApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Reddiph',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const PortalScreen(),
      );
}
