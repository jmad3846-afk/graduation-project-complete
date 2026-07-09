import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1000;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1000) {
      return desktop;
    } else if (width >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? drawer;
  final Color? backgroundColor;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar as PreferredSizeWidget?,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer != null ? _buildDrawer(context, drawer!) : null,
    );
  }

  Widget? _buildDrawer(BuildContext context, List<Widget> drawerItems) {
    if (ResponsiveLayout.isDesktop(context)) {
      return null; // No drawer on desktop
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'EMS Op Room',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'نظام إدارة غرفة عمليات الإسعاف',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ...drawerItems,
        ],
      ),
    );
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final Decoration? decoration;
  final BoxConstraints? constraints;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.width,
    this.height,
    this.alignment,
    this.decoration,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : isTablet ? 24 : 32,
            vertical: isMobile ? 12 : isTablet ? 16 : 20,
          ),
      margin: margin,
      width: width,
      height: height,
      alignment: alignment,
      decoration: decoration ??
          BoxDecoration(
            color: color ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: isMobile ? 4 : 6,
                offset: Offset(0, isMobile ? 2 : 3),
              ),
            ],
          ),
      constraints: constraints ??
          BoxConstraints(
            minHeight: isMobile ? 60 : 80,
            minWidth: isMobile ? double.infinity : 300,
          ),
      child: child,
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double mobileAspectRatio;
  final double tabletAspectRatio;
  final double desktopAspectRatio;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.mobileAspectRatio = 1.0,
    this.tabletAspectRatio = 1.5,
    this.desktopAspectRatio = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        double aspectRatio;

        if (isMobile) {
          crossAxisCount = 1;
          aspectRatio = mobileAspectRatio;
        } else if (isTablet) {
          crossAxisCount = width > 800 ? 2 : 1;
          aspectRatio = tabletAspectRatio;
        } else {
          crossAxisCount = width > 1400 ? 4 : width > 1000 ? 3 : 2;
          aspectRatio = desktopAspectRatio;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Text(
      text,
      style: style?.copyWith(
        fontSize: isMobile
            ? (style?.fontSize ?? 16) * 0.9
            : isTablet
                ? (style?.fontSize ?? 16) * 1.0
                : (style?.fontSize ?? 16) * 1.1,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}