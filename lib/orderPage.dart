import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List orders = [];
  bool isLoading = true;
  final String? baseUrl = dotenv.env['BASE_URL'];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final String url =
        '$baseUrl/orders/update-order-status-admin-page/$orderId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"order_status": newStatus}),
      );

      if (response.statusCode == 200) {
        print("Order status updated successfully.");
      } else {
        print("Failed to update order status: ${response.body}");
      }
    } catch (error) {
      print("Error updating order status: $error");
    }
  }

  Future<void> fetchOrders() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      print("No user logged in.");
      return;
    }

    final String url = '$baseUrl/orders/fetch-order-by-userId/$userId';
    print(url);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          orders = responseData['orders']; // ✅ Extract orders correctly
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load orders: ${response.body}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching orders: $error');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['_id'];
                    final orderStatus = order['order_status'];
                    final userName = order['user']['username'] ??
                        "Unknown"; // Get customer name
                    final productCount =
                        order['products'].length; // Get product count
                    final paymentStatus =
                        order['payment_status'] ?? "Pending"; // Payment status

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.brown, width: 2),
                      ),
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _styledText('Order ID:', orderId),
                            _styledText('Customer Name:', userName),
                            _styledText(
                                'Product Count:', productCount.toString()),
                            _styledText('Payment Status:', paymentStatus),

                            // Dropdown for Order Status
                            Row(
                              children: [
                                const Text('Order Status:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 10),
                                DropdownButton<String>(
                                  value: [
                                    'Pending',
                                    'Processing',
                                    'Shipped',
                                    'Delivered',
                                    'Cancelled'
                                  ].contains(
                                          orderStatus) // Ensure orderStatus is valid
                                      ? orderStatus
                                      : 'Pending', // Default to 'Pending' if invalid

                                  items: [
                                    'Pending',
                                    'Processing',
                                    'Shipped',
                                    'Delivered',
                                    'Cancelled'
                                  ]
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),

                                  onChanged: (newStatus) {
                                    if (newStatus != null) {
                                      setState(() {
                                        orders[index]['order_status'] =
                                            newStatus; // Update UI
                                      });
                                      updateOrderStatus(
                                          orderId, newStatus); // API call
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _styledText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold), // ✅ Bold labels
            ),
            const TextSpan(text: ' '),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
