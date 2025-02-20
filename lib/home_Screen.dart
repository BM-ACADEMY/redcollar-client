import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/service/notifi_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'clothes_Screen.dart';
import 'profile_Page.dart';
import 'search.dart';
import 'favorites_Page.dart';
import 'cart_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_details.dart';

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
      showDropdown = false;
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_currentIndex], // Now always up-to-date
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
  Future<List<Map<String, dynamic>>> fetchCarouselItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promotions/promotions-getAll'),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          List<dynamic> data = jsonData['data']; // ✅ Extract 'data' correctly

          return data.map((item) {
            return {
              'image': item['Image'] ?? '', // ✅ Use lowercase 'image'
              'title': item['title'] ?? 'No Title',
            };
          }).toList();
        } else {
          throw Exception('Invalid response format: Missing "data" key');
        }
      } else {
        throw Exception(
            'Failed to load carousel data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching carousel data: $e");
      throw Exception('Failed to load carousel data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section with Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $username', // Dynamic username
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Get popular fashion from everywhere',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
                        color: Colors.brown,
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
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      iconColor: Colors.brown),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.black),
                  onPressed: () {
                    // Add voice search logic
                  },
                ),
              ),
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

          // New Arrival Section
          _buildNewArrivals(),
          const SizedBox(height: 16),

          // Categories Section
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCarouselItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final carouselItems = snapshot.data!;
          return CarouselSlider.builder(
            itemCount: carouselItems.length,
            itemBuilder: (context, index, realIndex) {
              final item = carouselItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        generateImageUrl(item[
                            'image']), // Ensure the correct key is used here
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 20,
                        top: 70,
                        left: 20,
                        child: Text(
                          item['title'], // Ensure the correct key is used here
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              aspectRatio: 16 / 9,
            ),
          );
        }
      },
    );
  }

  Future<List<dynamic>> fetchNewArrivals() async {
    final url = Uri.parse('$baseUrl/products/fetch-product-new-araivel');

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
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No new arrivals found"));
        }

        final newArrivals = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Arrival',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: newArrivals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = newArrivals[index];

                  // ✅ Get image URL safely
                  final imageUrl = getProductImageUrl(
                    (item['images'] != null && item['images'].isNotEmpty)
                        ? item['images'][0]
                        : null,
                  );

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
                          builder: (context) => ProductDetailPage(
                              product: item), // ✅ Pass product to detail page
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 180,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Image Section
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported,
                                          size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                            // ✅ Details Section
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ✅ Product Details with Flex Wrap
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
                                          overflow: TextOverflow
                                              .ellipsis, // ✅ Prevents overflow
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₹${discountedPrice.toStringAsFixed(2)}',
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
                                          color: Colors.black.withOpacity(0.1),
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
                                          color: Colors.brown),
                                    ),
                                  ),
                                ],
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

  Widget _buildProductGrid(BuildContext context) {
    return FutureBuilder(
      future: fetchCategories(), // Fetching categories data
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load categories'));
        } else {
          final categories = snapshot.data ?? [];
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(getImageUrl(category['images'])),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      category['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
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
