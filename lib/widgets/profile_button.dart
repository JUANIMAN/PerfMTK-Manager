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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isSelected ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocale.getValue(profile).getString(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? color : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getProfileDescription(context, profile),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }

  String _getProfileDescription(BuildContext context, String profile) {
    switch (profile) {
      case 'performance':
        return AppLocale.performanceDsc.getString(context);
      case 'balanced':
        return AppLocale.balancedDsc.getString(context);
      case 'powersave':
        return AppLocale.powersaveDsc.getString(context);
      default:
        return '';
    }
  }
}
