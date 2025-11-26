import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/presentation/widgets/futuristic_header.dart';
import '../../../../core/presentation/widgets/futuristic_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey;

    return Scaffold(
      body: Column(
        children: [
          const FuturisticHeader(title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader(context, 'Appearance'),
                FuturisticCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: Text('Dark Theme', style: TextStyle(color: textColor)),
                    subtitle: Text('Enable dark mode for better visibility', style: TextStyle(color: subtitleColor)),
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                if (authProvider.isAdmin) ...[
                  _buildSectionHeader(context, 'Management'),
                  FuturisticCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.category,
                          title: 'Product Categories',
                          subtitle: 'Add, edit, or delete product categories',
                          onTap: () => Navigator.pushNamed(context, '/categories'),
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                        Divider(height: 1, color: textColor.withOpacity(0.1)),
                        _buildListTile(
                          context,
                          icon: Icons.local_offer,
                          title: 'Manage Coupons',
                          subtitle: 'Create and manage discount coupons',
                          onTap: () => Navigator.pushNamed(context, '/coupons'),
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                        Divider(height: 1, color: textColor.withOpacity(0.1)),
                        _buildListTile(
                          context,
                          icon: Icons.people_alt,
                          title: 'User Management',
                          subtitle: 'Manage users and roles',
                          onTap: () => Navigator.pushNamed(context, '/user_management'),
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildSectionHeader(context, 'About'),
                FuturisticCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.info,
                        title: 'About SmartPOS',
                        subtitle: 'Version 2.0.0',
                        onTap: () => _showAboutDialog(context),
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      Divider(height: 1, color: textColor.withOpacity(0.1)),
                      _buildListTile(
                        context,
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        onTap: () => _showPrivacyDialog(context),
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)) : null,
      trailing: Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SmartPOS',
      applicationVersion: '2.0.0',
      applicationLegalese: '© 2025 SmartPOS. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('SmartPOS is a modern Point of Sale system for retail businesses.'),
        const SizedBox(height: 8),
        const Text('Features:'),
        const Text('• Product & Inventory Management'),
        const Text('• Customer Management'),
        const Text('• Real-time Sales Processing'),
        const Text('• Dark/Light Theme'),
        const Text('• Discount & Coupon System'),
        const Text('• Advanced Reports'),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your privacy is important to us.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'SmartPOS stores all data locally on your device. We do not collect or transmit any personal data to external servers.',
              ),
              SizedBox(height: 8),
              Text(
                'For more information, please contact our support team.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
