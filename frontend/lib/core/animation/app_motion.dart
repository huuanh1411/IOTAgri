import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration toggle = Duration(milliseconds: 180);
  static const Duration tabSwitch = Duration(milliseconds: 220);
  static const Duration navigationIndicator = Duration(milliseconds: 240);
  static const Duration status = Duration(milliseconds: 240);
  static const Duration detailOpen = Duration(milliseconds: 280);
  static const Duration cardEntrance = Duration(milliseconds: 300);
  static const Duration chart = Duration(milliseconds: 400);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  static Duration duration(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

  static Duration cardDelay(int index) =>
      Duration(milliseconds: index.clamp(0, 7) * 40);

  static PageRoute<T> detailRoute<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    final transitionDuration = duration(context, detailOpen);
    return PageRouteBuilder<T>(
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: easeOut);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.045, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class AppMotionEntrance extends StatefulWidget {
  const AppMotionEntrance({required this.child, this.index = 0, super.key});

  final Widget child;
  final int index;

  @override
  State<AppMotionEntrance> createState() => _AppMotionEntranceState();
}

class _AppMotionEntranceState extends State<AppMotionEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final delay = AppMotion.cardDelay(widget.index);
    final total = delay + AppMotion.cardEntrance;
    _controller = AnimationController(vsync: this, duration: total);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.easeOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    child: widget.child,
    builder: (context, child) => FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(_animation),
        child: child,
      ),
    ),
  );
}

class AppMotionTabTransition extends StatefulWidget {
  const AppMotionTabTransition({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  @override
  State<AppMotionTabTransition> createState() => _AppMotionTabTransitionState();
}

class _AppMotionTabTransitionState extends State<AppMotionTabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 1);
    _animation = CurvedAnimation(parent: _controller, curve: AppMotion.easeOut);
  }

  @override
  void didUpdateWidget(covariant AppMotionTabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller
      ..duration = AppMotion.tabSwitch
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    child: widget.child,
    builder: (context, child) => FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0),
          end: Offset.zero,
        ).animate(_animation),
        child: child,
      ),
    ),
  );
}
