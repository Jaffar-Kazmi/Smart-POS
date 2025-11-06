
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:pos_app/features/auth/presentation/pages/login_page.dart';
import 'package:pos_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pos_app/features/products/presentation/pages/products_page.dart';
import 'package:pos_app/features/sales/presentation/pages/pos_page.dart';
import 'package:pos_app/features/customers/presentation/pages/customers_page.dart';
import 'package:pos_app/features/reports/presentation/pages/reports_page.dart';
import 'package:pos_app/shared/widgets/main_layout.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;
      final isAdmin = authProvider.isAdmin;

      final isLoggingIn = state.uri.path == '/login';

      // If not logged in, redirect to login page
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // If logged in and trying to access login page, redirect to appropriate home screen
      if (isLoggedIn && isLoggingIn) {
        return isAdmin ? '/dashboard' : '/sales';
      }

      // Prevent non-admins from accessing admin routes
      if (!isAdmin && _isAdminRoute(state.uri.path)) {
        return '/sales'; // Redirect to sales page
      }

      return null; // No redirect needed
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

  static bool _isAdminRoute(String path) {
    const adminRoutes = [
      '/dashboard',
      '/customers',
      '/reports',
      '/settings', // Assuming you have a settings page
    ];
    return adminRoutes.contains(path);
  }

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
