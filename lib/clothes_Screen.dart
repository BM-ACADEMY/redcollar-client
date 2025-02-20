// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:lottie/lottie.dart';
// import 'product_details.dart';
// import 'cart_Screen.dart';
// import 'favorites_provider.dart';

// class ClothesSectionPage extends StatefulWidget {
//   final String category;
//   final String documentId;
//   final String collectionName;

//   const ClothesSectionPage({
//     Key? key,
//     required this.category,
//     required this.documentId,
//     required this.collectionName,
//   }) : super(key: key);

//   @override
//   State<ClothesSectionPage> createState() => _ClothesSectionPageState();
// }

// class _ClothesSectionPageState extends State<ClothesSectionPage> {
//   String searchQuery = "";

//   Future<List<Map<String, dynamic>>> _fetchProducts() async {
//     final response = await http.get(
//       Uri.parse(
//           'http://10.0.2.2:6000/api/products/fetch-product-by-category/${widget.documentId}'),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as List;
//       return List<Map<String, dynamic>>.from(data);
//     } else {
//       throw Exception('Failed to load products');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final favoritesProvider = Provider.of<FavoritesProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.category,
//           style: const TextStyle(color: Colors.brown),
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.brown),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value.toLowerCase();
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//           ),
//           // Product Grid
//           Expanded(
//             child: FutureBuilder<List<Map<String, dynamic>>>(
//               future: _fetchProducts(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return _buildShimmerEffect();
//                 }
//                 if (snapshot.hasError) {
//                   return _buildErrorState();
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return _buildEmptyState();
//                 }

//                 final products = snapshot.data ?? [];

//                 final filteredProducts = products
//                     .where((item) =>
//                         item['name']?.toLowerCase().contains(searchQuery) ??
//                         false)
//                     .toList();

//                 if (filteredProducts.isEmpty) {
//                   return _buildEmptyState();
//                 }

//                 return GridView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: filteredProducts.length,
//                   itemBuilder: (context, index) {
//                     final item = filteredProducts[index];
//                     return _buildClothingCard(context, item, favoritesProvider);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: 6,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             color: Colors.white,
//             height: 200,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset('assets/jsons/empty.json', height: 200),
//           const SizedBox(height: 16),
//           const Text('No items found.', style: TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset('assets/jsons/error.json', height: 200),
//           const SizedBox(height: 16),
//           const Text('Error loading data.', style: TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_Screen.dart';
import 'package:flutter_application_1/profile_Page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'product_details.dart';
import 'cart_screen.dart';
import 'favorites_provider.dart';
import 'favorites_page.dart';
import 'search.dart';

class ClothesSectionPage extends StatefulWidget {
  final String category;
  final String documentId;
  final String collectionName;

  const ClothesSectionPage({
    Key? key,
    required this.category,
    required this.documentId,
    required this.collectionName,
  }) : super(key: key);

  @override
  State<ClothesSectionPage> createState() => _ClothesSectionPageState();
}

class _ClothesSectionPageState extends State<ClothesSectionPage> {
  String searchQuery = "";
  int _currentIndex = 0; // Tracks selected tab
  final List<Widget> _pages = []; // Stores different pages

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeScreen(
        username: '',
        email: '',
        isAdmin: false,
        userId: '',
      ), // Home Content
      SearchScreen(), // Search Screen
      FavoritesPage(), // Favorites Page
      const CartScreen(cart: []), // Cart Page
      ProfileScreen(
        username: '',
        email: '',
        phoneNumber: '',
      ), // Profile Page
    ]);
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:6000/api/products/fetch-product-by-category/${widget.documentId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.brown),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: _currentIndex == 0
          ? Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                // Product Grid
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerEffect();
                      }
                      if (snapshot.hasError) {
                        return _buildErrorState();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final products = snapshot.data ?? [];
                      final filteredProducts = products
                          .where((item) =>
                              item['name']
                                  ?.toLowerCase()
                                  .contains(searchQuery) ??
                              false)
                          .toList();

                      if (filteredProducts.isEmpty) {
                        return _buildEmptyState();
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final item = filteredProducts[index];
                          return _buildClothingCard(
                              context, item, favoritesProvider);
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          : _pages[_currentIndex], // Show selected page

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildClothingCard(
    BuildContext context,
    Map<String, dynamic> item,
    FavoritesProvider favoritesProvider,
  ) {
    final isFavorite = favoritesProvider.isFavorite(item['_id'] ?? '');
    final imageUrl =
        item['images']?.isNotEmpty == true ? item['images'][0] : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              product: item,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 100,
        child: Stack(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _getImageWidget(imageUrl),
            ),
            // Product Details at the Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['brand'] ?? 'Brand',
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${((item['original_price'] as num) - ((item['original_price'] as num) * (item['discount_percentage'] as num) / 100)).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isFavorite) {
                              favoritesProvider
                                  .removeFavorite(item['_id'] ?? '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${item['name']} removed from favorites!'),
                                ),
                              );
                            } else {
                              favoritesProvider.addFavorite(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${item['name']} added to favorites!'),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.shopping_bag
                                : Icons.shopping_bag_outlined,
                            color: isFavorite ? Colors.red : Colors.brown,
                          ),
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
    );
  }

  Widget _getImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(
        'assets/images/default_image.png',
        fit: BoxFit.cover,
      );
    }

    // Get image URL dynamically
    String imageUrl = getImageUrl(imagePath);

    // If it's a network URL
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default_image.png',
        fit: BoxFit.cover,
      ),
    );
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150'; // Placeholder if image path is null
    }
    List<String> splitPath = imagePath.split('/');
    String imageName = splitPath.last;
    return 'http://10.0.2.2:6000/api/products/fetch-product-image/$imageName';
  }

  Widget _buildShimmerEffect() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.white,
            height: 200,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/jsons/empty.json', height: 200),
          const SizedBox(height: 16),
          const Text('No items found.', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/jsons/error.json', height: 200),
          const SizedBox(height: 16),
          const Text('Error loading data.', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
