import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/sales/presentation/pages/pos_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../widgets/main_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;

      if (!isLoggedIn && state.uri.path != '/login') {
        return '/login';
      }

      if (isLoggedIn && state.uri.path == '/login') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(
          title: _getTitleFromPath(state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const POSPage(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsPage(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
        ],
      ),
    ],
  );

  static String _getTitleFromPath(String path) {
    switch (path) {
      case '/dashboard':
        return 'Dashboard';
      case '/sales':
        return 'Point of Sale';
      case '/products':
        return 'Products & Inventory';
      case '/customers':
        return 'Customer Management';
      case '/reports':
        return 'Reports & Analytics';
      default:
        return 'SmartPOS Desktop';
    }
  }
}