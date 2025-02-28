// import 'package:flutter/material.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);

//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final List<String> _recentSearches = ["Wilcox", "Kevin"];
//   final List<Map<String, dynamic>> _lastViewedItems = [
//     {
//       'name': 'Wilcox',
//       'type': 'Dresses',
//       'price': '\$85.88',
//       'image': 'assets/overcost/o1-min.jpeg',
//       'color': Colors.brown,
//       'size': 'XS',
//     },
//     {
//       'name': 'Karen Willis',
//       'type': 'Dresses',
//       'price': '\$142',
//       'image': 'assets/overcost/o1-min.jpeg',
//       'color': Colors.brown,
//       'size': 'XS',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//         title: const Text(
//           'Search',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search Bar
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search',
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 CircleAvatar(
//                   backgroundColor: Colors.grey[200],
//                   child: IconButton(
//                     icon: const Icon(Icons.filter_alt_outlined,
//                         color: Colors.black),
//                     onPressed: () {
//                       // Add filter logic here
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Recent Search Section
//             _buildSectionHeader('Recent Search', () {
//               setState(() {
//                 _recentSearches.clear();
//               });
//             }),
//             const SizedBox(height: 8),
//             _buildRecentSearches(),

//             const Divider(height: 32, color: Colors.grey),

//             // Last Viewed Section
//             _buildSectionHeader('Last Viewed', () {
//               setState(() {
//                 _lastViewedItems.clear();
//               });
//             }),
//             const SizedBox(height: 8),
//             Expanded(child: _buildLastViewedItems()),
//           ],
//         ),
//       ),
//     );
//   }

//   // Section Header
//   Widget _buildSectionHeader(String title, VoidCallback onClear) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         GestureDetector(
//           onTap: onClear,
//           child: const Text(
//             'Clear All',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.brown,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Recent Searches
//   Widget _buildRecentSearches() {
//     return _recentSearches.isEmpty
//         ? const Center(
//             child: Text(
//               'No recent searches.',
//               style: TextStyle(color: Colors.grey),
//             ),
//           )
//         : Column(
//             children: _recentSearches
//                 .map((search) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.history,
//                               size: 20, color: Colors.grey),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               search,
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _recentSearches.remove(search);
//                               });
//                             },
//                             child: const Icon(Icons.close,
//                                 size: 16, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ))
//                 .toList(),
//           );
//   }

//   // Last Viewed Items
//   Widget _buildLastViewedItems() {
//     return _lastViewedItems.isEmpty
//         ? const Center(
//             child: Text(
//               'No last viewed items.',
//               style: TextStyle(color: Colors.grey),
//             ),
//           )
//         : ListView.builder(
//             itemCount: _lastViewedItems.length,
//             itemBuilder: (context, index) {
//               final item = _lastViewedItems[index];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       // Image
//                       ClipRRect(
//                         borderRadius: const BorderRadius.horizontal(
//                             left: Radius.circular(12)),
//                         child: Image.asset(
//                           item['image'],
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(width: 8),

//                       // Details
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 8),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${item['name']} | ${item['type']}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 item['price'],
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.brown,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   const Text(
//                                     'Color:',
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.grey),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   CircleAvatar(
//                                     backgroundColor: item['color'],
//                                     radius: 8,
//                                   ),
//                                   const SizedBox(width: 16),
//                                   const Text(
//                                     'Size:',
//                                     style: TextStyle(
//                                         fontSize: 12, color: Colors.grey),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     item['size'],
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Remove Button
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.grey),
//                         onPressed: () {
//                           setState(() {
//                             _lastViewedItems.removeAt(index);
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _minPriceController = TextEditingController();
//   final TextEditingController _maxPriceController = TextEditingController();

//   List<String> selectedColors = [];
//   List<String> selectedSizes = [];
//   String? selectedCategory;
//   String? selectedBrand;
//   String? selectedGender;
//   String? selectedAgeCategory;
//   double? rating = 4.0;
//   String? sortByPrice = 'asc';
//   String? baseUrl = dotenv.env['BASE_URL'];

//   List<Map<String, dynamic>> categories = [];
//   List<String> brands = [];
//   List<String> colors = [];
//   List<String> sizes = [];
//   List<String> genders = [];
//   List<String> ageCategories = [];

//   // Method to fetch filter options (categories, brands, colors, etc.) from the backend
//   Future<void> _fetchFilterOptions() async {
//     try {
//       final response = await http
//           .get(Uri.parse('$baseUrl/products/search-products-for-searchpage'));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         setState(() {
//           categories = List<Map<String, dynamic>>.from(
//               data['categories'].map((category) => {
//                     "_id": category['name'],
//                     "name": category['name'],
//                   }));

//           brands = List<String>.from(data['brands']);
//           colors = List<String>.from(data['colors']);
//           sizes = List<String>.from(data['sizes']);
//           genders = List<String>.from(data['genders']);
//           ageCategories = List<String>.from(data['ageCategories']);
//         });
//       } else {
//         print('Error fetching filter options');
//       }
//     } catch (error) {
//       print('Error fetching filter options: $error');
//     }
//   }

//   // Method to fetch filtered products from the backend
//   Future<void> _getFilteredProducts() async {
//     final Uri uri = Uri.parse('$baseUrl/products/search-products?' +
//         'search=${_searchController.text.trim()}&' +
//         'category=$selectedCategory&' +
//         'brand=$selectedBrand&' +
//         'minPrice=${_minPriceController.text.trim()}&' +
//         'maxPrice=${_maxPriceController.text.trim()}&' +
//         'colors=${selectedColors.join(',')}&' +
//         'sizes=${selectedSizes.join(',')}&' +
//         'gender=$selectedGender&' +
//         'ageCategory=$selectedAgeCategory&' +
//         'rating=$rating&' +
//         'sortByPrice=$sortByPrice&' +
//         'page=1&' +
//         'limit=10');

//     final response = await http.get(uri);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       // Process the filtered product data
//       print(data);
//     } else {
//       print('Error fetching filtered products');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchFilterOptions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Search Products')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: categories.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Search bar at the top
//                     TextField(
//                       controller: _searchController,
//                       decoration: const InputDecoration(
//                         labelText: 'Search for products',
//                         hintText: 'Enter product name or keyword',
//                         prefixIcon: Icon(Icons.search),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Category filter
//                     DropdownButton<String>(
//                       value: selectedCategory,
//                       hint: const Text('Select Category'),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedCategory = newValue;
//                         });
//                       },
//                       items: categories.map((category) {
//                         return DropdownMenuItem<String>(
//                           value: category["_id"],
//                           child: Text(category["name"]!),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // Brand filter
//                     DropdownButton<String>(
//                       value: selectedBrand,
//                       hint: const Text('Select Brand'),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedBrand = newValue;
//                         });
//                       },
//                       items: brands.map((brand) {
//                         return DropdownMenuItem<String>(
//                           value: brand,
//                           child: Text(brand),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // Color filter
//                     Text('Select Colors:'),
//                     Wrap(
//                       children: colors.map((color) {
//                         return ChoiceChip(
//                           label: Text(color),
//                           selected: selectedColors.contains(color),
//                           onSelected: (isSelected) {
//                             setState(() {
//                               if (isSelected) {
//                                 selectedColors.add(color);
//                               } else {
//                                 selectedColors.remove(color);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // Size filter
//                     Text('Select Sizes:'),
//                     Wrap(
//                       children: sizes.map((size) {
//                         return ChoiceChip(
//                           label: Text(size),
//                           selected: selectedSizes.contains(size),
//                           onSelected: (isSelected) {
//                             setState(() {
//                               if (isSelected) {
//                                 selectedSizes.add(size);
//                               } else {
//                                 selectedSizes.remove(size);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // Price filter
//                     TextField(
//                       controller: _minPriceController,
//                       decoration: const InputDecoration(
//                         labelText: 'Min Price',
//                         hintText: 'Enter minimum price',
//                       ),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _maxPriceController,
//                       decoration: const InputDecoration(
//                         labelText: 'Max Price',
//                         hintText: 'Enter maximum price',
//                       ),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 16),

//                     // Gender filter
//                     DropdownButton<String>(
//                       value: selectedGender,
//                       hint: const Text('Select Gender'),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedGender = newValue;
//                         });
//                       },
//                       items: genders.map((gender) {
//                         return DropdownMenuItem<String>(
//                           value: gender,
//                           child: Text(gender),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // Age Category filter
//                     DropdownButton<String>(
//                       value: selectedAgeCategory,
//                       hint: const Text('Select Age Category'),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedAgeCategory = newValue;
//                         });
//                       },
//                       items: ageCategories.map((ageCategory) {
//                         return DropdownMenuItem<String>(
//                           value: ageCategory,
//                           child: Text(ageCategory),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // Rating filter
//                     Slider(
//                       value: rating ?? 4.0,
//                       min: 0,
//                       max: 5,
//                       divisions: 5,
//                       label: '$rating',
//                       onChanged: (newRating) {
//                         setState(() {
//                           rating = newRating;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // Apply filter button
//                     ElevatedButton(
//                       onPressed: _getFilteredProducts,
//                       child: const Text('Apply Filters'),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'product_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> categories = [];
  List<dynamic> products = [];
  String? selectedCategory;
  String selectedGender = '';
  List<String> selectedColors = [];
  List<String> selectedSizes = [];
  String sortOption = 'price_asc';
  String? baseUrl = dotenv.env['BASE_URL'];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  ScrollController _scrollController = ScrollController();
  String? selectedPriceRange;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);
    final response =
        await http.get(Uri.parse('$baseUrl/category/fetch-all-categories'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        categories = jsonResponse['data'];
      });
    }
    setState(() => isLoading = false);
  }

  // Future<void> fetchProducts() async {
  //   if (isLoading || !hasMore) return;
  //   setState(() => isLoading = true);

  //   try {
  //     String url = '$baseUrl/products/search-products?';
  //     if (selectedCategory != null) url += 'categoryId=$selectedCategory&';
  //     if (selectedGender.isNotEmpty) url += 'gender=$selectedGender&';
  //     if (selectedColors.isNotEmpty)
  //       url += 'color=${selectedColors.join(',')}&';
  //     if (selectedSizes.isNotEmpty) url += 'size=${selectedSizes.join(',')}&';
  //     if (selectedPriceRange != null) url += 'priceRange=$selectedPriceRange&';
  //     url += 'sort=$sortOption&page=$page&limit=10';

  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       if (jsonResponse.containsKey('products') &&
  //           jsonResponse['products'] != null) {
  //         List<dynamic> newProducts = jsonResponse['products'];

  //         setState(() {
  //           isLoading = false;
  //           if (newProducts.isEmpty) hasMore = false;

  //           products.addAll(newProducts.map((product) => {
  //                 'id': product['_id'] ?? '',
  //                 'name': product['name'] ?? 'Unknown',
  //                 'description':
  //                     product['description'] ?? 'No description available',
  //                 'category':
  //                     product['category'] ?? '', // Assuming it's an ObjectId
  //                 'brand': product['brand'] ?? 'Unknown',
  //                 'original_price': product['original_price'] ?? 0.0,
  //                 'discount_percentage': product['discount_percentage'] ?? 0.0,
  //                 'color': List<String>.from(
  //                     product['color'] ?? []), // Ensure it's a list of strings
  //                 'sizes': List<String>.from(
  //                     product['sizes'] ?? []), // Ensure it's a list of strings
  //                 'stock_quantity': product['stock_quantity'] ?? 0,
  //                 'images': (product['images'] is List &&
  //                         product['images'].isNotEmpty)
  //                     ? product['images']
  //                     : [], // Ensure it's always a list
  //                 'gender': product['gender'] ?? '',
  //                 'age_category': product['age_category'] ?? '',
  //                 'similar_products': List<String>.from(
  //                     product['similar_products'] ??
  //                         []), // Ensure it's a list of strings
  //                 'rating': product['rating'] ?? 0,
  //                 'deliveryOption':
  //                     product['deliveryOption'] ?? 'No Delivery Option',
  //               }));
  //           page++;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching products: $e');
  //   }

  //   setState(() => isLoading = false);
  // }
  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading || (!hasMore && !reset)) return; // Prevent duplicate requests

    if (reset) {
      setState(() {
        isLoading = true; // Show loader only for new filter selection
        products.clear(); // Clear old data when new filters are applied
        hasMore = true; // Reset pagination flag
        page = 1; // Reset page count
      });
    } else {
      setState(() {
        isLoading = true; // Show loader for pagination (next page load)
      });
    }

    try {
      String url = '$baseUrl/products/search-products?';
      if (selectedCategory != null) url += 'categoryId=$selectedCategory&';
      if (selectedGender.isNotEmpty) url += 'gender=$selectedGender&';
      if (selectedColors.isNotEmpty)
        url += 'color=${selectedColors.join(',')}&';
      if (selectedSizes.isNotEmpty) url += 'size=${selectedSizes.join(',')}&';
      if (selectedPriceRange != null) url += 'priceRange=$selectedPriceRange&';
      url += 'sort=$sortOption&page=$page&limit=10';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> newProducts = jsonResponse['products'] ?? [];

        setState(() {
          if (reset) {
            products = newProducts;
          } else {
            products.addAll(newProducts);
          }

          hasMore = newProducts.length == 10; // Check if more pages exist
          page++;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    }

    setState(() {
      isLoading = false; // Ensure loading is stopped
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchProducts();
    }
  }

  Widget buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: TextStyle(fontSize: 16)),
              onChanged: onChanged,
              isExpanded: true,
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return buildDropdown(
      hint: "Select Gender",
      value: selectedGender.isEmpty
          ? 'Male'
          : selectedGender, // Default to 'Male' if empty
      items: [
        DropdownMenuItem<String>(
          value: 'Male',
          child: Text("Male"),
        ),
        DropdownMenuItem<String>(
          value: 'Female',
          child: Text("Female"),
        ),
        DropdownMenuItem<String>(
          value: 'Unisex',
          child: Text("Unisex"),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedGender = value ?? 'Male'; // Default to 'Male' if null
          products.clear();
          page = 1;
          hasMore = true;
        });
        fetchProducts();
      },
    );
  }

  Widget buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10), // Added margin
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory?.isNotEmpty == true
                ? selectedCategory
                : (categories.isNotEmpty ? categories[0]['_id'] : ''),
            decoration: InputDecoration(
              border: InputBorder.none, // Remove default underline
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            style: TextStyle(fontSize: 16, color: Colors.black),
            dropdownColor: Colors.white,
            hint: Text("Select Category", style: TextStyle(color: Colors.grey)),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['_id'] ?? '',
                child: Row(
                  children: [
                    Icon(Icons.category,
                        color: const Color.fromARGB(255, 255, 68, 68),
                        size: 18),
                    SizedBox(width: 10),
                    Text(category['name'] ?? 'Unknown'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                products.clear();
                page = 1;
                hasMore = true;
              });
              fetchProducts();
            },
          ),
        ),
        SizedBox(height: 10), // Added spacing below dropdown
      ],
    );
  }

  Widget buildPriceRangeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10), // Added margin
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedPriceRange ?? 'under_40000',
            decoration: InputDecoration(
              border: InputBorder.none, // Remove default underline
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            icon: Icon(Icons.price_check, color: Colors.green),
            style: TextStyle(fontSize: 16, color: Colors.black),
            dropdownColor: Colors.white,
            hint: Text("Select Price Range",
                style: TextStyle(color: Colors.grey)),
            items: [
              DropdownMenuItem<String>(
                value: 'under_40000',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward,
                        color: Colors.blueAccent, size: 18),
                    SizedBox(width: 10),
                    Text("Under 40000"),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'above_50000',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.redAccent, size: 18),
                    SizedBox(width: 10),
                    Text("Above 50000"),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedPriceRange = value ?? 'under_40000';
                products.clear();
                page = 1;
                hasMore = true;
              });
              fetchProducts();
            },
          ),
        ),
        SizedBox(height: 10), // Added spacing below dropdown
      ],
    );
  }

  Widget buildProductList() {
    if (isLoading && products.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(child: Text("No products found"));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: products.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length && hasMore) {
          return Center(child: CircularProgressIndicator());
        }

        var product = products[index];
        String imageUrl =
            (product['images'] is List && product['images'].isNotEmpty)
                ? product['images'][0]
                : '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Stack(
              children: [
                // Product Image
                Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 50,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        size: Size(double.infinity,
                            50), // Adjust height of the overlay
                        painter: BoxOverlayPainter(),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Brand: ${product['brand'] ?? 'N/A'}",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Price: ₹${product['original_price']}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      print("Image path is empty or null!");
      return ''; // Return empty if there's no valid image
    }
    print("Fetching Image URL for: $imagePath");
    return '$baseUrl/products/fetch-product-image/${imagePath.split('/').last}';
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text("Search Products")),
  //     body: Column(
  //       children: [
  //         if (isLoading && categories.isEmpty)
  //           Center(child: CircularProgressIndicator()),
  //         buildCategoryDropdown(),
  //         buildPriceRangeDropdown(),
  //         buildGenderDropdown(), // Add gender filter dropdown here
  //         Expanded(
  //             child: isLoading && products.isEmpty
  //                 ? Center(child: CircularProgressIndicator())
  //                 : buildProductList()),
  //       ],
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Products",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white, // White AppBar background
        elevation: 1, // Medium drop shadow
        shadowColor: Colors.black26,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white, // White background for the entire screen
      body: Column(
        children: [
          buildCategoryDropdown(),
          buildPriceRangeDropdown(),
          // buildGenderDropdown(),
          Expanded(child: buildProductList()),
        ],
      ),
    );
  }
}

class BoxOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5) // Semi-transparent overlay
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: Radius.circular(10), // Rounded top-left corner
      bottomLeft: Radius.circular(10), // Rounded bottom-left corner
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
