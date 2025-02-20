import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white, // Keep the background white for clean look
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.black, // Black text for better visibility
          ),
        ),
        backgroundColor: Colors.white, // White background for app bar
        iconTheme: const IconThemeData(
            color: Colors.black), // Icons in black for consistency
        elevation: 0, // No elevation for flat app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 16, // Space between columns
                mainAxisSpacing: 16, // Space between rows
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

  // A helper method to create each card for admin panel options
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
        color: Colors.white, // White card background for consistency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners for cards
        ),
        elevation: 3, // Subtle shadow to create depth
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30, // Icon size and spacing
              backgroundColor:
                  color.withOpacity(0.1), // Light background for circle
              child: Icon(icon, size: 40, color: color), // Icon with main color
            ),
            const SizedBox(height: 12), // Space between icon and text
            Text(
              title,
              style: TextStyle(
                fontSize: 16, // Text size for the title
                fontWeight: FontWeight.bold, // Bold text for titles
                color: Colors.black, // Use black text for better readability
              ),
              textAlign: TextAlign.center, // Center align the text
            ),
          ],
        ),
      ),
    );
  }
}
