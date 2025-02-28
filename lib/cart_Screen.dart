// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'product_provider.dart';
// import 'check_Screen.dart'; // CheckoutScreen file

// class CartScreen extends StatelessWidget {
//   const CartScreen({Key? key, required List cart}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final productProvider = Provider.of<ProductProvider>(context);
//     final cart = productProvider.cart;

//     // Calculate prices
//     double subtotal = cart.fold(
//       0,
//       (sum, item) => sum + (item['price'] * item['quantity']),
//     );
//     double discount = subtotal * 0.1; // 10% Discount
//     double total = subtotal - discount;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.brown),
//         title: const Text(
//           'My Cart',
//           style: TextStyle(
//             color: Colors.brown,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: cart.isEmpty
//           ? _buildEmptyCart()
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: cart.length,
//                     itemBuilder: (context, index) {
//                       final item = cart[index];
//                       return _buildCartItem(context, item, productProvider);
//                     },
//                   ),
//                 ),
//                 // Summary Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const Divider(height: 24, thickness: 1),
//                       _buildPriceRow(
//                           'Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
//                       _buildPriceRow(
//                           'Discount', '-₹${discount.toStringAsFixed(2)}'),
//                       _buildPriceRow('Total', '₹${total.toStringAsFixed(2)}',
//                           isBold: true),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CheckoutScreen(
//                                 cart: cart,
//                                 subtotal: subtotal,
//                                 discount: discount,
//                                 total: total,
//                               ),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           backgroundColor: Colors.brown,
//                         ),
//                         child: const Text(
//                           'Checkout',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildCartItem(BuildContext context, Map<String, dynamic> item,
//       ProductProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: _getImageWidget(item['image']),
//               ),
//               const SizedBox(width: 16),

//               // Product Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product Name
//                     Text(
//                       item['name'] ?? 'Unnamed Item',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // Product Category
//                     Text(
//                       item['category'] ?? 'Category',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Price and Quantity
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '₹${item['price']} x ${item['quantity']}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                         // Quantity Increment/Decrement
//                         Row(
//                           children: [
//                             // Decrement Button
//                             IconButton(
//                               icon: const Icon(Icons.remove_circle,
//                                   color: Colors.grey),
//                               onPressed: () {
//                                 if (item['quantity'] > 1) {
//                                   provider.updateCartQuantity(
//                                       item, item['quantity'] - 1);
//                                 } else {
//                                   provider.removeFromCart(item);
//                                 }
//                               },
//                             ),
//                             Text(
//                               '${item['quantity']}',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             // Increment Button
//                             IconButton(
//                               icon: const Icon(Icons.add_circle,
//                                   color: Colors.brown),
//                               onPressed: () {
//                                 provider.updateCartQuantity(
//                                     item, item['quantity'] + 1);
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.brown),
//           const SizedBox(height: 16),
//           const Text(
//             'Your cart is empty!',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Add some products to the cart.',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getImageWidget(String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return Image.asset(
//         'assets/images/default_image.png',
//         width: 80,
//         height: 80,
//         fit: BoxFit.cover,
//       );
//     }

//     // Check if the image is an asset or a network URL
//     if (imageUrl.startsWith('assets/')) {
//       return Image.asset(
//         imageUrl,
//         width: 80,
//         height: 80,
//         fit: BoxFit.cover,
//       );
//     }

//     // For network images
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       width: 80,
//       height: 80,
//       fit: BoxFit.cover,
//       placeholder: (context, url) => const Center(
//         child: CircularProgressIndicator(),
//       ),
//       errorWidget: (context, url, error) => Image.asset(
//         'assets/images/default_image.png',
//         width: 80,
//         height: 80,
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/provider/userProvider.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'product_provider.dart';
// import 'check_Screen.dart'; // CheckoutScreen file

// class CartScreen extends StatefulWidget {
//   const CartScreen({Key? key, required List cart}) : super(key: key);

//   @override
//   _CartScreenState createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   late String userId;
//   late List<Map<String, dynamic>> cartItems = [];
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Access the UserProvider to get the userId
//     final userProvider = Provider.of<UserProvider>(context);
//     userId = userProvider.userId;
//     _fetchCartData();
//   }

//   Future<void> _fetchCartData() async {
//     final url = 'http://10.0.2.2:6000/api/carts/fetch-cart-by-user/$userId';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final List cartData = json.decode(response.body);
//         print('Fetched Cart Data: $cartData'); // Debugging

//         if (cartData.isNotEmpty) {
//           setState(() {
//             cartItems = List<Map<String, dynamic>>.from(cartData);
//           });
//         }
//       } else {
//         print('Failed to load cart');
//       }
//     } catch (error) {
//       print('Error fetching cart: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productProvider = Provider.of<ProductProvider>(context);
//     final cartItems = productProvider.cart;

//     // Calculate prices dynamically based on the current cart
//     double subtotal = cartItems.fold(
//       0,
//       (sum, item) =>
//           sum + (item['product']['original_price'] * item['quantity']),
//     );
//     double discount = subtotal * 0.1; // 10% Discount
//     double total = subtotal - discount;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.brown),
//         title: const Text(
//           'My Cart',
//           style: TextStyle(
//             color: Colors.brown,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: cartItems.isEmpty
//           ? _buildEmptyCart()
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: cartItems.length,
//                     itemBuilder: (context, index) {
//                       final item = cartItems[index];
//                       return _buildCartItem(context, item, productProvider);
//                     },
//                   ),
//                 ),
//                 // Summary Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const Divider(height: 24, thickness: 1),
//                       _buildPriceRow(
//                           'Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
//                       _buildPriceRow(
//                           'Discount', '-₹${discount.toStringAsFixed(2)}'),
//                       _buildPriceRow('Total', '₹${total.toStringAsFixed(2)}',
//                           isBold: true),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CheckoutScreen(
//                                 cart: cartItems,
//                                 subtotal: subtotal,
//                                 discount: discount,
//                                 total: total,
//                               ),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           backgroundColor: Colors.brown,
//                         ),
//                         child: const Text(
//                           'Checkout',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildCartItem(BuildContext context, Map<String, dynamic> item,
//       ProductProvider provider) {
//     double price = item['product']['original_price'].toDouble();
//     double totalItemPrice = price * item['quantity'];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: CachedNetworkImage(
//                   imageUrl: getImageUrl(item['product']['images'][0]),
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                   errorWidget: (context, url, error) => Image.asset(
//                     'assets/images/default_image.png',
//                     width: 80,
//                     height: 80,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Product Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product Name
//                     Text(
//                       item['product']['name'] ?? 'Unnamed Item',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // Product Category
//                     Text(
//                       item['product']['category'] ?? 'Category',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Price and Quantity
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Total Price for the Item
//                         Text(
//                           '₹${totalItemPrice.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green,
//                           ),
//                         ),
//                         // Quantity Increment/Decrement
//                         Row(
//                           children: [
//                             // Decrement Button
//                             IconButton(
//                               icon: const Icon(Icons.remove_circle,
//                                   color: Colors.grey),
//                               onPressed: () {
//                                 if (item['quantity'] > 1) {
//                                   provider.updateCartQuantity(
//                                       item, item['quantity'] - 1);
//                                 } else {
//                                   provider.removeFromCart(item);
//                                 }
//                               },
//                             ),
//                             Text(
//                               '${item['quantity']}',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             // Increment Button
//                             IconButton(
//                               icon: const Icon(Icons.add_circle,
//                                   color: Colors.brown),
//                               onPressed: () {
//                                 provider.updateCartQuantity(
//                                     item, item['quantity'] + 1);
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // Delete Icon
//               IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.red),
//                 onPressed: () {
//                   // Call the API to delete the item from the cart
//                   provider.removeFromCart(item);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.brown),
//           const SizedBox(height: 16),
//           const Text(
//             'Your cart is empty!',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Add some products to the cart.',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   String getImageUrl(String imagePath) {
//     return 'http://10.0.2.2:6000/api/products/fetch-product-image/${imagePath.split('/').last}';
//   }

//   Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'check_Screen.dart'; // CheckoutScreen file

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key, required List cart}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String userId;
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.userId;
    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    final url = 'http://10.0.2.2:6000/api/carts/fetch-cart-by-user/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List cartData = json.decode(response.body);
        print('Fetched Cart Data: $cartData'); // Debugging

        setState(() {
          cartItems = List<Map<String, dynamic>>.from(cartData);
          isLoading = false;
        });
      } else {
        print('Failed to load cart');
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error fetching cart: $error');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateCartQuantity(String cartItemId, int newQuantity) async {
    final url = 'http://10.0.2.2:6000/api/carts/update-cart/$cartItemId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"quantity": newQuantity}),
      );

      if (response.statusCode == 200) {
        _fetchCartData();
      } else {
        print('Failed to update quantity');
      }
    } catch (error) {
      print('Error updating cart: $error');
    }
  }

  Future<void> _removeFromCart(String cartItemId) async {
    final url = 'http://10.0.2.2:6000/api/carts/delete-cart/$cartItemId';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((item) => item['_id'] == cartItemId);
        });
      } else {
        print('Failed to remove item from cart');
      }
    } catch (error) {
      print('Error removing cart item: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = cartItems.fold(
      0,
      (sum, item) =>
          sum + (item['product']['original_price'] * item['quantity']),
    );
    double discount = subtotal * 0.1; // 10% Discount
    double total = subtotal - discount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4, // Increased elevation for shadow effect
        shadowColor: Colors.black26, // Soft shadow color
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItem(item);
                        },
                      ),
                    ),
                    _buildSummarySection(subtotal, discount, total),
                  ],
                ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    double price = item['product']['original_price'].toDouble();
    double totalItemPrice = price * item['quantity'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  // imageUrl: getImageUrl(item['product']['images'][0]),
                  imageUrl: item['product']['images'][0],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/default_image.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item['product']['name'] ?? 'Unnamed Item',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Selected Color
                    Text(
                      'Color: ${item['selected_color'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Selected Size
                    Text(
                      'Size: ${item['selected_size'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price and Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total Price
                        Text(
                          '₹${totalItemPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        // Quantity Increment/Decrement
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.black),
                              onPressed: () {
                                if (item['quantity'] > 1) {
                                  _updateCartQuantity(
                                      item['_id'], item['quantity'] - 1);
                                } else {
                                  _removeFromCart(item['_id']);
                                }
                              },
                            ),
                            Text('${item['quantity']}',
                                style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.black),
                              onPressed: () {
                                _updateCartQuantity(
                                    item['_id'], item['quantity'] + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete Icon
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _removeFromCart(item['_id']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(double subtotal, double discount, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 24, thickness: 1),
          _buildPriceRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          _buildPriceRow('Discount', '-₹${discount.toStringAsFixed(2)}'),
          _buildPriceRow('Total', '₹${total.toStringAsFixed(2)}', isBold: true),

          const SizedBox(height: 16), // Spacing before button

          // Gradient Checkout Button
          Container(
            decoration: BoxDecoration(
              color: Colors.black, // Black background
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to CheckoutScreen with the required arguments
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      cart: cartItems, // Pass the cart items
                      subtotal: subtotal, // Pass the subtotal
                      discount: discount, // Pass the discount
                      total: total, // Pass the total
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black background
                foregroundColor: Colors.white, // White text
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // 20px border radius
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10), // Padding 10px
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(child: Text('Your cart is empty!'));
  }

  String getImageUrl(String imagePath) {
    return 'http://10.0.2.2:6000/api/products/fetch-product-image/${imagePath.split('/').last}';
  }
}
