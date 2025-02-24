import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../localization/app_locales.dart';

class ProfileButton extends StatefulWidget {
  final String profile;
  final bool isSelected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ProfileButton({
    super.key,
    required this.profile,
    required this.isSelected,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ProfileButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      enabled: !widget.isSelected,
      selected: widget.isSelected,
      label: '${AppLocale.getValue(widget.profile).getString(context)} profile',
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
              child: GestureDetector(
                onTapDown: (_) => _handleTapDown(),
                onTapUp: (_) => _handleTapUp(),
                onTapCancel: _handleTapCancel,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getBorderColor(isFocused, theme),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.1),
                        blurRadius: widget.isSelected ? 8 : 4,
                        spreadRadius: widget.isSelected ? 2 : 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildContent(theme),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Stack(
      children: [
        if (widget.isSelected)
          Positioned.fill(
            child: _buildSelectedBackground(),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(theme),
                    const SizedBox(height: 4),
                    _buildDescription(theme),
                  ],
                ),
              ),
              _buildCheckmark(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedBackground() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(0.15 * _slideAnimation.value),
              widget.color.withOpacity(0.05 * _slideAnimation.value),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.icon,
        color: widget.color,
        size: 24,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      AppLocale.getValue(widget.profile).getString(context),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: widget.isSelected ? widget.color : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      _getProfileDescription(),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCheckmark() {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Icon(
          Icons.check_circle,
          color: widget.color,
          size: 24,
        ),
      ),
    );
  }

  Color _getBorderColor(bool isFocused, ThemeData theme) {
    if (widget.isSelected) return widget.color;
    if (isFocused) return theme.colorScheme.primary.withOpacity(0.5);
    return theme.colorScheme.onSurface.withOpacity(0.1);
  }

  String _getProfileDescription() {
    switch (widget.profile) {
      case 'performance':
        return AppLocale.performanceDsc.getString(context);
      case 'balanced':
        return AppLocale.balancedDsc.getString(context);
      case 'powersave':
        return AppLocale.powersaveDsc.getString(context);
      case 'powersave+':
        return AppLocale.powersavePlusDsc.getString(context);
      default:
        return '';
    }
  }

  void _handleTapDown() {
    if (!widget.isSelected) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp() {
    if (!widget.isSelected) {
      _controller.reverse();
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    if (!widget.isSelected) {
      _controller.reverse();
    }
  }
}