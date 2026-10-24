import 'package:flutter/material.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/core/design/design.dart';

class SheetProfileData {
  final ProfileType? profileType;
  final String name;
  final String description;
  const SheetProfileData({
    required this.profileType,
    required this.name,
    required this.description,
  });
}

// ── Animated slide-in for each sheet item ─────────────────────────────────────
class AnimatedSheetItem extends StatefulWidget {
  final Widget child;
  final int index;
  const AnimatedSheetItem({super.key, required this.child, required this.index});
  @override
  State<AnimatedSheetItem> createState() => AnimatedSheetItemState();
}

class AnimatedSheetItemState extends State<AnimatedSheetItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 35 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
