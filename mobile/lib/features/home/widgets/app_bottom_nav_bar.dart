import 'package:flutter/material.dart';

enum AppPage { beranda, layarIlmu, arena, lencana }
class AppBottomNavBar extends StatelessWidget {
  final AppPage currentPage;
  final ValueChanged<AppPage> onNavigate;

  const AppBottomNavBar({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  static const _tabs = [
    _NavTab(
      page: AppPage.beranda,
      label: 'Beranda',
      icon: Icons.home_rounded,
    ),
    _NavTab(
      page: AppPage.layarIlmu,
      label: 'Layar Ilmu',
      icon: Icons.menu_book_rounded,
    ),
    _NavTab(
      page: AppPage.arena,
      label: 'Arena',
      icon: Icons.sports_esports_rounded,
    ),
    _NavTab(
      page: AppPage.lencana,
      label: 'Lencana',
      icon: Icons.emoji_events_rounded,
    ),
  ];
  static const _activeGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF14B8A6)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFa5f3fc), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: _tabs.map((tab) {
              final active = currentPage == tab.page;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onNavigate(tab.page),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: active ? _activeGradient : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
                          color:
                              active ? Colors.white : const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: active
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final AppPage page;
  final String label;
  final IconData icon;

  const _NavTab({
    required this.page,
    required this.label,
    required this.icon,
  });
}