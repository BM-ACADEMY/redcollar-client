import 'package:flutter/material.dart';
import 'package:flutter_application_1/address.dart';
import 'package:flutter_application_1/changePassword.dart';
import 'package:flutter_application_1/orderConfirmationPage.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'reviews.dart';
import 'OrderPage.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;

  const ProfileScreen(
      {super.key,
      required this.username,
      required this.email,
      required String phoneNumber});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userName;
  late String userEmail;
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    userName = widget.username;
    userEmail = widget.email;
  }

  late String userId;
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the UserProvider inside didChangeDependencies
    final userProvider = Provider.of<UserProvider>(context);

    userId = userProvider.userId;
    userName = userProvider.username;
    email = userProvider.email;
    print(email);
  }

  // Function to edit profile name
  void editProfile() {
    TextEditingController nameController =
        TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Full Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                userName = nameController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Function to log out
  Future<void> logout() async {
    // Implement your logout functionality here
    // For example, clearing session data or signing out from Firebase
    // Since you are already navigating to the sign-in screen, no return value is needed
    Navigator.pushReplacementNamed(context, "/signin");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Profile Header with Image & Details
            Container(
              height: 350,
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E6E53), Color(0xFFB89C89)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Implement profile picture upload
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Text(
                              _getInitials(userName),
                              style: TextStyle(
                                color: Colors.brown.shade700,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Profile Options
            const Text(
              "Profile Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.brown),
              title: Text(userName, style: const TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.brown),
                onPressed: editProfile,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.brown),
              title: Text(
                email.isNotEmpty ? email : 'No email available',
                style: const TextStyle(fontSize: 18),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.brown),
              title: const Text("Orders", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrderPage()), // Navigate to Order.dart
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Colors.brown),
              title: const Text("Address", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddressService()), // Navigate to AddressPage
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review, color: Colors.brown),
              title: const Text("Reviews", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewsPage(userId: userId),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock, color: Colors.brown),
              title:
                  const Text("Change Password", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.brown),
              title: const Text("Order Traking Page",
                  style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderConfirmationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Sign Out",
                  style: TextStyle(fontSize: 18, color: Colors.red)),
              onTap: () async {
                // Perform sign-out logic (e.g., Firebase or custom sign-out function)
                await logout(); // Ensure you await it but don't use its result.

                // Navigate to the Sign-In page after sign-out
                Navigator.pushReplacementNamed(context, '/signin');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// *Generate Initials from Name*
  String _getInitials(String name) {
    String initials = "";
    List<String> nameParts = name.trim().split(" ");
    for (var part in nameParts) {
      if (part.isNotEmpty) initials += part[0].toUpperCase();
    }
    return initials;
  }
}
