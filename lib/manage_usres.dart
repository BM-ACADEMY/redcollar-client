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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  // ✅ Fetch Users
  Future<void> _getUsers() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/fetch-all-users'));

      if (response.statusCode == 200) {
        final List<dynamic> userData = json.decode(response.body);

        setState(() {
          users = userData
              .map((user) => {
                    'id': user['_id'],
                    'username': user['username'].toString(),
                    'email': user['email'].toString(),
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      _showToast("Error fetching users: $e", Colors.red);
    }
  }

  // ✅ Create User
  Future<void> _createUser(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json
          .encode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      _showToast("User created successfully", Colors.green);
      Navigator.pop(context);
      _getUsers();
    } else {
      _showToast("Error creating user", Colors.red);
    }
  }

  // ✅ Update User
  Future<void> _updateUser(String userId, String newEmail, String newPassword,
      String newUsername) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/updateUserById/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': newEmail,
        'password': newPassword,
        'username': newUsername,
      }),
    );

    if (response.statusCode == 200) {
      _showToast("User updated successfully", Colors.green);
      Navigator.pop(context);
      _getUsers();
    } else {
      _showToast("Error updating user", Colors.red);
    }
  }

  // ✅ Delete User
  Future<void> _deleteUser(String userId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/users/deleteUserById/$userId'));

    if (response.statusCode == 200) {
      _showToast("User deleted successfully", Colors.green);
      _getUsers();
    } else {
      _showToast("Error deleting user", Colors.red);
    }
  }

  // ✅ Show Toast Message
  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
    );
  }

  // ✅ Show Dialog to Create User
  void _showCreateUserDialog() {
    _emailController.clear();
    _passwordController.clear();
    _usernameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _createUser(_usernameController.text,
                _emailController.text, _passwordController.text),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // ✅ Show Dialog to Update User
  void _showUpdateUserDialog(
      String userId, String oldEmail, String oldUsername) {
    final TextEditingController newEmailController =
        TextEditingController(text: oldEmail);
    final TextEditingController newUsernameController =
        TextEditingController(text: oldUsername);
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: newUsernameController,
                decoration: const InputDecoration(labelText: "New Username")),
            TextField(
                controller: newEmailController,
                decoration: const InputDecoration(labelText: "New Email")),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _updateUser(userId, newEmailController.text,
                passwordController.text, newUsernameController.text),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Manage Users'), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.add),
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  child: ListTile(
                    title: Text('Username: ${user['username']}'),
                    subtitle: Text('Email: ${user['email']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showUpdateUserDialog(
                              user['id'], user['email'], user['username']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
