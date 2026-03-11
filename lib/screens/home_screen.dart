import 'package:flutter/material.dart';
import '../services/widget_sync_service.dart';
import '../widgets/floating_nav_bar.dart';
import 'today_screen.dart';
import 'timetable_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final GlobalKey<TodayScreenState> _todayKey = GlobalKey();
  final GlobalKey<TimetableScreenState> _timetableKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetSyncService.syncAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _todayKey.currentState?.refresh();
      WidgetSyncService.syncAll();
    }
  }

  void _onDataChanged() {
    _todayKey.currentState?.refresh();
    _timetableKey.currentState?.refresh();
    WidgetSyncService.syncAll();
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return TodayScreen(key: _todayKey);
      case 1:
        return TimetableScreen(key: _timetableKey);
      case 2:
        return SettingsScreen(onDataChanged: _onDataChanged);
      default:
        return TodayScreen(key: _todayKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _buildCurrentScreen(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: FloatingNavBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
