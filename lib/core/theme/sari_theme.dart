import 'package:flutter/material.dart';

class SariColors {
  static const Color cream = Color(0xFFFFFAF2);
  static const Color creamDark = Color(0xFFF5EDE0);
  static const Color card = Colors.white;
  static const Color ink = Color(0xFF2B1D14);
  static const Color inkLight = Color(0xFF443427);
  static const Color muted = Color(0xFF6F6258);
  static const Color border = Color(0xFFF0E6DA);

  // Brand Accents
  static const Color orange = Color(0xFFF26B1D);
  static const Color orangeDark = Color(0xFFC9480F);
  static const Color orangeSoft = Color(0xFFFFE9DC);

  // Status & Financial
  static const Color green = Color(0xFF23863F);
  static const Color greenSoft = Color(0xFFE3F5E9);
  static const Color red = Color(0xFFD93A40);
  static const Color redSoft = Color(0xFFFFE4E1);
  static const Color yellow = Color(0xFFD97706);
  static const Color yellowSoft = Color(0xFFFFF4D6);
}

class SariFonts {
  static const String inter = 'Inter';
  static const String plusJakartaSans = 'Plus Jakarta Sans';
  static const String nunito = 'Nunito';
}

class SariTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SariColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SariColors.orange,
        primary: SariColors.orange,
        secondary: SariColors.green,
        error: SariColors.red,
        surface: SariColors.cream,
      ),
      fontFamily: SariFonts.inter,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: SariFonts.nunito, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(fontFamily: SariFonts.plusJakartaSans, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontFamily: SariFonts.plusJakartaSans, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(fontFamily: SariFonts.plusJakartaSans, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontFamily: SariFonts.plusJakartaSans, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontFamily: SariFonts.plusJakartaSans, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontFamily: SariFonts.plusJakartaSans, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: SariFonts.inter, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontFamily: SariFonts.inter, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontFamily: SariFonts.inter, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(fontFamily: SariFonts.inter, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontFamily: SariFonts.inter, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontFamily: SariFonts.inter, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SariColors.cream,
        foregroundColor: SariColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: SariFonts.plusJakartaSans,
          color: SariColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: SariColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SariColors.border, width: 1),
        ),
        shadowColor: const Color(0x1478481E),
      ),
      dividerTheme: const DividerThemeData(
        color: SariColors.border,
        thickness: 1,
      ),
    );
  }

  static TextStyle heading({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w800,
    Color color = SariColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: SariFonts.plusJakartaSans,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = SariColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: SariFonts.inter,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle money({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w800,
    Color color = SariColors.ink,
  }) {
    return TextStyle(
      fontFamily: SariFonts.plusJakartaSans,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle wordmark({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w900,
    Color color = SariColors.orange,
  }) {
    return TextStyle(
      fontFamily: SariFonts.nunito,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = 20,
    Border? border,
    bool shadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: SariColors.border, width: 1),
      boxShadow: shadow
          ? [
              const BoxShadow(
                color: Color(0x1478481E),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}

enum SariPose {
  idle,
  face,
  listening,
  thinking,
  success,
  confused,
  scanning,
  offline,
  welcome,
  insights,
  empty,
}

class SariMascot extends StatelessWidget {
  final SariPose pose;
  final double size;
  final BoxFit fit;

  const SariMascot({
    super.key,
    required this.pose,
    this.size = 48,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/sari/${pose.name}.png',
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.storefront_rounded,
        size: size,
        color: SariColors.orange,
      ),
    );
  }
}

/// Pill rounded button matching Figma .pill-button
class SariPillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isGhost;
  final bool isDanger;
  final IconData? icon;
  final double? width;
  final EdgeInsetsGeometry padding;

  const SariPillButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isSecondary = false,
    this.isGhost = false,
    this.isDanger = false,
    this.icon,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    Color bg = SariColors.orange;
    Color fg = Colors.white;
    Border? border;

    if (isDanger) {
      bg = SariColors.red;
      fg = Colors.white;
    } else if (isSecondary) {
      bg = SariColors.orangeSoft;
      fg = SariColors.orangeDark;
    } else if (isGhost) {
      bg = Colors.transparent;
      fg = SariColors.muted;
      border = Border.all(color: SariColors.border);
    }

    if (onPressed == null) {
      bg = bg.withValues(alpha: 0.5);
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        DefaultTextStyle(
          style: TextStyle(
            color: fg,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          child: child,
        ),
      ],
    );

    return SizedBox(
      width: width,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: border,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

/// Filter chip matching Figma .chip
class SariFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? leading;

  const SariFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SariColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? SariColors.orange : SariColors.border,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: SariColors.orange.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : SariColors.ink,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String tagalogDateEyebrow(DateTime date) {
  const days = ['LINGGO', 'LUNES', 'MARTES', 'MIYERKULES', 'HUWEBES', 'BIYERNES', 'SABADO'];
  const months = [
    'ENERO', 'PEBRERO', 'MARSO', 'ABRIL', 'MAYO', 'HUNYO',
    'HULYO', 'AGOSTO', 'SETYEMBRE', 'OKTUBRE', 'NOBYEMBRE', 'DISYEMBRE'
  ];
  final dayName = days[date.weekday % 7];
  final monthName = months[date.month - 1];
  return '$dayName, $monthName ${date.day}';
}

String tagalogGreeting(DateTime date) {
  final hour = date.hour;
  if (hour < 12) return 'Magandang umaga';
  if (hour < 18) return 'Magandang hapon';
  return 'Magandang gabi';
}

