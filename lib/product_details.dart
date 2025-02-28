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
import 'package:flutter_application_1/service/notifi_service.dart';

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
  int unreadCount = 0;
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
    _loadUnreadCount();
    print(widget.product);
    List<dynamic> images = widget.product['images'] ?? [];
    // selectedImage = images.isNotEmpty ? getImageUrl(images.first) : '';
    selectedImage = images.isNotEmpty ? images.first : '';
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

  Future<void> _loadUnreadCount() async {
    int count = await NotifiService().getUnreadCount();
    print('$count,count');
    setState(() {
      unreadCount = count;
    });
  }

  Future<void> _resetUnreadCount() async {
    await NotifiService().resetUnreadCount();
    setState(() {
      unreadCount = 0;
      // showDropdown = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _resetUnreadCount();
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
    bool _isHovered = false;
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
      backgroundColor: Colors.white,
      body: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                                            ? Colors.black
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
                              onEnter: (_) {
                                setState(() {
                                  _isHovered = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _isHovered = false;
                                });
                              },
                              onHover: (details) {
                                setState(() {
                                  _zoomPosition = details.localPosition;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isHovered
                                      // ignore: dead_code
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 6),
                                          )
                                        ]
                                      : [],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        height: double.maxFinite,
                                        imageUrl: selectedImage,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                                Icons.image_not_supported),
                                      ),
                                      if (_isHovered)
                                        // ignore: dead_code
                                        AnimatedOpacity(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          opacity: 0.2,
                                          child: Container(
                                            color: Colors.black,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
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
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_offer,
                                      size: 20,
                                      color: Colors.black), // Brand icon
                                  const SizedBox(
                                      width: 8), // Space between icon and text
                                  Text(
                                    product['brand'] ?? 'No Brand available.',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.local_shipping,
                                      size: 20, color: Color(0xFFFE0000)),
                                  const SizedBox(
                                      width:
                                          5), // Add spacing between the icon and text
                                  Text(
                                    product['deliveryOption'] ?? 'Standard',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // Right side - Reviews

                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFFE0000), size: 20),
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
                                  style: TextStyle(color: Colors.black),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (isFavorite) {
                                    removeFavorite(productDocId);
                                  } else {
                                    addFavorite(productDocId);
                                  }
                                  setState(() {});
                                },
                                icon: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    shape: BoxShape.circle, // Rounded container
                                    // border: Border.all(
                                    //     color: Colors.black,
                                    //     width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.2), // Shadow color
                                        blurRadius: 6, // Medium blur
                                        spreadRadius: 2, // Soft spread
                                        offset:
                                            Offset(2, 4), // Position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                                ),
                              ),

                              // Add to Cart Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.black, // Black background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Rounded edges
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 20), // Spacing
                                  elevation: 6, // Slight shadow for depth
                                ),
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
                                icon: const Icon(
                                  Icons.shopping_cart, // Shopping cart icon
                                  color:
                                      Colors.white, // White icon for contrast
                                ),
                                label: Text(
                                  isLoading ? 'Adding...' : 'Add to Cart',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white, // White text
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2, // Slight spacing
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Favorite & Cart Buttons

                    // if (isAddedToBasket)
                    //   Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => CartScreen(
                    //                   cart: []), // Pass correct cart data
                    //             ),
                    //           );
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.brown),
                    //         child: const Text(
                    //           "View Bag",
                    //           style:
                    //               TextStyle(fontSize: 18, color: Colors.white),
                    //         ),
                    //       ),
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => CheckoutScreen(),
                    //             ),
                    //           );
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //             backgroundColor: Colors.brown),
                    //         child: const Text(
                    //           "Checkout",
                    //           style:
                    //               TextStyle(fontSize: 18, color: Colors.white),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // View Bag & Checkout Buttons
                  ],
                ),
              ),
            )
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(
            // ❌ Do NOT use `const` here
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart), // Cart icon
                if (unreadCount > 0) // Show badge only if count > 0
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
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

  // Widget _buildColorSelection(List<String> colors) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('Color',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 8),
  //       Wrap(
  //         spacing: 10,
  //         children: colors.map((color) => _buildColorOption(color)).toList(),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildColorOption(String color) {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         selectedColor = color;
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.brown, width: 2),
  //         borderRadius: BorderRadius.circular(8),
  //         color: selectedColor == color ? Colors.brown.withOpacity(0.2) : null,
  //       ),
  //       child: Text(
  //         color,
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  Map<String, Color> colorMap = {
    "Blue": Colors.blue,
    "Light Blue": Colors.lightBlue,
    "Dark Blue": Colors.blueAccent,
    "Yellow": Colors.yellow,
    "Light Yellow": Color(0xFFFFFF99), // Custom light yellow
    "Gold": Color(0xFFFFD700),
    "White": Colors.white,
    "Black": Colors.black,
    "Grey": Colors.grey,
    "Dark Grey": Colors.black54,
    "Light Grey": Colors.grey[300]!,
    "Red": Colors.red,
    "Dark Red": Colors.redAccent,
    "Pink": Colors.pink,
    "Hot Pink": Color(0xFFFF69B4),
    "Magenta": Colors.pinkAccent,
    "Orange": Colors.orange,
    "Dark Orange": Colors.deepOrange,
    "Light Orange": Color(0xFFFFCC80),
    "Purple": Colors.purple,
    "Dark Purple": Colors.deepPurple,
    "Lavender": Color(0xFFE6E6FA),
    "Violet": Color(0xFF8A2BE2),
    "Indigo": Colors.indigo,
    "Green": Colors.green,
    "Light Green": Colors.lightGreen,
    "Dark Green": Colors.greenAccent,
    "Teal": Colors.teal,
    "Turquoise": Color(0xFF40E0D0),
    "Cyan": Colors.cyan,
    "Beige": Color(0xFFF5F5DC),
    "Brown": Colors.brown,
    "Maroon": Color(0xFF800000),
    "Olive": Color(0xFF808000),
    "Silver": Color(0xFFC0C0C0),
    "Tan": Color(0xFFD2B48C),
    "Peach": Color(0xFFFFDAB9),
    "Coral": Color(0xFFFF7F50),
    "Sky Blue": Color(0xFF87CEEB),
    "Azure": Color(0xFF007FFF),
    "Sea Green": Color(0xFF2E8B57),
    "Forest Green": Color(0xFF228B22),
    "Lime": Colors.lime,
    "Rose": Color(0xFFFF007F),
    "Crimson": Color(0xFFDC143C),
    "Chocolate": Color(0xFFD2691E),
    "Mint": Color(0xFF98FF98),
    "Navy": Colors.blue[900]!,
  };

// String? selectedColor;

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
    bool isSelected = selectedColor == color;
    Color displayColor =
        colorMap[color] ?? Colors.grey; // Use mapped color or default to grey

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: displayColor,
          border: Border.all(
              color: isSelected ? Colors.black : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(50),
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
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: selectedSize == size ? Colors.black.withOpacity(0.2) : null,
        ),
        child: Text(
          size,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String getImageUrl(String imagePath) {
    return imagePath;
    // return '$baseUrl/products/fetch-product-image/${imagePath.split('/').last}';
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
        NotifiService().showNotification(
          title: "Product!",
          body: "Item added to cart",
        );

        await _loadUnreadCount();
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
