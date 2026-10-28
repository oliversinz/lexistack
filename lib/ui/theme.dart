import 'package:flutter/material.dart';

const tierColors = [
  Color(0xFFF1D582),
  Color(0xFFB8D6AA),
  Color(0xFFB9D3EF),
  Color(0xFFD9C4EB),
];
const tierInk = Color(0xFF202B25);

ThemeData lexistackTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final colors = ColorScheme.fromSeed(
    seedColor: const Color(0xFF315747),
    brightness: brightness,
    surface: dark ? const Color(0xFF171E1B) : const Color(0xFFFAF8F1),
    primary: dark ? const Color(0xFFB0D6BF) : const Color(0xFF315747),
    onPrimary: dark ? const Color(0xFF173B2B) : Colors.white,
  );
  final base = ThemeData(colorScheme: colors, useMaterial3: true);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  return base.copyWith(
    scaffoldBackgroundColor: colors.surface,
    // Offline SDK typography. No font dependency or runtime download.
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      headlineSmall: base.textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -.5,
      ),
      titleMedium: base.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
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
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: shape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: shape,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
  );
}

String counted(int count, String noun) =>
    '$count $noun${count == 1 ? '' : 's'}';

Duration motionDuration(BuildContext context, int milliseconds) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);
