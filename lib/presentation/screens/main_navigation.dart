import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../widgets/starry_background.dart';
import 'archived/archived_screen.dart';
import 'current/current_screen.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';
import 'upcoming/upcoming_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    UpcomingScreen(),
    CurrentScreen(),
    ArchivedScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return StarryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: S.of(context).homeTitle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.schedule),
              label: S.of(context).upcomingTitle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.play_circle),
              label: S.of(context).currentTitle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.archive),
              label: S.of(context).archivedTitle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: S.of(context).settingsTitle,
            ),
          ],
        ),
      ),
    );
  }
}