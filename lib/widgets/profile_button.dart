import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';

class ProfileButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: isSelected ? null : onTap,
      splashColor: color.withOpacity(0.1),
      highlightColor: color.withOpacity(0.05),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: _buildDecoration(theme),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildContent(context, theme),
      ),
    );
  }

  BoxDecoration _buildDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color:
            isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? color.withOpacity(0.1)
              : theme.colorScheme.onSurface.withOpacity(0.05),
          blurRadius: isSelected ? 15 : 10,
          spreadRadius: isSelected ? 10 : 1,
          offset: const Offset(0, 3),
        )
      ],
      gradient: isSelected
          ? LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildIconContainer(),
        const SizedBox(width: 16),
        Expanded(
          child: _buildProfileDetails(context, theme),
        ),
        _buildSelectionIndicator(theme),
      ],
    );
  }

  Widget _buildIconContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocale.getValue(profile).getString(context),
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected ? color : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getProfileDescription(context, profile),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionIndicator(ThemeData theme) {
    return isSelected
        ? Icon(
            Icons.check_circle_rounded,
            color: color,
            key: UniqueKey(),
          )
        : const SizedBox.shrink();
  }

  String _getProfileDescription(BuildContext context, String profile) {
    switch (profile) {
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
}
