import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../sales/presentation/pages/pos_page.dart';
import '../../../customers/presentation/pages/customers_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    
    // Define pages based on role to match NavigationHelper indices
    final List<Widget> _pages = isAdmin
        ? [
            const DashboardPage(),
            const ProductsPage(),
            POSPage(),
            const CustomersPage(),
            const ReportsPage(),
            const SettingsPage(),
          ]
        : [
            const ProductsPage(),
            POSPage(),
            const CustomersPage(),
          ];

    // Ensure _currentIndex is valid for current role's page count
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          destinations: NavigationHelper.getNavigationDestinations(isAdmin: isAdmin),
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authProvider.currentUser?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    isAdmin ? 'Admin Access' : 'Cashier Access',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              onTap: isAdmin
                  ? () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    }
                  : null,
              enabled: isAdmin,
              selected: isAdmin && _currentIndex == 0,
            ),
            _buildDrawerItem(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = isAdmin ? 1 : 0);
              },
              selected: _currentIndex == (isAdmin ? 1 : 0),
            ),
            _buildDrawerItem(
              icon: Icons.point_of_sale,
              title: 'POS Terminal',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = isAdmin ? 2 : 1);
              },
              selected: _currentIndex == (isAdmin ? 2 : 1),
            ),
            _buildDrawerItem(
              icon: Icons.people_outline,
              title: 'Customers',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = isAdmin ? 3 : 2);
              },
              selected: _currentIndex == (isAdmin ? 3 : 2),
            ),
            if (isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(color: Colors.white.withOpacity(0.1)),
              ),
              _buildDrawerItem(
                icon: Icons.analytics_outlined,
                title: 'Reports',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 4);
                },
                selected: _currentIndex == 4,
              ),
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 5);
                },
                selected: _currentIndex == 5,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(color: Colors.white.withOpacity(0.1)),
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool enabled = true,
    bool selected = false,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.redAccent
        : (selected
            ? Theme.of(context).colorScheme.primary
            : Colors.white70);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: selected
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? color : Colors.white24,
          shadows: selected && !isDestructive
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? color : Colors.white24,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: enabled ? onTap : null,
        enabled: enabled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
