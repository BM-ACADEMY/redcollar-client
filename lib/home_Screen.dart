import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/productTypesScreen.dart';
import 'package:flutter_application_1/service/notifi_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'clothes_Screen.dart';
import 'profile_Page.dart';
import 'search.dart';
import 'favorites_Page.dart';
import 'cart_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'product_details.dart';
import 'dart:math';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final String username;
  final String userId;
  const HomeScreen(
      {Key? key,
      required this.username,
      required bool isAdmin,
      required this.userId,
      required email})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int unreadCount = 0;
  String lastNotificationMessage = 'No new notifications';
  bool showDropdown = false;
  final List<Widget> _pages = [];
  static String? baseUrl = dotenv.env['BASE_URL'];

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    int count = await NotifiService().getUnreadCount();
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

  Future<void> _loadMessage() async {
    try {
      // Fetch today's notifications from backend
      final response =
          await http.get(Uri.parse('$baseUrl/promotions/notifications/todays'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          showDropdown = !showDropdown;
        });
        if (data['promotions'] != null && data['promotions'].isNotEmpty) {
          setState(() {
            lastNotificationMessage = data['promotions'][0]['message'] ??
                'No new notifications for today';
          });
          _resetUnreadCount();
          // setState(() {
          //   unreadCount = 0;
          // });
        } else {
          setState(() {
            unreadCount = 0;
            lastNotificationMessage = 'No promotions for today';
          });
        }
      } else {
        throw Exception('Failed to fetch today\'s promotions');
      }
    } catch (e) {
      print('Error fetching today\'s promotions: $e');
    }
  }

  // Future<void> _resetUnreadCount() async {
  //   try {
  //     await NotifiService().resetUnreadCount();
  //     // setState(() {
  //     //   unreadCount = 0;
  //     // });
  //     setState(() {
  //       unreadCount = 0;
  //     });
  //   } catch (e) {
  //     print('Error resetting unread count: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(
          username: widget.username,
          unreadCount: unreadCount,
          lastNotificationMessage: lastNotificationMessage,
          onResetUnread: _loadMessage,
          onToggleDropdown: () {
            setState(() {
              showDropdown = !showDropdown;
            });
          },
          showDropdown: showDropdown,
          reset: _resetUnreadCount),
      SearchScreen(),
      FavoritesPage(),
      const CartScreen(cart: []),
      ProfileScreen(
        username: '',
        email: '',
        phoneNumber: '',
      ),
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false, // Hide unselected labels
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ), // Style only the active label
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
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String username;
  final int unreadCount;
  final VoidCallback onResetUnread;
  static String? baseUrl = dotenv.env['BASE_URL'];
  final String lastNotificationMessage;
  final VoidCallback onToggleDropdown;
  final bool showDropdown;
  final VoidCallback reset;
  String generateImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/300x200'; // ✅ Placeholder if image is missing
    }
    List<String> parts = imagePath.split('/');
    String filename = parts.last;
    String finalUrl = '$baseUrl/promotions/get-image/$filename';

    print("Generated URL: $finalUrl");
    return finalUrl;
  }

  // ignore: unused_element
  const _HomeContent(
      {Key? key,
      required this.username,
      required this.unreadCount,
      required this.onResetUnread,
      required this.onToggleDropdown,
      required this.showDropdown,
      required this.lastNotificationMessage,
      required this.reset})
      : super(key: key);

  // Fetch carousel data from the API
  Future<Map<String, dynamic>> fetchCarouselItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/promotions-last-data'),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          final item = jsonData['data'];
          return {
            'image': item['Image'] ?? '',
            'title': item['title'] ?? 'No Title',
            'message': item['message'] ?? 'No Message', // Include message field
          };
        } else {
          throw Exception('Invalid response format: Missing "data" key');
        }
      } else {
        throw Exception(
            'Failed to load promotion data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching promotion data: $e");
      throw Exception('Failed to load promotion data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centers elements in the main axis
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Centers elements in the cross axis
                    children: [
                      Text(
                        'Hi $username',
                        style: GoogleFonts.rubik(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5), // Add spacing between texts
                      // Text(
                      //   'R & C',

                      //   style: GoogleFonts.rubik(
                      //     color: Color(0xFFFE0000),
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Get popular fashion from everywhere',
                    style: TextStyle(
                      color: Color.fromARGB(255, 182, 182, 182),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Icons for Notification and Shopping Cart
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        color: Colors.black,
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          onResetUnread();
                          // onToggleDropdown(); // Call the reset unread count function
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // if (showDropdown == true)
                      //   Positioned(
                      //     right: 6,
                      //     bottom: 6,
                      //     child: IconButton(
                      //       icon: const Icon(Icons.close, color: Colors.red),
                      //       onPressed: () {
                      //         reset();
                      //       },
                      //     ),
                      //   ),
                    ],
                  ),
                ],
              )
            ],
          ),
          if (showDropdown)
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Text(lastNotificationMessage),
            ),
          const SizedBox(height: 16),

          // Search Bar with Voice Button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      iconColor: Colors.brown,
                    ),
                    enabled: false, // Disable typing since it only navigates
                  ),
                ),
              ),

              const SizedBox(width: 8),
              // CircleAvatar(
              //   backgroundColor: Colors.grey[200],
              //   child: IconButton(
              //     icon: const Icon(Icons.mic, color: Colors.black),
              //     onPressed: () {
              //       // Add voice search logic
              //     },
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTextOption('RECOMMEND'),
                  _buildTextOption('NEW'),
                  _buildTextOption('COLLECTION'),
                  _buildTextOption('POPULAR'),
                ],
              )),
          const SizedBox(height: 16),

          // Carousel Section
          _buildCarousel(),
          _buildTypesGrid(context),
          // New Arrival Section
          _buildNewArrivals(),
          const SizedBox(height: 16),

          // Categories Section
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Applied custom color
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.black, // Applied same color to the icon
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Product Grid Section
          _buildProductGrid(context),
        ],
      ),
    );
  }

  // Function to build carousel widget
  Widget _buildCarousel() {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCarouselItems(),
      builder: (context, snapshot) {
        print("Snapshot Connection State: ${snapshot.connectionState}");
        print("Snapshot Data: ${snapshot.data}");
        print("Snapshot Has Data: ${snapshot.hasData}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Center(child: Text('No promotions available'));
        } else {
          final promotion = snapshot.data!;

          return Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(promotion['image'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45, // Semi-transparent background
                borderRadius: BorderRadius.circular(10), // Add border radius
              ),
              padding: const EdgeInsets.all(
                  12), // Add some padding for better appearance
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      promotion['title'] ?? 'No Title',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 8), // Space between title and message
                    Text(
                      promotion['message'] ?? 'No Message',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchNewArrivals() async {
    final url = Uri.parse('$baseUrl/products/fetch-product-new-arrival');

    try {
      final response = await http.get(url);
      print(response);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load new arrivals');
      }
    } catch (e) {
      print('Error fetching new arrivals: $e');
      return [];
    }
  }

  Widget _buildNewArrivals() {
    return FutureBuilder(
      future: fetchNewArrivals(),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No new arrivals found"));
        }

        final newArrivals = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 16), // Add space before the row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Arrival',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Applied custom color
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.black, // Applied same color to the icon
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 190, // ✅ Increased height to accommodate the overlay
              child: ListView.separated(
                padding:
                    const EdgeInsets.only(bottom: 20), // ✅ Added bottom padding
                scrollDirection: Axis.horizontal,
                itemCount: newArrivals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = newArrivals[index];

                  // ✅ Get image URL safely
                  // final imageUrl = getProductImageUrl(
                  //   (item['images'] != null && item['images'].isNotEmpty)
                  //       ? item['images'][0]
                  //       : null,
                  // );
                  final imageUrl =
                      (item['images'] != null && item['images'].isNotEmpty)
                          ? item['images'][0]
                          : null;

                  // ✅ Extract and handle null values safely
                  final name = item['name'] ?? "Unnamed Product";
                  final category =
                      item['category']?['name'] ?? "Unknown Category";
                  final originalPrice = item['original_price'] ?? 0;
                  final discount = item['discount_percentage'] ?? 0;
                  final discountedPrice =
                      originalPrice - (originalPrice * (discount / 100));

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: item),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 220,
                      height: 100,
                      child: Card(
                        color: Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Stack(
                          clipBehavior: Clip
                              .none, // ✅ Ensures overflow content is visible
                          children: [
                            // ✅ Full-width & full-height image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey),
                              ),
                            ),

                            // ✅ Overlay Product Details
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom:
                                  -10, // ✅ Adjusted position to show more of the overlay
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ✅ Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            category,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '₹${discountedPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // ✅ Shopping Bag Icon
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          // Add to cart logic
                                        },
                                        icon: const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: Color(0xFFFE0000)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildProductGrid(BuildContext context) {
  //   return FutureBuilder(
  //     future: fetchCategories(), // Fetching categories data
  //     builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text('Failed to load categories'));
  //       } else {
  //         final categories = snapshot.data ?? [];
  //         return GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 3,
  //             crossAxisSpacing: 16,
  //             mainAxisSpacing: 16,
  //             childAspectRatio: 3 / 4,
  //           ),
  //           itemCount: categories.length,
  //           itemBuilder: (context, index) {
  //             final category = categories[index];
  //             return GestureDetector(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => ClothesSectionPage(
  //                       category: category['name'],
  //                       documentId: category['_id'],
  //                       collectionName: category['name'].toLowerCase(),
  //                     ),
  //                   ),
  //                 );
  //               },
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(12),
  //                   image: DecorationImage(
  //                     image: NetworkImage(getImageUrl(category['images'])),
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //                 alignment: Alignment.center,
  //                 child: Container(
  //                   color: Colors.black54,
  //                   padding: EdgeInsets.all(8),
  //                   child: Text(
  //                     category['name'],
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       }
  //     },
  //   );
  // }
  Widget _buildProductGrid(BuildContext context) {
    return FutureBuilder(
      future: fetchCategories(), // Fetch categories data
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load categories'));
        } else {
          final categories = snapshot.data ?? [];
          return Column(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20), // Gap between items
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClothesSectionPage(
                          category: category['name'],
                          documentId: category['_id'],
                          collectionName: category['name'].toLowerCase(),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      // 🌟 Background Gradient Stack
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.red,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(4, 6),
                            ),
                          ],
                        ),
                      ),

                      // Upper Stack with Image
                      Positioned(
                        top: 10, // Makes bottom gradient visible
                        left: 0, // Makes right gradient visible
                        right: 10,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              // Image
                              Image.network(
                                category['images'] ??
                                    'https://via.placeholder.com/250',
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              ),

                              // Overlay Gradient on Image
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),

                              // Category Name on Top of Image
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      // borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      category['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category/fetch-all-categories'),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('data')) {
          return jsonData['data']; // ✅ Correctly extract "data" field
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> fetchTypes() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/types/get-all-types-for-types'));

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List) {
          return jsonData; // ✅ API returns a list directly
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load types');
      }
    } catch (e) {
      print("Error fetching types: $e");
      throw Exception('Failed to load types');
    }
  }

  Widget _buildTypesGrid(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchTypes(),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Failed to load types'));
        } else {
          final types = snapshot.data ?? [];
          final Random random = Random();

          return Column(
            children: types.asMap().entries.map((entry) {
              int index = entry.key;
              var type = entry.value;
              int randomPrice = random.nextInt(3001) + 2000;

              // Randomly generate position offsets
              double randomTop = random.nextDouble() * 20;
              double randomLeft = random.nextDouble() * 20;
              double randomBottom = random.nextDouble() * 20;
              double randomRight = random.nextDouble() * 20;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductTypesScreen(
                          typeId: type['_id'],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none, // Allows elements to overflow
                    children: [
                      // 🌟 Main Rectangle Shape 🌟
                      Container(
                        height: 400,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.red],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(4, 6),
                            ),
                          ],
                        ),
                      ),

                      // 🎨 Small Randomly Positioned Shapes 🎨
                      for (int i = 0; i < 5; i++) _buildWaterBubbleShape(),

                      // 🖼 Image & Overlay (Random Positions)
                      Positioned(
                        top: randomTop,
                        left: randomLeft,
                        right: randomRight,
                        bottom: randomBottom,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Image.network(
                                type['image'] ??
                                    'https://via.placeholder.com/250',
                                width: double.infinity,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      type['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Lobster',
                                      ),
                                    ),
                                    Text(
                                      type['description'] ?? 'No description',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontFamily: 'Raleway',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 🔲 Price Overlay with Black Background 🔲
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            "₹$randomPrice",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150'; // ✅ Placeholder image for safety
    }
    List<String> splitPath = imagePath.split('/');
    String imageName = splitPath.last;
    return '$baseUrl/category/fetch-category-image/$imageName';
  }

  String getProductImageUrl(String imagePath) {
    return '$baseUrl/products/fetch-product-image/${imagePath.split('/').last}';
  }

  Widget _buildTextOption(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class CurvedRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.1);
    path.lineTo(size.width, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.5, size.height, 0, size.height * 0.9);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SoftEdgeRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(10, 0);
    path.lineTo(size.width - 10, 0);
    path.quadraticBezierTo(size.width, 10, size.width, 20);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
        size.width, size.height - 10, size.width - 10, size.height);
    path.lineTo(10, size.height);
    path.quadraticBezierTo(0, size.height - 10, 0, size.height - 20);
    path.lineTo(0, 20);
    path.quadraticBezierTo(0, 10, 10, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// class CircleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path()
//       ..addOval(Rect.fromCircle(
//         center: Offset(size.width / 2, size.height / 2),
//         radius: size.width / 2, // Ensures it remains a circle
//       ));
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2, // Ensures it remains a circle
      ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(0)));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class EllipticalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget _buildWaterBubbleShape() {
  final List<CustomClipper<Path>> bubbleClippers = [
    CircleClipper(),
    EllipticalClipper(),
  ];
  final random = Random();

  return Positioned(
    top: random.nextDouble() * 800 - 300, // Spread farther from main shape
    left: random.nextDouble() * 700 - 300,
    child: Transform.rotate(
      angle: random.nextDouble() * pi, // Random rotation
      child: ClipPath(
        clipper: bubbleClippers[random.nextInt(bubbleClippers.length)],
        child: Stack(
          children: [
            // Glass effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Softer blur
              child: Container(
                height: random.nextDouble() * 40 + 15, // Smaller sizes
                width: random.nextDouble() * 40 + 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3), // Glow in center
                      Colors.white.withOpacity(0.1), // Transparent edges
                    ],
                    stops: [0.4, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5), // Thin glossy edge
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2), // Soft glow
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Small highlight inside bubble
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                height: 7,
                width: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
