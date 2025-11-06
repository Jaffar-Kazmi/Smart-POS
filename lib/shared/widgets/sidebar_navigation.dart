
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pos_app/core/constants/app_colors.dart';
import 'package:pos_app/core/constants/app_strings.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(
          'SmartPOS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (isAdmin)
          _buildNavigationItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            path: '/dashboard',
            isSelected: currentPath == '/dashboard',
          ),

        _buildNavigationItem(
          context,
          icon: Icons.shopping_cart,
          title: 'Sales',
          path: '/sales',
          isSelected: currentPath == '/sales',
        ),

        _buildNavigationItem(
          context,
          icon: Icons.inventory,
          title: 'Products',
          path: '/products',
          isSelected: currentPath == '/products',
        ),

        if (isAdmin)
          _buildNavigationItem(
            context,
            icon: Icons.people,
            title: 'Customers',
            path: '/customers',
            isSelected: currentPath == '/customers',
          ),

        if (isAdmin)
          _buildNavigationItem(
            context,
            icon: Icons.analytics,
            title: 'Reports',
            path: '/reports',
            isSelected: currentPath == '/reports',
          ),

        const Divider(height: 32),

        if (isAdmin)
          _buildNavigationItem(
            context,
            icon: Icons.person_add,
            title: 'User Management',
            path: '/admin/users',
            isSelected: currentPath == '/admin/users',
          ),

        if (isAdmin)
          _buildNavigationItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
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
