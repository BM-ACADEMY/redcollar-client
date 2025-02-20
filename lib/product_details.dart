import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/favorites_page.dart';
import 'package:flutter_application_1/home_Screen.dart';
import 'package:flutter_application_1/profile_Page.dart';
import 'package:flutter_application_1/reviewHomePage.dart';
import 'package:flutter_application_1/search.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'favorites_provider.dart';
import 'cart_screen.dart'; // Corrected the CartScreen import
import 'product_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'provider/userProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late String selectedImage;
  late String selectedColor;
  late String selectedSize;
  bool isLoading = false;
  bool isAddedToBasket = false;
  late String username;
  late String userId;
  late String email;
  static String? baseUrl = dotenv.env['BASE_URL'];
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the UserProvider inside didChangeDependencies
    final userProvider = Provider.of<UserProvider>(context);
    username = userProvider.username;
    userId = userProvider.userId;
    email = userProvider.email;
  }

  @override
  void initState() {
    super.initState();
    print(widget.product);
    List<dynamic> images = widget.product['images'] ?? [];
    selectedImage = images.isNotEmpty ? getImageUrl(images.first) : '';
    selectedColor = widget.product['color']?.first ?? '';
    selectedSize = widget.product['sizes']?.first ?? '';
    _pages = [
      HomeScreen(
        username: '',
        email: '',
        isAdmin: false,
        userId: '',
      ), // Home
      SearchScreen(), // Search
      FavoritesPage(), // Favorites
      const CartScreen(cart: []), // Cart
      ProfileScreen(
        username: '',
        email: '',
        phoneNumber: '',
      ), // Profile
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = widget.product;
    List<String> images = (product['images'] as List<dynamic>)
        .map((e) => getImageUrl(e))
        .toList();
    List<String> colors = List<String>.from(product['color'] ?? []);
    List<String> sizes = List<String>.from(product['sizes'] ?? []);

    String productName = product['name'] ?? 'Unknown Product';
    String productDocId = product['_id'] ?? '';
    double originalPrice = (product['original_price'] as num).toDouble();
    double discountPercentage =
        (product['discount_percentage'] as num).toDouble();
    double discountedPrice =
        originalPrice - (originalPrice * discountPercentage / 100);

    bool isFavorite = favoritesProvider.isFavorite(productDocId);

    // Variables for zoom functionality
    double zoomScale = 2.0; // Control the zoom factor
    Offset _zoomPosition = Offset(0.0, 0.0); // Tracks mouse position for zoom
    bool hasReviews =
        (product['reviews'] != null && product['reviews'].isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 250, 248, 248), // White background
        elevation: 4, // Small shadow effect
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Left arrow
          onPressed: () {
            Navigator.pop(context); // Go back one step
          },
        ),
        title: Text(
          productName, // Dynamic product name
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Dynamic text color
          ),
        ),
      ),
      body: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(), // Enables smooth scrolling
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery (Left) & Main Image (Right)
                    SizedBox(
                      height:
                          400, // Set a fixed height to avoid content being hidden
                      child: Row(
                        children: [
                          // Left: Image Thumbnails
                          SizedBox(
                            width: 100,
                            child: ListView.builder(
                              itemCount: images.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                String imageUrl = images[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImage = imageUrl;
                                    });
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    width: 80, // Fixed width
                                    height: 80, // Fixed height
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedImage == imageUrl
                                            ? Colors.brown
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                                Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right: Main Product Image with Zoom Effect on Hover
                          Expanded(
                            child: MouseRegion(
                              onHover: (details) {
                                setState(() {
                                  _zoomPosition = details.localPosition;
                                });
                              },
                              child: CachedNetworkImage(
                                imageUrl: selectedImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Product Details Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name & Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${discountedPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Product Description
                          Text(
                            product['description'] ??
                                'No description available.',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54),
                          ),
                          Text(
                            "Brand: ${product['brand'] ?? 'No Brand available.'}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          // Right side - Reviews

                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReviewHomePage(
                                            productId: product['_id'])),
                                  );
                                },
                                child: const Text(
                                  'View All Reviews',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Color Selection
                          _buildColorSelection(colors),
                          const SizedBox(height: 16),

                          // Size Selection
                          _buildSizeSelection(sizes),
                          const SizedBox(height: 16),

                          // Delivery Option
                          Text(
                            "Delivery Option: ${product['deliveryOption'] ?? 'Standard'}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Favorite & Cart Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.brown,
                            size: 32,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              removeFavorite(productDocId);
                            } else {
                              addFavorite(productDocId);
                            }
                            setState(() {});
                          },
                        ),

                        // Add to Cart Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await _addToBasket(
                                      userId,
                                      productDocId,
                                      selectedColor,
                                      selectedSize,
                                      discountedPrice);
                                  setState(() {
                                    isLoading = false;
                                    isAddedToBasket = true;
                                  });
                                },
                          child: Text(
                            isLoading ? 'Adding...' : 'Add to Cart',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    // View Bag & Checkout Buttons
                    if (isAddedToBasket)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartScreen(
                                      cart: []), // Pass correct cart data
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown),
                            child: const Text(
                              "View Bag",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown),
                            child: const Text(
                              "Checkout",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
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

  Future<void> addFavorite(String productId) async {
    final url = '$baseUrl/linkedproducts/create-favorite';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "productId": productId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to favorites'),
          ),
        );
      } else {
        throw Exception('Failed to toggle favorite');
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  Future<void> removeFavorite(String productId) async {
    final url = '$baseUrl/linkedproducts/delete-favorite';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "productId": productId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from favorites'),
          ),
        );
      } else {
        throw Exception('Failed to toggle favorite');
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  Widget _buildColorSelection(List<String> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: colors.map((color) => _buildColorOption(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: selectedColor == color ? Colors.brown.withOpacity(0.2) : null,
        ),
        child: Text(
          color,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSizeSelection(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: sizes.map((size) => _buildSizeOption(size)).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: selectedSize == size ? Colors.brown.withOpacity(0.2) : null,
        ),
        child: Text(
          size,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String getImageUrl(String imagePath) {
    return '$baseUrl/products/fetch-product-image/${imagePath.split('/').last}';
  }

  Future<void> _addToBasket(String userId, String productDocId,
      String selectedColor, String selectedSize, double discountedPrice) async {
    final url = Uri.parse('$baseUrl/carts/create-cart');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId, // Add userId here
          'product':
              productDocId, // Send only productId, not the whole product object
          'quantity': 1, // Default quantity to 1
          'selected_color': selectedColor, // Send selectedColor
          'selected_size': selectedSize, // Send selectedSize
          'total_price':
              discountedPrice // Optional: Add total_price if you want to calculate it
        }),
      );

      if (response.statusCode == 201) {
        // Successfully added to basket
        print("Item added to basket");
      } else {
        // Error handling
        print("Failed to add item to basket: ${response.body}");
      }
    } catch (error) {
      // Handle network or other errors
      print("Error: $error");
    }
  }

  // CheckoutScreen declaration
  CheckoutScreen() {
    return Scaffold(
      body: Center(
        child: Text("Checkout Screen"),
      ),
    );
  }
}
