import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';

/// Collapsible section card used throughout the PerfConfig screen.
///
/// Wraps an [ExpansionTile]-style card that matches the app's existing
/// visual design (surface colours, border, radius from [AppConstants]).
class SectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool initiallyExpanded;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _ctrl;
  late Animation<double> _iconTurn;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
      value: _expanded ? 1.0 : 0.0,
    );
    _iconTurn = Tween<double>(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing16,
                vertical: AppConstants.spacing14,
              ),
              child: Row(
                children: [
                  // Coloured icon badge
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: AppConstants.iconSizeMedium,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  // Animated chevron
                  RotationTransition(
                    turns: _iconTurn,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: cs.onSurfaceVariant,
                      size: AppConstants.iconSizeMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible body ──────────────────────────────────────────────
          AnimatedSize(
            duration: AppConstants.animationNormal,
            curve: Curves.easeOutCubic,
            child: _expanded
                ? FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Divider(
                          height: 1,
                          indent: AppConstants.spacing16,
                          endIndent: AppConstants.spacing16,
                          color:
                              widget.color.withValues(alpha: 0.2),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppConstants.spacing16,
                            AppConstants.spacing12,
                            AppConstants.spacing16,
                            AppConstants.spacing16,
                          ),
                          child: widget.child,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
