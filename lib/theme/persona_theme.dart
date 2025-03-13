import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme class containing Persona 5 styling constants
class PersonaTheme {
  /// Primary red color used throughout Persona 5 UI
  static const Color primaryRed = Color(0xFFFF0000);
  
  /// Secondary black color
  static const Color secondaryBlack = Color(0xFF0D0D0D);
  
  /// Accent gold color
  static const Color accentGold = Color(0xFFFFD700);
  
  /// Background dark color
  static const Color backgroundDark = Color(0xFF0A0A0A);
  
  /// Primary background color
  static const Color primaryBackground = Color(0xFF0a0a0a);
  
  /// Text colors
  static const Color textWhite = Color(0xFFE8E8E8);
  static const Color textGrey = Color(0xFFA0A0A0);
  
  /// Card gradients for Persona 5 style cards
  static List<Color> cardGradient = [
    cardColor,
    primaryRed.withOpacity(0.2),
  ];
  
  /// Shadow for Persona styled elements
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryRed.withOpacity(0.2),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];
  
  /// Card shadows for Persona styled cards
  static List<BoxShadow> cardShadows = [
    BoxShadow(
      color: primaryRed.withOpacity(0.2),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];
  
  /// Border for Persona styled cards
  static Border cardBorder = Border.all(
    color: primaryRed.withOpacity(0.6),
    width: 1,
  );
  
  /// Radius for Persona styled cards
  static BorderRadius cardRadius = const BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(4),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(12),
  );
  
  /// Main menu gradient
  static LinearGradient mainMenuGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryRed,
      primaryRed.withOpacity(0.7),
      Colors.black,
    ],
  );
  
  /// Text shadows for headings
  static List<Shadow> textShadows = [
    Shadow(
      color: primaryRed.withOpacity(0.7),
      blurRadius: 5,
      offset: const Offset(1, 1),
    ),
  ];
  
  /// Section header style
  static TextStyle sectionHeaderStyle = GoogleFonts.rajdhani(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
      letterSpacing: 2,
    ),
  );
  
  /// Subtitle style
  static TextStyle subtitleStyle = const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );
  
  /// Text styles
  static TextStyle headingStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: textWhite,
  );
  
  static TextStyle subheadingStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: textWhite,
  );
  
  static TextStyle bodyStyle = const TextStyle(
    fontSize: 14,
    color: textWhite,
    letterSpacing: 0.5,
  );
  
  static TextStyle amountStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    color: primaryRed,
  );
  
  /// Create a persona-styled text shadow
  static List<Shadow> textShadow = [
    Shadow(
      color: primaryRed.withOpacity(0.7),
      blurRadius: 5,
      offset: const Offset(1, 1),
    ),
  ];

  static const darkRed = Color(0xFF8B0000);
  static const backgroundColor = Color(0xFF0A0A0A);
  static const cardColor = Color(0xFF1A1A1A);
  static const accentColor = Color(0xFFFFD700);
  
  // Text styles
  static final heading = GoogleFonts.rajdhani(
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 2,
    ),
  );
  
  static final subHeading = GoogleFonts.rajdhani(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
      letterSpacing: 1.5,
    ),
  );
  
  static final bodyText = GoogleFonts.rajdhani(
    textStyle: const TextStyle(
      fontSize: 16,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: accentGold,
        surface: cardColor,
        background: backgroundDark,
        error: Color(0xFFCF6679),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.rajdhani(
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textWhite,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(
          color: primaryRed,
        ),
      ),
      textTheme: textTheme,
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: buttonTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          textStyle: GoogleFonts.rajdhani(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: primaryRed, width: 1),
        ),
        titleTextStyle: GoogleFonts.rajdhani(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        contentTextStyle: GoogleFonts.rajdhani(
          textStyle: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: GoogleFonts.rajdhani(
          textStyle: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primaryRed, width: 1),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
  
  static final buttonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return darkRed;
        }
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade800;
        }
        return primaryRed;
      }),
      foregroundColor: MaterialStateProperty.all(textWhite),
      shape: MaterialStateProperty.all(
        const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ),
          side: BorderSide(color: textWhite, width: 1),
        ),
      ),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return 2;
        }
        if (states.contains(MaterialState.hovered)) {
          return 12;
        }
        return 8;
      }),
      shadowColor: MaterialStateProperty.all(primaryRed.withOpacity(0.6)),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return textWhite.withOpacity(0.1);
        }
        if (states.contains(MaterialState.hovered)) {
          return primaryRed.withOpacity(0.2);
        }
        return Colors.transparent;
      }),
      textStyle: MaterialStateProperty.all(
        GoogleFonts.rajdhani(
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    ),
  );

  /// Floating Action Button theme
  static final floatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: primaryRed,
    foregroundColor: textWhite,
    elevation: 8,
    splashColor: darkRed,
    shape: const BeveledRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
      side: BorderSide(color: textWhite, width: 1),
    ),
  );

  static final textTheme = TextTheme(
    displayLarge: GoogleFonts.rajdhani(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 2,
    ),
    displayMedium: GoogleFonts.rajdhani(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.5,
    ),
    displaySmall: GoogleFonts.rajdhani(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1.2,
    ),
    headlineMedium: GoogleFonts.rajdhani(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1,
    ),
    bodyLarge: GoogleFonts.rajdhani(
      fontSize: 16,
      color: Colors.white,
      letterSpacing: 1,
    ),
    bodyMedium: GoogleFonts.rajdhani(
      fontSize: 14,
      color: Colors.white70,
      letterSpacing: 0.5,
    ),
    labelLarge: GoogleFonts.rajdhani(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1,
    ),
  );

  static final inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.black87,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryRed, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryRed, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryRed.withOpacity(0.8), width: 3),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade800, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade800, width: 3),
    ),
    labelStyle: GoogleFonts.rajdhani(
      color: Colors.white70,
      fontSize: 16,
      letterSpacing: 1,
    ),
    hintStyle: GoogleFonts.rajdhani(
      color: Colors.white38,
      fontSize: 16,
      letterSpacing: 1,
    ),
    errorStyle: GoogleFonts.rajdhani(
      color: Colors.red.shade300,
      fontSize: 14,
      letterSpacing: 0.5,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static BoxDecoration getGlowingDecoration({
    Color color = primaryRed,
    double spreadRadius = 2,
    double blurRadius = 8,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: Colors.black87,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: color, width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          spreadRadius: spreadRadius,
          blurRadius: blurRadius,
        ),
      ],
    );
  }
  
  static BoxDecoration getAngularDecoration({
    Color color = primaryRed,
    double opacity = 0.3,
  }) {
    return BoxDecoration(
      color: Colors.black87,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(4),
      ),
      border: Border.all(color: color, width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
          spreadRadius: 1,
          blurRadius: 6,
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.15),
          Colors.black87,
        ],
      ),
    );
  }
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Animation curves
  static const Curve defaultCurve = Curves.easeOutQuart;
  static const Curve bouncyCurve = Curves.easeOutBack;
} 