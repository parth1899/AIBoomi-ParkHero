import 'package:flutter/material.dart';

class AppColors {
  // iOS system colors (default light)
  static const red = Color.fromARGB(255, 255, 56, 60);
  static const orange = Color.fromARGB(255, 255, 141, 40);
  static const yellow = Color.fromARGB(255, 255, 204, 0);
  static const green = Color.fromARGB(255, 52, 199, 89);
  static const mint = Color.fromARGB(255, 0, 200, 179);
  static const teal = Color.fromARGB(255, 0, 195, 208);
  static const cyan = Color.fromARGB(255, 0, 192, 232);
  static const blue = Color.fromARGB(255, 0, 136, 255);
  static const indigo = Color.fromARGB(255, 97, 85, 245);
  static const purple = Color.fromARGB(255, 203, 48, 224);
  static const pink = Color.fromARGB(255, 255, 45, 85);
  static const brown = Color.fromARGB(255, 172, 127, 94);

  // iOS system grays (default light)
  static const systemGray = Color.fromARGB(255, 142, 142, 147);
  static const systemGray2 = Color.fromARGB(255, 174, 174, 178);
  static const systemGray3 = Color.fromARGB(255, 199, 199, 204);
  static const systemGray4 = Color.fromARGB(255, 209, 209, 214);
  static const systemGray5 = Color.fromARGB(255, 229, 229, 234);
  static const systemGray6 = Color.fromARGB(255, 242, 242, 247);

  static const primary = blue;
  static const background = systemGray6;
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0B0F1A);
  static const textSecondary = systemGray;
  static const divider = systemGray5;
  static const success = green;
  static const warning = orange;
  static const danger = red;
  static const mapOverlay = Color(0xB3FFFFFF);
}

class AppSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const xxl = 36.0;
}

class AppRadii {
  static const sm = 14.0;
  static const md = 20.0;
  static const lg = 28.0;
  static const xl = 34.0;
}

class AppTextStyles {
  static const headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'SF Pro',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.teal,
      surface: AppColors.card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.textPrimary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary.withOpacity(0.12),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
  );
}
