import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension ScreenSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  double get widthPx => screenWidth;
  double get heightPx => screenHeight;

  bool get isTabletWidth => screenWidth >= 600;
  bool get isDesktopWidth => screenWidth >= 900;
  bool get isPhoneWidth => screenWidth < 600;

  double get responsivePadding {
    if (isDesktopWidth) return 32.0;
    if (isTabletWidth) return 24.0;
    return 16.0;
  }

  double get responsiveMargin {
    if (isDesktopWidth) return 48.0;
    if (isTabletWidth) return 32.0;
    return 16.0;
  }

  double get responsiveFontSize {
    if (isDesktopWidth) return 1.4;
    if (isTabletWidth) return 1.2;
    return 1.0;
  }

  /// Scales font size based on [responsiveFontSize]
  double sp(num size) => size * responsiveFontSize;

  /// Scales width based on a standard 375px design width
  double w(num size) => size * (screenWidth / 375);

  /// Scales height based on a standard 812px design height
  double h(num size) => size * (screenHeight / 812);

  /// Adaptive "responsive" size that scales based on screen width
  /// Perfect for icons, padding, and images.
  double r(num size) => size * (screenWidth / 375);

  double responsiveWidth(double fraction) => screenWidth * fraction;
  double responsiveHeight(double fraction) => screenHeight * fraction;
}

extension ResponsiveSizing on num {
  /// Responsive font size: [24.sp]
  double get sp {
    final context = Get.context;
    if (context == null) return toDouble();
    return context.sp(this);
  }

  /// Responsive width: [100.w]
  double get w {
    return this * (Get.width / 375);
  }

  /// Responsive height: [100.h]
  double get h {
    return this * (Get.height / 812);
  }

  /// Adaptive responsive size: [16.r]
  /// Scale factors are calculated based on screen width.
  double get r {
    return this * (Get.width / 375);
  }

  /// Creates a vertical [SizedBox] with this value as height
  Widget get verticalSpacer => SizedBox(height: h);

  /// Creates a horizontal [SizedBox] with this value as width
  Widget get horizontalSpacer => SizedBox(width: w);
}

class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;

  const ResponsiveWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}

class ScreenResponsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ScreenResponsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 900 && desktop != null) {
      return desktop!;
    } else if (width >= 600 && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;
  static const double fabSize = 56.0;

  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return paddingL;
    if (width >= 600) return paddingM;
    return paddingS;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return baseSize * 1.3;
    if (width >= 600) return baseSize * 1.1;
    return baseSize;
  }
}
