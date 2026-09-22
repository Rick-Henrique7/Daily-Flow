import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../../features/settings/data/settings_controller.dart';

/// Snackbar padronizado do Daily Flow — usado para "Desfazer" exclusões
/// de hábitos/tarefas.
///
/// Visual:
/// - Fundo `surface` (#141414) com borda 1px `border` (#1E1E1E)
/// - Texto `textPrimary` (#FFFFFF)
/// - Ícone à esquerda em `accent` (configurável pelo usuário)
/// - Ação "Desfazer" em `accent` (configurável pelo usuário)
/// - `behavior: floating` com margem inferior para não cobrir a nav bar
/// - Raio 12px (radius-sm) e leve sombra (depth via surface-2 vs background)
///
/// Comportamento:
/// - 4 segundos (padrão Material 3) — o usuário tem tempo de ler e decidir
/// - Tocar em "Desfazer" chama o callback E fecha explicitamente o snackbar
///   (senão fica "travado" até o timeout expirar, sensação de bug)
/// - `dismissDirection` permite arrastar para cima para fechar
class AppUndoSnackBar {
  AppUndoSnackBar._();

  /// Mostra um snackbar com ação "Desfazer" padronizada.
  ///
  /// - [icon]: ícone à esquerda (ex: `Icons.delete_outline`)
  /// - [message]: texto principal
  /// - [onUndo]: callback ao tocar em "Desfazer". Após executar,
  ///   o snackbar é fechado explicitamente.
  /// - [ref]: para ler o accent color atual do usuário.
  static void show(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String message,
    required VoidCallback onUndo,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final accent = ref.read(accentColorProvider);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84), // 84px = nav bar safe-area
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        duration: const Duration(seconds: 4),
        dismissDirection: DismissDirection.up,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: accent,
          onPressed: () {
            onUndo();
            // Fecha explicitamente — sem isso o snackbar fica "travado"
            // até o timeout expirar (sensação de bug).
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
