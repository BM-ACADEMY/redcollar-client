import 'package:flutter/material.dart';
import 'package:flutter_application_1/search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'favorites_provider.dart';
import 'product_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductTypesScreen extends StatefulWidget {
  final String typeId;

  const ProductTypesScreen({Key? key, required this.typeId}) : super(key: key);

  @override
  State<ProductTypesScreen> createState() => _ProductTypesScreenState();
}

class _ProductTypesScreenState extends State<ProductTypesScreen> {
  @override
  void initState() {
    super.initState();
    print("Fetching products for typeId: ${widget.typeId}");
    _fetchProductsByType();
  }

  String searchQuery = "";
  final String? baseUrl = dotenv.env['BASE_URL'];
  Future<List<Map<String, dynamic>>> _fetchProductsByType() async {
    print(widget.typeId);
    final response = await http.get(
      Uri.parse('$baseUrl/products/fetch-product-by-type-id/${widget.typeId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Check if the response is a list or a message object
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map<String, dynamic> && data.containsKey('message')) {
        // Handle "No products found" case
        return []; // Return empty list so the UI shows "No products found"
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Border height
          child: Container(
            color: Colors.black26, // Border color
            height: 1.0, // Border thickness
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
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
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchProductsByType(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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
                        item['name']?.toLowerCase().contains(searchQuery) ??
                        false)
                    .toList();

                if (filteredProducts.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = filteredProducts[index];
                    return _buildProductCard(context, item, favoritesProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> item,
      FavoritesProvider favoritesProvider) {
    final isFavorite = favoritesProvider.isFavorite(item['_id'] ?? '');
    final imageUrl =
        item['images']?.isNotEmpty == true ? item['images'][0] : '';

    final discountPercentage = item['discount_percentage'] as num? ?? 0;
    final discountedPrice = ((item['original_price'] as num) -
            ((item['original_price'] as num) * discountPercentage / 100))
        .toStringAsFixed(2);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: item),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Icon(Icons.image_not_supported),
            ),
          ),

          // **Discount Badge**
          if (discountPercentage > 0)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '${discountPercentage.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Product Details Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 238, 238, 238),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['name'] ?? 'Unnamed',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['brand'] ?? 'Brand',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\₹${item['original_price']}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              decoration: TextDecoration
                                  .lineThrough, // Strikethrough for original price
                            ),
                          ),
                          const SizedBox(width: 5), // Spacing between prices
                          Text(
                            '\₹$discountedPrice',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.red, // Highlight the discounted price
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          if (isFavorite) {
                            favoritesProvider.removeFavorite(item['_id'] ?? '');
                          } else {
                            favoritesProvider.addFavorite(item);
                          }
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.shopping_bag
                              : Icons.shopping_bag_outlined,
                          color: Colors.black,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No products found',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        'Failed to load products',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.red),
      ),
    );
  }
}
