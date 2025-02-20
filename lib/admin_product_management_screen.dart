// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/admin_product_details.dart';
// // Updated import

// class AdminProductScreen extends StatefulWidget {
//   const AdminProductScreen({Key? key}) : super(key: key);

//   @override
//   State<AdminProductScreen> createState() => _AdminProductScreenState();
// }

// class _AdminProductScreenState extends State<AdminProductScreen> {
//   final List<Map<String, dynamic>> _products = [
//     {
//       'name': 'T-Shirt',
//       'docId': 'biRhapgdIk6LdYEcoA6A',
//       'collection': 'clothes',
//       'image': 'assets/t-shop.jpeg',
//     },
//     {
//       'name': 'Hoodie',
//       'docId': '0XT0FaUS8sdxQj7VYnIJ',
//       'collection': 'hoodies',
//       'image': 'assets/hoodie-shop.jpeg',
//     },
//     {
//       'name': 'Jeans',
//       'docId': '7iUIOTG60q64EmQqAmdV',
//       'collection': 'jeans',
//       'image': 'assets/jean-shop.jpeg',
//     },
//     {
//       'name': 'Shoes',
//       'docId': 'Op3RND16TFucJc9YNy7S',
//       'collection': 'shoes',
//       'image': 'assets/shoe-shop.jpeg',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Product Screen'),
//       ),
//       body: ListView.builder(
//         itemCount: _products.length,
//         itemBuilder: (context, index) {
//           final product = _products[index];
//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child: ListTile(
//               leading: Image.asset(
//                 product['image'] as String,
//                 width: 50,
//                 height: 50,
//                 fit: BoxFit.cover,
//               ),
//               title: Text(product['name'] as String),
//               subtitle: Text('Collection: ${product['collection']}'),
//               trailing: ElevatedButton(
//                 onPressed: () {
//                   // Navigate to AdminProductDetailsPage with admin privileges
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AdminProductDetailsPage(
//                         category: product['name'] as String,
//                         documentId: product['docId'] as String,
//                         collectionName: product['collection'] as String,
//                         isAdmin: true,
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Admin View',
//                   style: TextStyle(fontSize: 12, color: Colors.white),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/favorites_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/admin_product_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final String? baseUrl = dotenv.env['BASE_URL']; // ✅ Local server
  late Future<List<Map<String, dynamic>>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = _fetchCategories();
  }

  // ✅ Fetch categories from API
  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/category/fetch-all-categories'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['data'];
        return responseData
            .map((category) => category as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // ✅ Construct full image URL with safety checks
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150'; // ✅ Default placeholder
    }
    List<String> splitPath = imagePath.split('/');
    String imageName = splitPath.last;
    return '$baseUrl/category/fetch-category-image/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ Fixed AppBar Syntax
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // ✅ Align title & icon
          children: [
            const Text('Admin Product Screen'), // ✅ Left side title
            IconButton(
              icon: const Icon(Icons.favorite,
                  color: Colors.red), // ❤️ Favorite Icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FavoritesPage()), // ✅ Navigate to Favorites
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // ⏳ Loading indicator
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // ⚠️ Error Handling
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final imageUrl =
                  getImageUrl(category['images']); // ✅ Fetch Image URL

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.network(
                        'https://via.placeholder.com/150',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(category['name'] ?? 'Unknown Category'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // ✅ Navigate to AdminProductDetailsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProductDetailsPage(
                            category: category['name'] as String,
                            documentId: category['_id'] as String,
                            collectionName:
                                category['name'] as String, // ✅ Collection Name
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Admin View',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
