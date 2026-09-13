import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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

/// Barra de navegação inferior com efeito Liquid Glass 3D.
///
/// Substitui o `BottomNavigationBar` flat do Material por uma camada
/// vítrea que combina com o resto do design system.
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SafeArea(
        top: false,
        child: GlassContainer(
          shape: LiquidRoundedSuperellipse(borderRadius: 28),
          settings: LiquidGlassSettings(
            thickness: 36,
            blur: 24,
            glassColor: Colors.white.withValues(alpha: 0.18),
            lightIntensity: 0.75,
            glowIntensity: 1.0,
            fresnelStrength: 1.3,
            chromaticAberration: 0.025,
            ambientRim: 0.7,
            ambientStrength: 0.15,
            edgeAbsorption: 0.12,
            whitenStrength: 0.05,
            shadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 12),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          useOwnLayer: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
    final color = active
        ? const Color(0xFFC084FC)
        : Colors.white.withValues(alpha: 0.55);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
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
