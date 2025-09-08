import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shoping/core/routes/configuration.dart';
import 'package:shoping/core/theme/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeController(),
      child: ECommerceApp(),
    ),
  );
}


class ECommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp.router(
          title: 'Modern E-Commerce',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFce9fc9),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.cairoTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFce9fc9),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
          ),
          themeMode: themeController.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}

















