import 'package:flutter/material.dart';
import 'package:flutter_application_1/manage_categories.dart';
import 'package:flutter_application_1/manage_types.dart';

import 'admin_product_management_screen.dart';
import 'manage_orders_screen.dart';
import 'settings_screen.dart';
import 'manage_usres.dart';
import 'promo.dart'; // Import Manage Promotions screen

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key, required String username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _adminPanelCard(
                    context,
                    'Manage Products',
                    Icons.store,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProductScreen(),
                      ),
                    ),
                  ),
                  _adminPanelCard(
                    context,
                    'Manage Orders',
                    Icons.shopping_cart,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageOrdersScreen(),
                      ),
                    ),
                  ),
                  _adminPanelCard(
                    context,
                    'Manage Users',
                    Icons.person,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageUsersScreen(),
                      ),
                    ),
                  ),
                  _adminPanelCard(
                    context,
                    'Manage Promotions',
                    Icons.campaign,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagePromotionsScreen(),
                      ),
                    ),
                  ),
                  _adminPanelCard(
                    context,
                    'Manage Categories',
                    Icons.category,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminCategoryScreen(),
                      ),
                    ),
                  ),
                  _adminPanelCard(
                    context,
                    'Manage Types', // New Item
                    Icons.layers, // Chose an appropriate icon
                    Colors.indigo, // Different color for distinction
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ManageTypesScreen(), // New screen
                      ),
                    ),
                  ),
                  _adminPanelCard(
                    context,
                    'Settings',
                    Icons.settings,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminPanelCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
