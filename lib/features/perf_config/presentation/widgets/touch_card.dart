import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

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
      title: context.l10n.touchBoosterTitle,
      icon: Icons.touch_app_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Switch 1: Game Mode & 480Hz Report Rate ───────────────────────
          _buildSwitchRow(
            context: context,
            title: context.l10n.touchGameMode,
            subtitle: context.l10n.touchGameModeDesc,
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
            title: context.l10n.touchThpSmooth,
            subtitle: context.l10n.touchThpSmoothDesc,
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
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onChanged(v);
          },
        ),
      ],
    );
  }
}
