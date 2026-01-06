import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomAboutDialog extends StatefulWidget {
  const CustomAboutDialog({super.key});

  @override
  State<CustomAboutDialog> createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog>
    with SingleTickerProviderStateMixin, EntryAnimationMixin {
  late String version = '';

  @override
  void initState() {
    super.initState();
    _getInfo();
    initEntryAnimation(duration: AppConstants.animationSlow);
  }

  @override
  void dispose() {
    disposeEntryAnimation();
    super.dispose();
  }

  Future<void> _getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF056FD9);

    return buildWithEntryAnimation(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        ),
        elevation: AppConstants.elevationLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isDarkMode, primaryColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing24,
                AppConstants.spacing24,
                AppConstants.spacing24,
                AppConstants.spacing16,
              ),
              child: Column(
                children: [
                  Text(
                    AppLocale.aboutDescription.getString(context),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  _buildInfoRow(
                    context,
                    Icons.memory,
                    AppLocale.compDevices.getString(context),
                    'MediaTek™',
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  _buildInfoRow(
                    context,
                    Icons.developer_mode,
                    AppLocale.developer.getString(context),
                    'JUANIMAN',
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing24,
                AppConstants.spacing16,
                AppConstants.spacing24,
                AppConstants.spacing24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(
                    context,
                    'GitHub',
                    Icons.code,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      launchUrlString('https://github.com/JUANIMAN/PerfMTK-Manager');
                    },
                  ),
                  _buildSocialButton(
                    context,
                    'Telegram',
                    Icons.telegram,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      launchUrlString('https://t.me/RePerfMTK');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.border,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAppIcon(),
          const SizedBox(height: AppConstants.spacing20),
          Text(
            'PerfMTK Manager',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacing6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.border,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Text(
              'Versión $version',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing4),
      decoration: BoxDecoration(
        color: Colors.white.border,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icon/icon.png',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        IconContainer(
          icon: icon,
          color: Theme.of(context).colorScheme.primary,
          size: AppConstants.spacing12,
          iconSize: AppConstants.iconSizeMedium,
        ),
        const SizedBox(width: AppConstants.spacing16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      BuildContext context,
      String label,
      IconData icon, {
        required VoidCallback onTap,
      }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing20,
            vertical: AppConstants.spacing12,
          ),
          decoration: BoxDecoration(
            color: primaryColor.light,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            border: Border.all(
              color: primaryColor.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppConstants.iconSizeSmall,
                color: primaryColor,
              ),
              const SizedBox(width: AppConstants.spacing12),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}