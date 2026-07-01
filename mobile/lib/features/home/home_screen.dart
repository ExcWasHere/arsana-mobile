import 'package:arsana/features/home/pages/materi_belajar_page.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_storage_service.dart';
import '../auth/login_screen.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'pages/beranda_page.dart';
import 'pages/arena_page.dart';
import 'pages/lencana_page.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppPage _currentPage = AppPage.beranda;

  Future<void> _logout() async {
    await AuthStorageService.instance.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: AppPage.values.indexOf(_currentPage),
        children: [
          BerandaPage(onLogout: _logout),
          const MateriBelajarPage(),
          const ArenaPage(),
          const LencanaPage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentPage: _currentPage,
        onNavigate: (page) => setState(() => _currentPage = page),
      ),
    );
  }
}