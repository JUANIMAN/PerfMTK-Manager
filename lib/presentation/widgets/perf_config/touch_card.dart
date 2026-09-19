import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Hardware Touch & Digitizer Booster card — Game Mode & 480Hz/2160Hz sample rate
class TouchCard extends StatelessWidget {
  final bool gameMode;
  final bool thpSmooth;
  final Color color;
  final void Function({
    required bool gameMode,
    required bool thpSmooth,
  }) onChanged;

  const TouchCard({
    super.key,
    required this.gameMode,
    required this.thpSmooth,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: AppLocale.touchBoosterTitle.getString(context),
      icon: Icons.touch_app_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Switch 1: Game Mode & 480Hz Report Rate ───────────────────────
          _buildSwitchRow(
            context: context,
            title: AppLocale.touchGameMode.getString(context),
            subtitle: AppLocale.touchGameModeDesc.getString(context),
            value: gameMode,
            onChanged: (v) => onChanged(
              gameMode: v,
              thpSmooth: thpSmooth,
            ),
          ),

          const SizedBox(height: AppConstants.spacing12),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.35)),
          const SizedBox(height: AppConstants.spacing12),

          // ── Switch 2: Host Processing (THP) Smoothing ─────────────────────
          _buildSwitchRow(
            context: context,
            title: AppLocale.touchThpSmooth.getString(context),
            subtitle: AppLocale.touchThpSmoothDesc.getString(context),
            value: thpSmooth,
            onChanged: (v) => onChanged(
              gameMode: gameMode,
              thpSmooth: v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: value ? color : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        Switch(
          value: value,
          activeThumbColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
