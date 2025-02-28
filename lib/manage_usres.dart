// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
// import 'dart:convert'; // Required for parsing JSON

// class ManageUsersScreen extends StatefulWidget {
//   const ManageUsersScreen({super.key});

//   @override
//   _ManageUsersScreenState createState() => _ManageUsersScreenState();
// }

// class _ManageUsersScreenState extends State<ManageUsersScreen> {
//   List<Map<String, String>> users = [];

//   @override
//   void initState() {
//     super.initState();
//     _getUsers(); // Fetch the list of users when the screen loads
//   }

//   // Fetch users from the backend
//   Future<void> _getUsers() async {
//     final response = await http.get(Uri.parse('http://10.0.2.2:6000/users'));

//     if (response.statusCode == 200) {
//       final List<Map<String, String>> fetchedUsers = [];

//       // Parsing the JSON response to a List of dynamic objects
//       final List<dynamic> userData = json.decode(response.body);

//       // Now process each user
//       for (var user in userData) {
//         fetchedUsers.add({
//           'email': user['email'], // Only use email for display
//         });
//       }

//       setState(() {
//         users = fetchedUsers;
//       });
//     } else {
//       Fluttertoast.showToast(
//         msg: "Failed to load users",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }

//   // Delete user by email
//   Future<void> _deleteUser(String email) async {
//     final response = await http.delete(
//       Uri.parse('http://10.0.2.2:6000/deleteUserByEmail/$email'),
//     );

//     if (response.statusCode == 200) {
//       _showToast("User deleted successfully");

//       _getUsers(); // Refresh the user list after deletion
//     } else {
//       _showToast("Error deleting user");
//     }
//   }

//   // Show toast message
//   void _showToast(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Users'),
//         backgroundColor: Colors.blue,
//       ),
//       body: users.isEmpty
//           ? const Center(
//               child: CircularProgressIndicator()) // Show loading while fetching
//           : ListView.builder(
//               itemCount: users.length,
//               itemBuilder: (context, index) {
//                 final user = users[index];

//                 return Card(
//                   margin: const EdgeInsets.all(8.0),
//                   elevation: 4,
//                   child: ListTile(
//                     title:
//                         Text('Email: ${user['email']}'), // Only display email
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteUser(
//                           user['email']!), // Call delete user by email
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final String? baseUrl = dotenv.env['BASE_URL'];
  List<Map<String, dynamic>> users = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getUsers();
    _scrollController.addListener(_scrollListener);
  }

  // ✅ GET USERS (Pagination & Infinite Scroll)
  Future<void> _getUsers({bool refresh = false}) async {
    if (isLoading || !hasMore) return;

    if (refresh) {
      setState(() {
        users.clear();
        currentPage = 1;
        hasMore = true;
      });
    }

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/fetch-all-users?page=$currentPage&limit=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> userData = data['users'];
        // final int totalUsers = data['totalUsers'];
        final int totalPages = data['totalPages'];

        if (userData.isEmpty || currentPage > totalPages) {
          setState(() => hasMore = false);
        } else {
          setState(() {
            users.addAll(userData.map((user) => {
                  'id': user['_id'].toString(),
                  'username': user['username'].toString(),
                  'email': user['email'].toString(),
                  'phoneNumber': user['phoneNumber']?.toString() ?? '',
                  'addressLine1': user['address']?['addressLine1'] ?? '',
                  'addressLine2': user['address']?['addressLine2'] ?? '',
                  'country': user['address']?['country'] ?? '',
                  'state': user['address']?['state'] ?? '',
                  'city': user['address']?['city'] ?? '',
                  'pincode': user['address']?['pincode'] ?? '',
                }));

            currentPage++;
            hasMore = currentPage <= totalPages; // Stop fetching if last page
          });
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      _showToast("Error fetching users: $e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ POST (ADD NEW USER)
  Future<void> _addUser(
      String username, String email, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/addUser'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': {} // Empty initially
      }),
    );

    if (response.statusCode == 201) {
      _showToast("User added successfully", Colors.green);
      _getUsers(refresh: true);
    } else {
      _showToast("Error adding user", Colors.red);
    }
  }

  // ✅ PUT (UPDATE USER DETAILS)
  Future<void> _updateUser(
      String userId, String email, String username, String phoneNumber) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/updateUserById/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
          {'email': email, 'username': username, 'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      _showToast("User updated successfully", Colors.green);
      Navigator.pop(context);
      _getUsers(refresh: true);
    } else {
      _showToast("Error updating user", Colors.red);
    }
  }

  // ✅ DELETE USER
  Future<void> _deleteUser(String userId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/users/deleteUser/$userId'));

    if (response.statusCode == 200) {
      _showToast("User deleted successfully", Colors.green);
      setState(() {
        users.removeWhere((user) => user['id'] == userId);
      });
    } else {
      _showToast("Error deleting user", Colors.red);
    }
  }

  // ✅ Infinite Scroll Listener
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.95) {
      _getUsers();
    }
  }

  // ✅ Show Add User Popup
  void _showAddUserDialog() {
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _addUser(usernameController.text, emailController.text,
                  phoneController.text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ✅ Show Toast
  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
        msg: message, backgroundColor: color, textColor: Colors.white);
  }

  void _showAddressDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Address of ${user['username']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Address Line 1: ${user['addressLine1']}"),
            Text("Address Line 2: ${user['addressLine2']}"),
            Text("City: ${user['city']}"),
            Text("State: ${user['state']}"),
            Text("Country: ${user['country']}"),
            Text("Pincode: ${user['pincode']}"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    TextEditingController usernameController =
        TextEditingController(text: user['username']?.toString() ?? '');
    TextEditingController emailController =
        TextEditingController(text: user['email']?.toString() ?? '');
    TextEditingController phoneController =
        TextEditingController(text: user['phoneNumber']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _updateUser(user['id'].toString(), emailController.text,
                  usernameController.text, phoneController.text);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditUserDialog({}),
        child: const Icon(Icons.add),
      ),
      body: Scrollbar(
        thickness: 6,
        radius: const Radius.circular(10),
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: users.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == users.length) {
              return isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox();
            }

            final user = users[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Details
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Username: ${user['username'] ?? 'N/A'}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Email: ${user['email'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Text(
                          'Phone: ${user['phoneNumber'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            // Handle info icon click (Show details, tooltip, or action)
                          },
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Icons Row with Transparent Background
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconButton(
                        Icons.location_on,
                        Colors.blue,
                        () => _showAddressDialog(user),
                      ),
                      _iconButton(
                        Icons.edit,
                        Colors.orange,
                        () => _showEditUserDialog(user),
                      ),
                      _iconButton(
                        Icons.delete,
                        Colors.red,
                        () => _deleteUser(user['id'] ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom Icon Button with Transparent Black Background
  Widget _iconButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2), // More visible transparency
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
