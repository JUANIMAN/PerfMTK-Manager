import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';

/// Card for configuring background daemon parameters (screen-off profile and debounce interval).
class DaemonSettingsCard extends StatefulWidget {
  final AppProfileState state;
  final VoidCallback onPickScreenOffProfile;
  final ValueChanged<int> onCommitDebounce;

  const DaemonSettingsCard({
    super.key,
    required this.state,
    required this.onPickScreenOffProfile,
    required this.onCommitDebounce,
  });

  @override
  State<DaemonSettingsCard> createState() => _DaemonSettingsCardState();
}

class _DaemonSettingsCardState extends State<DaemonSettingsCard> {
  int? _debounceDraftMs;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isConfigured = state.configExists;
    final cs = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        0,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHigh.withValues(alpha: 0.55)
              : cs.surfaceContainer.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.25),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IgnorePointer(
          ignoring: !isConfigured,
          child: AnimatedOpacity(
            duration: AppConstants.animationFast,
            opacity: isConfigured ? 1.0 : AppConstants.opacityDisabled,
            child: Column(
              children: [
                _buildScreenOffRow(context, state),
                Divider(
                  height: 1,
                  indent: AppConstants.spacing16,
                  endIndent: AppConstants.spacing16,
                  color: cs.outlineVariant.withValues(alpha: 0.20),
                ),
                _buildDebounceRow(context, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenOffRow(BuildContext context, AppProfileState state) {
    final cs = Theme.of(context).colorScheme;
    final color = ProfileUtils.colorFor(state.screenOffProfile);
    final icon = ProfileUtils.iconFor(state.screenOffProfile);

    return InkWell(
      onTap: state.configExists
          ? () {
              HapticFeedback.lightImpact();
              widget.onPickScreenOffProfile();
            }
          : null,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            Icon(
              Icons.bedtime_rounded,
              size: AppConstants.iconSizeMedium,
              color: cs.primary,
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.screenOffProfile.getString(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    AppLocale.screenOffProfileDesc.getString(context),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(
                    ProfileUtils.nameFor(context, state.screenOffProfile),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacing4),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
              size: AppConstants.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebounceRow(BuildContext context, AppProfileState state) {
    final cs = Theme.of(context).colorScheme;
    final debounce = _debounceDraftMs ?? state.appDebounceMs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing10,
        AppConstants.spacing16,
        AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: AppConstants.iconSizeMedium,
                color: cs.primary,
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.appDebounceMs.getString(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      AppLocale.appDebounceMsDesc.getString(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${debounce}ms',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: debounce.toDouble(),
              min: 500,
              max: 10000,
              divisions: 38,
              onChanged: (value) {
                final snapped = (value / 250).round() * 250;
                if (_debounceDraftMs != snapped) {
                  setState(() => _debounceDraftMs = snapped);
                }
              },
              onChangeEnd: (value) {
                HapticFeedback.selectionClick();
                final snapped = (value / 250).round() * 250;
                widget.onCommitDebounce(snapped);
              },
            ),
          ),
        ],
      ),
    );
  }
}
