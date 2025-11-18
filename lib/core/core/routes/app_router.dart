// lib/core/routes/app_router.dart - Updated with new routes

import 'package:flutter/material.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String productsRoute = '/products';
  static const String posRoute = '/pos';
  static const String customersRoute = '/customers';
  static const String settingsRoute = '/settings';
  static const String categoriesRoute = '/categories';
  static const String couponsRoute = '/coupons';
  static const String dashboardRoute = '/dashboard';
  static const String reportsRoute = '/reports';
  static const String receiptRoute = '/receipt';

  static Map<String, WidgetBuilder> get routes => {
    loginRoute: (context) => const LoginPage(),
    homeRoute: (context) => const HomePage(),
    productsRoute: (context) => const ProductsPage(),
    posRoute: (context) => const POSPage(),
    customersRoute: (context) => const CustomersPage(),
    settingsRoute: (context) => const SettingsPage(),
    categoriesRoute: (context) => const CategoriesPage(),
    dashboardRoute: (context) => const DashboardPage(),
    reportsRoute: (context) => const ReportsPage(),
  };

  static Future<void> navigateTo(BuildContext context, String routeName) {
    return Navigator.pushNamed(context, routeName);
  }

  static Future<void> navigateToAndReplace(BuildContext context, String routeName) {
    return Navigator.pushReplacementNamed(context, routeName);
  }

  static Future<void> navigateToAndRemoveUntil(BuildContext context, String routeName) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
    );
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
}

// ============================================================================
// NAVIGATION HELPER - Use this in your main navigation shell/homepage
// ============================================================================

class NavigationHelper {
  static List<NavigationDestination> getNavigationDestinations({
    required bool isAdmin,
  }) {
    return [
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      const NavigationDestination(
        icon: Icon(Icons.inventory),
        label: 'Products',
      ),
      const NavigationDestination(
        icon: Icon(Icons.point_of_sale),
        label: 'POS',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people),
        label: 'Customers',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.analytics),
          label: 'Reports',
        ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
    ];
  }

  static String getRouteForIndex({
    required int index,
    required bool isAdmin,
  }) {
    if (isAdmin) {
      // Admin routes: Dashboard, Products, POS, Customers, Reports, Settings
      switch (index) {
        case 0:
          return AppRouter.dashboardRoute;
        case 1:
          return AppRouter.productsRoute;
        case 2:
          return AppRouter.posRoute;
        case 3:
          return AppRouter.customersRoute;
        case 4:
          return AppRouter.reportsRoute;
        case 5:
          return AppRouter.settingsRoute;
        default:
          return AppRouter.dashboardRoute;
      }
    } else {
      // Cashier routes: Products, POS, Customers (no Dashboard, Reports, Settings)
      switch (index) {
        case 0:
          return AppRouter.productsRoute;
        case 1:
          return AppRouter.posRoute;
        case 2:
          return AppRouter.customersRoute;
        default:
          return AppRouter.productsRoute;
      }
    }
  }
}
