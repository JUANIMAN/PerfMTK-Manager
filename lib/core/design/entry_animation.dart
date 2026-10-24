import 'package:flutter/material.dart';

/// Mixin para animaciones de entrada
mixin EntryAnimationMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;

  void initEntryAnimation({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    animationController = AnimationController(
      duration: duration,
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: curve),
    );

    animationController.forward();
  }

  void disposeEntryAnimation() {
    animationController.dispose();
  }

  Widget buildWithEntryAnimation(Widget child) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) => FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          ),
        ),
      ),
    );
  }
}
