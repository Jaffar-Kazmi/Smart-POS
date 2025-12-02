import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../sales/presentation/pages/pos_page.dart';
import '../../../customers/presentation/pages/customers_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    final List<Widget> pages = isAdmin
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

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: pages[_currentIndex],
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
                      context.pop();
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
                context.pop();
                setState(() => _currentIndex = isAdmin ? 1 : 0);
              },
              selected: _currentIndex == (isAdmin ? 1 : 0),
            ),
            _buildDrawerItem(
              icon: Icons.point_of_sale,
              title: 'POS Terminal',
              onTap: () {
                context.pop();
                setState(() => _currentIndex = isAdmin ? 2 : 1);
              },
              selected: _currentIndex == (isAdmin ? 2 : 1),
            ),
            _buildDrawerItem(
              icon: Icons.people_outline,
              title: 'Customers',
              onTap: () {
                context.pop();
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
                  context.pop();
                  setState(() => _currentIndex = 4);
                },
                selected: _currentIndex == 4,
              ),
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  context.pop();
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
                context.go('/login');
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
