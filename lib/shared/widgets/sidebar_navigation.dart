import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildNavigationItems(context),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          Icon(
            Icons.store,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildNavigationItem(
          context,
          icon: Icons.dashboard,
          title: AppStrings.dashboard,
          path: '/dashboard',
          isSelected: currentPath == '/dashboard',
        ),
        _buildNavigationItem(
          context,
          icon: Icons.shopping_cart,
          title: AppStrings.sales,
          path: '/sales',
          isSelected: currentPath == '/sales',
        ),
        _buildNavigationItem(
          context,
          icon: Icons.inventory,
          title: AppStrings.products,
          path: '/products',
          isSelected: currentPath == '/products',
        ),
        _buildNavigationItem(
          context,
          icon: Icons.people,
          title: AppStrings.customers,
          path: '/customers',
          isSelected: currentPath == '/customers',
        ),
        _buildNavigationItem(
          context,
          icon: Icons.analytics,
          title: AppStrings.reports,
          path: '/reports',
          isSelected: currentPath == '/reports',
        ),
        const Divider(height: 32),
        _buildNavigationItem(
          context,
          icon: Icons.settings,
          title: AppStrings.settings,
          path: '/settings',
          isSelected: currentPath == '/settings',
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String path,
        required bool isSelected,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => context.go(path),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              authProvider.logout();
              context.go('/login');
            },
          );
        },
      ),
    );
  }
}