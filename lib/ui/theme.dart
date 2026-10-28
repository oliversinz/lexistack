import 'package:flutter/material.dart';

const paper = Color(0xFFF6F0E7);
const ink = Color(0xFF1B2433);
const cream = Color(0xFFFFFDF6);
const violet = Color(0xFF694BD6);
const coral = Color(0xFFF5826C);
const midnight = Color(0xFF151924);
const nightPaper = Color(0xFF242A3A);
const warmWhite = Color(0xFFF8F2E9);
const lilac = Color(0xFFB39BFF);
const tierColors = [
  Color(0xFFF1D582),
  Color(0xFFB8D6AA),
  Color(0xFFB9D3EF),
  Color(0xFFD9C4EB),
];
const tierInk = ink;

// Fraunces is reserved for these two editorial brand roles.
const wordmarkStyle = TextStyle(
  fontFamily: 'Fraunces',
  fontSize: 23,
  height: 1.12,
  fontWeight: FontWeight.w600,
  letterSpacing: -.8,
);
const homeHeroStyle = TextStyle(
  fontFamily: 'Fraunces',
  fontSize: 32,
  height: 1.12,
  fontWeight: FontWeight.w600,
  letterSpacing: -.8,
);

ThemeData lexistackTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final colors = ColorScheme(
    brightness: brightness,
    primary: dark ? lilac : violet,
    onPrimary: dark ? ink : cream,
    secondary: dark ? const Color(0xFFFF9D89) : coral,
    onSecondary: ink,
    error: dark ? const Color(0xFFFFB4AB) : const Color(0xFF9D3344),
    onError: dark ? ink : cream,
    surface: dark ? midnight : paper,
    onSurface: dark ? warmWhite : ink,
    onSurfaceVariant: dark ? const Color(0xFFD0CADB) : const Color(0xFF525466),
    surfaceContainerLowest: dark ? midnight : cream,
    surfaceContainerLow: dark ? nightPaper : cream,
    surfaceContainer: dark ? const Color(0xFF1D2230) : const Color(0xFFE9E1D4),
    surfaceContainerHigh: dark
        ? const Color(0xFF30374B)
        : const Color(0xFFEAE3F6),
    surfaceContainerHighest: dark ? nightPaper : cream,
    primaryContainer: dark ? const Color(0xFF35304C) : const Color(0xFFEAE3F6),
    onPrimaryContainer: dark ? warmWhite : ink,
    outline: dark ? const Color(0xFF9D96AF) : const Color(0xFF777183),
    outlineVariant: dark ? const Color(0xFF50576B) : const Color(0xFFD2C8B9),
  );
  final base = ThemeData(
    colorScheme: colors,
    useMaterial3: true,
    fontFamily: 'DM Sans',
  );
  TextStyle heading(double size) => TextStyle(
    fontFamily: 'DM Sans',
    fontSize: size,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -.8,
    color: colors.onSurface,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  return base.copyWith(
    scaffoldBackgroundColor: colors.surface,
    textTheme: base.textTheme.copyWith(
      displaySmall: heading(32),
      headlineMedium: heading(28),
      headlineSmall: heading(26),
      titleLarge: heading(22),
      titleMedium: base.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: base.textTheme.bodyMedium!.copyWith(height: 1.4),
      labelSmall: base.textTheme.labelSmall!.copyWith(
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      titleTextStyle: heading(23),
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: shape,
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        disabledBackgroundColor: colors.surfaceContainerHigh,
        disabledForegroundColor: colors.onSurfaceVariant,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: shape,
        foregroundColor: colors.onSurface,
        disabledForegroundColor: colors.onSurfaceVariant,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        disabledForegroundColor: colors.onSurfaceVariant,
        minimumSize: const Size(48, 48),
        shape: shape,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: shape,
    ),
    dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
  );
}

String counted(int count, String noun) =>
    '$count $noun${count == 1 ? '' : 's'}';
Duration motionDuration(BuildContext context, int milliseconds) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);
