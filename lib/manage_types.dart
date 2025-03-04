import 'package:flutter_application_1/addOreditTypeScreen.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ManageTypesScreen extends StatefulWidget {
  const ManageTypesScreen({Key? key}) : super(key: key);

  @override
  _ManageTypesScreenState createState() => _ManageTypesScreenState();
}

class _ManageTypesScreenState extends State<ManageTypesScreen> {
  final String? baseUrl = dotenv.env['BASE_URL'];
  List<Map<String, dynamic>> types = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTypes();
  }

  Future<void> fetchTypes() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/types/get-all-types-for-types'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          types = List<Map<String, dynamic>>.from(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load types");
      }
    } catch (e) {
      print("Error fetching types: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteType(String id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/types/delete-type/$id'));
      if (response.statusCode == 200) {
        fetchTypes();
      } else {
        throw Exception("Failed to delete type");
      }
    } catch (e) {
      print("Error deleting type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Types",
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Border height
          child: Container(
            color: Colors.black26, // Border color
            height: 1.0, // Border thickness
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddOrEditTypeScreen()),
              );
              fetchTypes(); // Refresh after adding
            },
            icon: Icon(Icons.add, size: 10, color: Colors.white),
            label: Text("Add New",
                style: TextStyle(fontSize: 10, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded button
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 10, vertical: 12), // Button size
              elevation: 5, // Shadow effect
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: type['image'] != null
                        ? Image.network(type['image'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                    title: Text(type['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(type['description'] ?? "No description"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddOrEditTypeScreen(
                                  id: type['_id'],
                                  existingName: type['name'],
                                  existingDescription: type['description'],
                                  existingImage: type['image'],
                                ),
                              ),
                            );
                            fetchTypes(); // Refresh after updating
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteType(type['_id']),
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
