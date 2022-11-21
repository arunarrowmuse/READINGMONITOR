import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'constants.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Constants.primaryColor,
        ).copyWith(secondary: Constants.primaryColor),
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark)
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
