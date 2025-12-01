import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/constants/app_colors.dart';
import 'core/core/routes/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/sales/presentation/providers/sales_provider.dart';
import 'features/categories/presentation/providers/category_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/coupons/presentation/providers/coupon_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Platform.isAndroid) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({required this.dbHelper, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProxyProvider<ProductProvider, SalesProvider>(
          create: (context) => SalesProvider(Provider.of<ProductProvider>(context, listen: false)),
          update: (context, productProvider, salesProvider) =>
              salesProvider ?? SalesProvider(productProvider),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => CouponProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => ReportsProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(dbHelper)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SmartPOS',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
            routes: AppRouter.routes,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Use the 'currentUser' API (may be synchronous or a Future) instead of calling a possibly removed getCurrentUser()
    dynamic userOrFuture = authProvider.currentUser;
    dynamic user;
    if (userOrFuture is Future) {
      user = await userOrFuture;
    } else {
      user = userOrFuture;
    }

    if (mounted) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'SmartPOS',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Professional Point of Sale System'),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
