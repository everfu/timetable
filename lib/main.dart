import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'screens/home_screen.dart';
import 'theme/app_design_tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimetableApp());
}

class TimetableApp extends StatelessWidget {
  const TimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '课表',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF772F91),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppTDColors.bgPage,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTDColors.bgPage,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTDColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: AppTDColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          ),
          color: AppTDColors.bgContainer,
        ),
        dividerTheme: DividerThemeData(
          color: AppTDColors.stroke,
          thickness: 0.5,
        ),
        extensions: [TDThemeData.defaultData()],
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF772F91),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTDColors.bgPageDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTDColors.bgPageDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTDColors.textPrimaryDark,
          ),
          iconTheme: IconThemeData(color: AppTDColors.textPrimaryDark),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          ),
          color: AppTDColors.bgContainerDark,
        ),
        dividerTheme: DividerThemeData(
          color: AppTDColors.strokeDark,
          thickness: 0.5,
        ),
        extensions: [TDThemeData.defaultData()],
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
