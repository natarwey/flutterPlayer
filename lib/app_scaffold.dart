import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showBottomNav;
  final Widget? customBottomNavBar;
  final Widget? drawer;
  final Widget? floatingPlayer;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBottomNav = true,
    this.customBottomNavBar,
    this.drawer,
    this.floatingPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: title != null 
                ? AppBar(
                  title: Text(title!),backgroundColor: Colors.transparent)
                : null,
            body: body,
            drawer: drawer,
            bottomNavigationBar: showBottomNav 
                ? (customBottomNavBar ?? const _AppBottomNavBar())
                : null,
          ),
          if (floatingPlayer != null)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: floatingPlayer!,
            ),
        ],
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 119, 119, 119),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.maybePop(context),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 24),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}