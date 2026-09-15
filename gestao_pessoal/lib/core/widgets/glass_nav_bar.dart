import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Item de navegação com rótulo + ícone.
class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// Barra de navegação inferior flat dark.
///
/// Design system "Financial App — Dark/Green":
/// - Background: `#141414` (surface)
/// - Border: 1px `#1E1E1E`
/// - Radius: 24px (radius-lg)
/// - Item ativo: ícone + label em `#00E676` (primary)
/// - Item inativo: ícone + label em `#7A7A7A` (text-secondary)
/// - Sem drop shadow — depth via surface vs background
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final String currentRoute;
  final ValueChanged<String> onTap;

  int get _activeIndex {
    for (var i = 0; i < items.length; i++) {
      if (items[i].route == currentRoute) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppColors.space5, 0, AppColors.space5, AppColors.space4),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusLg),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppColors.space2,
            vertical: AppColors.space2 + 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavButton(
                  item: items[i],
                  active: i == _activeIndex,
                  onTap: () => onTap(items[i].route),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });
  final GlassNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: AppColors.space2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}