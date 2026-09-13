import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'animated_background.dart';
import 'glass_nav_bar.dart';

/// Shell padrão para todas as telas do app.
///
/// Empilha:
/// 1. `AnimatedBackground` (gradientes difusos em loop)
/// 2. Conteúdo da rota atual
/// 3. `GlassNavBar` no rodapé (3D com Liquid Glass)
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _items = [
    GlassNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Hoje',
      route: '/',
    ),
    GlassNavItem(
      icon: Icons.water_drop_outlined,
      activeIcon: Icons.water_drop,
      label: 'Hábitos',
      route: '/habits',
    ),
    GlassNavItem(
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
      label: 'Tarefas',
      route: '/tasks',
    ),
    GlassNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Foco',
      route: '/pomodoro',
    ),
    GlassNavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      label: 'Stats',
      route: '/stats',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Sem `extendBody: true` — assim o FAB respeita a nav bar 3D
        // e fica visível acima dela. As telas usam `padding-bottom`
        // grande pra não cortar o último conteúdo sob a nav.
        body: child,
        bottomNavigationBar: GlassNavBar(
          items: _items,
          currentRoute: location,
          onTap: (route) => context.go(route),
        ),
      ),
    );
  }
}
