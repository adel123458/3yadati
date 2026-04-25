import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/home', icon: Icons.home_outlined, active: Icons.home, label: 'الرئيسية'),
    _TabItem(path: '/calendar', icon: Icons.calendar_today_outlined, active: Icons.calendar_today, label: 'المواعيد'),
    _TabItem(path: '/patients', icon: Icons.people_outline, active: Icons.people, label: 'المرضى'),
    _TabItem(path: '/statistics', icon: Icons.bar_chart_outlined, active: Icons.bar_chart, label: 'الإحصائيات'),
    _TabItem(path: '/profile', icon: Icons.person_outline, active: Icons.person, label: 'حسابي'),
  ];

  int _indexFor(String path) {
    final i = _tabs.indexWhere((t) => path.startsWith(t.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _indexFor(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: idx,
            elevation: 0,
            backgroundColor: AppColors.white,
            onTap: (i) => context.go(_tabs[i].path),
            items: [
              for (var i = 0; i < _tabs.length; i++)
                BottomNavigationBarItem(
                  icon: Icon(_tabs[i].icon),
                  activeIcon: Icon(_tabs[i].active),
                  label: _tabs[i].label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String path;
  final IconData icon;
  final IconData active;
  final String label;
  const _TabItem({required this.path, required this.icon, required this.active, required this.label});
}
