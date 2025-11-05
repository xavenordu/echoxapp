import 'package:flutter/material.dart';

class AnimatedGlitch extends StatefulWidget {
  final Widget child;
  const AnimatedGlitch({super.key, required this.child});

  @override
  _AnimatedGlitchState createState() => _AnimatedGlitchState();
}

class _AnimatedGlitchState extends State<AnimatedGlitch> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = (_ctrl.value * 2.0) - 1.0;
        return Transform.translate(
          offset: Offset(2 * t.abs(), 0),
          child: Opacity(
            opacity: 0.95 + 0.05 * (t.abs()),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
