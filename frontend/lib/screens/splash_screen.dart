import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../providers/auth_controller.dart';

/// The one-time cold-start handoff to the existing auth-aware router guard.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _logoAsset = 'assets/images/aerogreen_splash_logo.png';
  static const _animationDuration = Duration(milliseconds: 1500);
  static const _authTimeout = Duration(seconds: 5);

  late final AnimationController _controller;
  late final Animation<double> _reveal;
  bool _prepared = false;
  bool _animationFinished = false;
  bool _authReadyOrTimedOut = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: _animationDuration,
          animationBehavior: AnimationBehavior.normal,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _animationFinished = true;
            _tryNavigate();
          }
        });
    _reveal = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Creating this provider starts the existing persisted-auth check in parallel.
    ref.read(authControllerProvider);
    unawaited(
      Future<void>.delayed(_authTimeout).then((_) {
        if (!mounted) return;
        _authReadyOrTimedOut = true;
        _tryNavigate();
      }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    _precacheAndStart(MediaQuery.disableAnimationsOf(context));
  }

  Future<void> _precacheAndStart(bool disableAnimations) async {
    final image = const AssetImage(_logoAsset);
    final precache = precacheImage(image, context).catchError((_) {});

    if (disableAnimations) {
      _controller.value = 1;
      _animationFinished = true;
      _tryNavigate();
      return;
    }

    // Asset failure is rendered by Image.errorBuilder; do not let it block startup.
    await precache.timeout(const Duration(seconds: 2), onTimeout: () {});
    if (!mounted) return;
    await _controller.forward();
  }

  void _tryNavigate() {
    if (!mounted ||
        _hasNavigated ||
        !_animationFinished ||
        !_authReadyOrTimedOut) {
      return;
    }
    _hasNavigated = true;
    // `go` replaces this one-time route. The existing redirect then chooses auth/home.
    context.go('/auth');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    if (!authState.isInitializing && !_authReadyOrTimedOut) {
      _authReadyOrTimedOut = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigate());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _reveal,
            child: const _SplashLogo(asset: _logoAsset),
            builder: (context, child) =>
                _RevealLogo(progress: _reveal.value, child: child!),
          ),
        ),
      ),
    );
  }
}

class _RevealLogo extends StatelessWidget {
  const _RevealLogo({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final revealEnd = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              AppColors.forestGreen.withValues(alpha: 0.16),
              BlendMode.srcIn,
            ),
            child: child,
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: const [
                AppColors.forestGreen,
                AppColors.forestGreen,
                Colors.transparent,
                Colors.transparent,
              ],
              stops: [0, revealEnd, revealEnd, 1],
            ).createShader(bounds),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Text(
          'Aerogreen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
