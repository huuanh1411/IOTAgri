import 'package:flutter/cupertino.dart';

enum ScreenSize { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.mobile;
    } else if (width < 1024) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    
    int crossAxisCount;
    double childAspectRatio;
    
    switch (screenSize) {
      case ScreenSize.mobile:
        crossAxisCount = 2;
        childAspectRatio = 1.0;
        break;
      case ScreenSize.tablet:
        crossAxisCount = 3;
        childAspectRatio = 1.2;
        break;
      case ScreenSize.desktop:
        crossAxisCount = 4;
        childAspectRatio = 1.3;
        break;
    }
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobilePadding;
  final double? tabletPadding;
  final double? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    
    double padding;
    switch (screenSize) {
      case ScreenSize.mobile:
        padding = mobilePadding ?? 16;
        break;
      case ScreenSize.tablet:
        padding = tabletPadding ?? 24;
        break;
      case ScreenSize.desktop:
        padding = desktopPadding ?? 32;
        break;
    }
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}