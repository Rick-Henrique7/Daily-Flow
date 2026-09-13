import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../data/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  String _colorToHex(Color color) {
    final value = color.toARGB32();
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<void> _openColorPicker(BuildContext context, WidgetRef ref) async {
    final current = _hexToColor(ref.read(settingsProvider).wallpaperSeed);
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _PickerDialog(initial: current),
    );
    if (picked != null) {
      await ref
          .read(settingsProvider.notifier)
          .updateWallpaperSeed(_colorToHex(picked));
    }
  }

  /// Abre o color picker genérico para qualquer campo que recebe HEX.
  Future<void> _openColorPickerForField(
    BuildContext context,
    WidgetRef ref,
    String currentHex,
    Future<void> Function(String) onPicked,
  ) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _PickerDialog(initial: _hexToColor(currentHex)),
    );
    if (picked != null) {
      await onPicked(_colorToHex(picked));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final seedColor = _hexToColor(settings.wallpaperSeed);

    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Configurações'),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          const _SectionHeader('Aparência'),
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cor do Papel de Parede',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Define a cor-base dos blobs animados no fundo.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: seedColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.wallpaperSeed,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Toque para alterar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _openColorPicker(context, ref),
                      child: const Text('Escolher'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Intensidade dos blobs
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Intensidade dos Blobs',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(settings.blobIntensity * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: settings.blobIntensity,
                  min: 0,
                  max: 0.7,
                  divisions: 14,
                  onChanged: notifier.updateBlobIntensity,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const _SectionHeader('Geral'),
          LiquidGlassCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: settings.darkMode,
                  onChanged: (_) => notifier.toggleDarkMode(),
                  title: const Text(
                    'Modo Escuro',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Mantém o Dark Mode ativo',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          const _SectionHeader('Timer de Foco'),
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cores do Ciclo Pomodoro',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Toque para personalizar o anel de cada modo.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                _ColorRow(
                  label: 'Foco',
                  color: settings.pomodoroFocusColor,
                  onTap: () => _openColorPickerForField(
                    context,
                    ref,
                    settings.pomodoroFocusColor,
                    notifier.updatePomodoroFocusColor,
                  ),
                ),
                const SizedBox(height: 12),
                _ColorRow(
                  label: 'Pausa Curta',
                  color: settings.pomodoroShortBreakColor,
                  onTap: () => _openColorPickerForField(
                    context,
                    ref,
                    settings.pomodoroShortBreakColor,
                    notifier.updatePomodoroShortBreakColor,
                  ),
                ),
                const SizedBox(height: 12),
                _ColorRow(
                  label: 'Pausa Longa',
                  color: settings.pomodoroLongBreakColor,
                  onTap: () => _openColorPickerForField(
                    context,
                    ref,
                    settings.pomodoroLongBreakColor,
                    notifier.updatePomodoroLongBreakColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reset
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await notifier.resetDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configurações restauradas'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.restart_alt, color: AppColors.textSecondary),
              label: const Text(
                'Restaurar padrões',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String color;
  final VoidCallback onTap;

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _hexToColor(color),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.tune, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PickerDialog extends StatefulWidget {
  const _PickerDialog({required this.initial});
  final Color initial;

  @override
  State<_PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<_PickerDialog> {
  late Color _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escolha uma cor',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // ColorPicker da flex_color_picker
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: ColorPicker(
                  color: _current,
                  onColorChanged: (c) => _current = c,
                  width: 38,
                  height: 38,
                  borderRadius: 19,
                  spacing: 4,
                  runSpacing: 4,
                  wheelDiameter: 160,
                  heading: Text(
                    'Selecione',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  subheading: Text(
                    'Cor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  wheelSubheading: Text(
                    'Tom',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  showMaterialName: false,
                  showColorName: false,
                  showColorCode: true,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyButton: false,
                    pasteButton: false,
                    longPressMenu: false,
                  ),
                  pickersEnabled: const {
                    ColorPickerType.wheel: true,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: false,
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _current),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
