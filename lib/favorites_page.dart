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
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final String? baseUrl = dotenv.env['BASE_URL'];
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
    favoritesFuture = fetchFavoriteProducts();
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
        print('Response Data: ${jsonData['data']}');

        if (jsonData['data'] != null) {
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
      print('Error: $e');
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/linkedproducts/delete-favorite'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': productId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Favorite removed successfully');
        setState(() {
          favoritesFuture = fetchFavoriteProducts();
        });
      } else {
        print('Failed to remove favorite');
      }
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<void> addFavorite(Map<String, dynamic> item) async {}

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFE0000),
            indicatorWeight: 4,
            labelColor: Colors.black,
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
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            // final imageUrl = category['images'] != null &&
            //         category['images'].isNotEmpty
            //     ? '$baseUrl/category/fetch-category-image/${category['images'].split('/').last}'
            //     : '';

            final imageUrl =
                category['images'] != null && category['images'].isNotEmpty
                    ? category['images']
                    : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16), // Space between items
              child: _buildCategoryCard(context, category, imageUrl),
            );
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
            child: Text(
              'No favorites yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final favorites = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            final product = favorite['productId'];

            // Ensure product and images are not null or empty
            // final imageUrl = product['images'] != null &&
            //         product['images'].isNotEmpty
            //     ? '$baseUrl/products/fetch-product-image/${product['images'][0].split('/').last}'
            //     : '';

            final imageUrl =
                product['images'] != null && product['images'].isNotEmpty
                    ? product['images'][0]
                    : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildFavoriteCard(context, product, imageUrl),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category, String imageUrl) {
    return Stack(
      children: [
        // Category Image Container
        Container(
          height: 160, // Fixed height for category card
          width: double.infinity,
          // margin: const EdgeInsets.only(left: 30), // Offset 30px from left
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
            color: Colors.grey[300],
          ),
        ),

        // Name Overlay with Vertical Text
        Positioned(
          top: 0,
          bottom: 0,
          left: 0, // Overlay sticks to left edge
          child: Container(
            width: 80, // Fixed width for overlay
            decoration: BoxDecoration(
              color:
                  Color(0xFF83807A).withOpacity(0.6), // Semi-transparent black
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 3, // Rotate text vertically (bottom to top)
              child: Text(
                category['name'] ?? "Category",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(
      BuildContext context, Map<String, dynamic> product, String imageUrl) {
    // Calculate final price after discount
    double originalPrice = product['original_price']?.toDouble() ?? 0;
    double discountPercentage = product['discount_percentage']?.toDouble() ?? 0;
    double finalPrice =
        originalPrice - (originalPrice * (discountPercentage / 100));

    return Stack(
      children: [
        // Card Container
        Container(
          height: 100,
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10), // 10px left border offset
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Image border radius
            color: Colors.white,
            border: Border(
              left: BorderSide(
                  color: Color(0xFFFE0000), width: 10), // Left side border
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 120,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 120,
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
              ),

              const SizedBox(width: 10), // Gap of 3px between image and text

              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Product Name & Brand
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? "Product Name",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['brand'] ?? "Brand",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      // Price & Discounted Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Final Price (on top)
                          Text(
                            '₹${finalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                              height: 3), // Small spacing between prices

                          // Original Price + Discount Percentage (in a row)
                          Row(
                            children: [
                              Text(
                                '₹${originalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '-${discountPercentage.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFE0000),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Favorite Icon in Top Right Corner
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(5),
            child: const Icon(
              Icons.favorite,
              color: Color(0xFFFE0000),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
