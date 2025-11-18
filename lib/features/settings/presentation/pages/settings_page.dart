// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Enable dark mode for better visibility'),
            value: isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.category, color: Theme.of(context).primaryColor),
            title: const Text('Product Categories'),
            subtitle: const Text('Add, edit, or delete product categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/categories'),
          ),
          ListTile(
            leading: Icon(Icons.local_offer, color: Theme.of(context).primaryColor),
            title: const Text('Manage Coupons'),
            subtitle: const Text('Create and manage discount coupons'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/coupons'),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
            title: const Text('About SmartPOS'),
            subtitle: const Text('Version 2.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
            title: const Text('Privacy Policy'),
            onTap: () => _showPrivacyDialog(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
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
