import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/routes/app_router.dart';
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
        ChangeNotifierProvider(create: (_) => SettingsProvider(dbHelper)),
        ChangeNotifierProxyProvider<SettingsProvider, ProductProvider>(
          create: (context) => ProductProvider(Provider.of<SettingsProvider>(context, listen: false)),
          update: (context, settingsProvider, productProvider) {
            productProvider?.update(settingsProvider);
            return productProvider!;
          },
        ),
        ChangeNotifierProxyProvider<ProductProvider, SalesProvider>(
          create: (context) => SalesProvider(Provider.of<ProductProvider>(context, listen: false)),
          update: (context, productProvider, salesProvider) {
            salesProvider?.update(productProvider);
            return salesProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => CouponProvider(dbHelper)),
        ChangeNotifierProxyProvider<SettingsProvider, DashboardProvider>(
          create: (context) => DashboardProvider(dbHelper, Provider.of<SettingsProvider>(context, listen: false)),
          update: (context, settingsProvider, dashboardProvider) {
            dashboardProvider?.update(settingsProvider);
            return dashboardProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => ReportsProvider(dbHelper)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Smart POS',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
