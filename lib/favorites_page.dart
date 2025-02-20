// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'favorites_provider.dart';

// class FavoritesPage extends StatelessWidget {
//   const FavoritesPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final favoritesProvider = Provider.of<FavoritesProvider>(context);

//     return DefaultTabController(
//       length: 2, // Two tabs: All Products and Favorites
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Favorites',
//             style: TextStyle(
//               color: Colors.brown,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.brown,
//           elevation: 0,
//           bottom: const TabBar(
//             indicatorColor: Colors.brown,
//             indicatorWeight: 3,
//             labelColor: Colors.brown,
//             unselectedLabelColor: Colors.grey,
//             tabs: [
//               Tab(text: 'all category'),
//               Tab(text: 'Favorites'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildAllProductsView(context), // All Products Tab
//             _buildFavoritesView(favoritesProvider), // Favorites Tab
//           ],
//         ),
//       ),
//     );
//   }

//   /// All Products Tab
//   Widget _buildAllProductsView(BuildContext context) {
//     // Sample product data
//     final sampleProducts = [
//       {
//         'name': 'T-Shirts',
//         'docId': 'biRhapgdIk6LdYEcoA6A',
//         'image': 'assets/compressedimages/cclothes/t6.jpeg',
//       },
//       {
//         'name': 'Hoodies',
//         'docId': '0XT0FaUS8sdxQj7VYnIJ',
//         'image': 'assets/compressedimages/choodies/h1.jpeg',
//       },
//       {
//         'name': 'Jeans',
//         'docId': '7iUIOTG60q64EmQqAmdV',
//         'image': 'assets/compressedimages/cjeans/j1.jpeg',
//       },
//       {
//         'name': 'Shoes',
//         'docId': 'Op3RND16TFucJc9YNy7S',
//         'image': 'assets/compressedimages/cshoes/s1.jpeg',
//       },
//     ];

//     final favoritesProvider = Provider.of<FavoritesProvider>(context);

//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 3 / 4,
//       ),
//       itemCount: sampleProducts.length,
//       itemBuilder: (context, index) {
//         final item = sampleProducts[index];
//         final isFavorite = favoritesProvider.isFavorite(item['docId']!);

//         return _buildProductCard(context, item, isFavorite);
//       },
//     );
//   }

//   /// Favorites Tab
//   Widget _buildFavoritesView(FavoritesProvider favoritesProvider) {
//     final favorites = favoritesProvider.favorites;

//     if (favorites.isEmpty) {
//       return const Center(
//         child: Text(
//           'No favorites yet!',
//           style: TextStyle(fontSize: 18, color: Colors.grey),
//         ),
//       );
//     }

//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 3 / 4,
//       ),
//       itemCount: favorites.length,
//       itemBuilder: (context, index) {
//         final item = favorites[index];
//         return _buildProductCard(context, item, true);
//       },
//     );
//   }

//   /// Product Card Widget
//   Widget _buildProductCard(
//       BuildContext context, Map<String, dynamic> item, bool isFavorite) {
//     final favoritesProvider =
//         Provider.of<FavoritesProvider>(context, listen: false);

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       clipBehavior: Clip.antiAlias,
//       elevation: 4,
//       child: Stack(
//         children: [
//           Image.asset(
//             item['image'],
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//           Positioned(
//             bottom: 16,
//             left: 16,
//             child: Text(
//               item['name'],
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 8,
//             right: 8,
//             child: IconButton(
//               icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
//               color: isFavorite ? Colors.red : Colors.grey,
//               onPressed: () {
//                 if (isFavorite) {
//                   favoritesProvider.removeFavorite(item['docId']);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('${item['name']} removed from favorites!'),
//                     ),
//                   );
//                 } else {
//                   favoritesProvider.addFavorite(item);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('${item['name']} added to favorites!'),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'favorites_provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final String baseUrl = "http://10.0.2.2:6000/api";
  late Future<List<Map<String, dynamic>>> categoriesFuture;
  late Future<List<dynamic>> favoritesFuture;

  late String userId;

  @override
  void initState() {
    super.initState();
    categoriesFuture = fetchCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId;

    // Only call the fetchFavoriteProducts() once userId is set
    favoritesFuture =
        fetchFavoriteProducts(); // Ensure this is called only after userId is initialized
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/category/fetch-all-categories'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<dynamic>> fetchFavoriteProducts() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/linkedproducts/fetch-favorite-products-by-userId/$userId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Debugging to inspect the returned response
        print('Response Data: ${jsonData['data']}');

        if (jsonData['data'] != null) {
          // Ensure the response data is a list
          if (jsonData['data'] is List) {
            return List<dynamic>.from(jsonData['data']);
          } else {
            throw Exception('Unexpected data format: data is not a list');
          }
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print('Error: $e'); // Debugging the error message
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/linkedproducts/delete-favorite'), // Correct API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId, // Product ID to be removed
          'userId': userId, // User ID who is removing the favorite
        }),
      );

      if (response.statusCode == 200) {
        print('Favorite removed successfully');

        // Once the favorite is removed, call fetchFavoriteProducts to update the list
        setState(() {
          favoritesFuture =
              fetchFavoriteProducts(); // Re-fetch favorite products
        });
      } else {
        print('Failed to remove favorite');
      }
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<void> addFavorite(Map<String, dynamic> item) async {
    // Your code to add a favorite (it will need a proper API endpoint)
    // You can follow the same logic used for `removeFavorite`
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites',
              style:
                  TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.brown,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.brown,
            indicatorWeight: 3,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'All Category'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllProductsView(),
            _buildFavoritesView(favoritesProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProductsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        final categories = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 4,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final imageUrl = category['images'] != null &&
                    category['images'].isNotEmpty
                ? '$baseUrl/category/fetch-category-image/${category['images'].split('/').last}'
                : ''; // Handle missing images
            return _buildProductCard(context, category, imageUrl, false);
          },
        );
      },
    );
  }

  Widget _buildFavoritesView(FavoritesProvider favoritesProvider) {
    return FutureBuilder<List<dynamic>>(
      future: favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No favorites yet!',
                  style: TextStyle(fontSize: 18, color: Colors.grey)));
        }

        final favorites = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 4,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            final product = favorite['productId']; // productId is an object
            final productId =
                product['_id']; // Access the _id field using the correct key

            // Check if product and images are not null or empty
            final imageUrl = product['images'] != null &&
                    product['images'].isNotEmpty
                ? '$baseUrl/products/fetch-product-image/${product['images'][0].split('/').last}'
                : ''; // Fallback to empty string if images is not valid or empty

            return _buildProductCard(context, product, imageUrl, true);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> item,
      String imageUrl, bool isFavorite) {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Stack(
        children: [
          imageUrl.isNotEmpty
              ? Image.network(imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity)
              : const Center(
                  child: Icon(Icons.image,
                      size: 50,
                      color: Colors.grey)), // Placeholder for missing image
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(item['name'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              color: isFavorite ? Colors.red : Colors.grey,
              onPressed: () async {
                final productId = item['_id']; // Product ID

                if (isFavorite) {
                  await removeFavorite(productId); // Remove favorite
                } else {
                  await addFavorite(item); // Add favorite
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
