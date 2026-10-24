import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/app_services_providers.dart';

/// Renders an app icon either from memory, cache, or lazily on demand.
class AppIconImage extends ConsumerStatefulWidget {
  final String packageName;
  final Uint8List? initialIcon;
  final double size;

  const AppIconImage({
    super.key,
    required this.packageName,
    this.initialIcon,
    this.size = 44,
  });

  @override
  ConsumerState<AppIconImage> createState() => _AppIconImageState();
}

class _AppIconImageState extends ConsumerState<AppIconImage> {
  Uint8List? _iconBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _resolveIcon();
  }

  @override
  void didUpdateWidget(AppIconImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _isLoading = false;
      _resolveIcon();
    }
  }

  void _resolveIcon() {
    final pkg = widget.packageName;
    _iconBytes =
        widget.initialIcon ??
        ref.read(appIconCacheProvider).getCached(pkg);
    if (_iconBytes == null && !_isLoading) {
      _isLoading = true;
      ref.read(appIconCacheProvider).loadIcon(pkg).then((bytes) {
        if (mounted && widget.packageName == pkg) {
          setState(() {
            _iconBytes = bytes;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconBytes;
    if (icon != null) {
      return Image.memory(
        icon,
        width: widget.size,
        height: widget.size,
        cacheWidth: 72,
        cacheHeight: 72,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Icon(
        Icons.android_rounded,
        size: widget.size * 0.65,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
      ),
    );
  }
}
