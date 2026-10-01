import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  await NotificationService.instance.init();

  runApp(const DebtTrackerApp());
}

class DebtTrackerApp extends StatelessWidget {
  const DebtTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DebtProvider>(
          create: (_) => DebtProvider(),
          update: (_, auth, debtProvider) =>
              debtProvider!..updateUser(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, auth, expenseProvider) =>
              expenseProvider!..updateUser(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'Catatan Hutang',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        locale: const Locale('id', 'ID'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
