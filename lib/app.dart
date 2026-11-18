import 'package:flutter/material.dart';

import 'features/auth/auth_gate.dart';

class EssApp extends StatelessWidget {
  const EssApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ESS • Employee Self Service',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF176B58),
            surface: const Color(0xFFF7F8F6),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F8F6),
          fontFamily: 'Roboto',
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        home: const AuthGate(),
      );
}
