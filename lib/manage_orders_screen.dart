// import 'package:flutter/material.dart';

// class ManageOrdersScreen extends StatelessWidget {
//   const ManageOrdersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Dummy order data
//     final List<Map<String, dynamic>> orders = [
//       {
//         'id': '1',
//         'date': '2024-12-01',
//         'status': 'Completed',
//         'price': '\$250'
//       },
//       {'id': '2', 'date': '2024-12-02', 'status': 'Pending', 'price': '\$150'},
//       {'id': '3', 'date': '2024-12-03', 'status': 'Shipped', 'price': '\$100'},
//       {'id': '4', 'date': '2024-12-04', 'status': 'Cancelled', 'price': '\$50'},
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Orders'),
//         backgroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: orders.length,
//           itemBuilder: (context, index) {
//             final order = orders[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 8.0),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blue,
//                   child: Text(order['id']),
//                 ),
//                 title: Text('Order ID: ${order['id']}'),
//                 subtitle:
//                     Text('Date: ${order['date']} | Status: ${order['status']}'),
//                 trailing: Text(
//                   order['price'],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 onTap: () {
//                   // Handle order click (e.g., show order details)
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Order ${order['id']} clicked')),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  _ManageOrdersScreenState createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  final String? baseUrl = dotenv.env['BASE_URL']; // Replace with your API URL

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchOrders() async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
          Uri.parse("$baseUrl/orders/fetch-all-orders/?page=$currentPage"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> fetchedOrders = data['orders'];

        setState(() {
          orders.addAll(
              fetchedOrders.map((order) => order as Map<String, dynamic>));
          hasMoreData = fetchedOrders.isNotEmpty;
          if (hasMoreData) currentPage++;
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      _fetchOrders();
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/orders/update-order-status-admin-page/$orderId"),
        body: json.encode({"order_status": newStatus}),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Update the status locally after a successful API call
        setState(() {
          final orderIndex =
              orders.indexWhere((order) => order['_id'] == orderId);
          if (orderIndex != -1) {
            orders[orderIndex]['order_status'] =
                newStatus; // Update status locally
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order status updated")),
        );
      } else {
        throw Exception("Failed to update order status");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}")),
      );
    }
  }

  // Helper function to check if the status is valid
  bool _isStatusValid(String status) {
    final validStatuses = [
      'Confirmed',
      'Shipped',
      'Delivered',
      'Cancelled',
      'PreparedforDelivery',
    ];
    return validStatuses.contains(status);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: orders.isEmpty && !isLoading
            ? const Center(child: Text("No orders available"))
            : ListView.builder(
                controller: _scrollController,
                itemCount: orders.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == orders.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final order = orders[index];
                  final productCount = order['products'].length;
                  final orderId = order['_id'];
                  final username = order['user']['username'];
                  final totalAmount = order['total_amount'];
                  final paymentStatus = order['payment']['payment_status'];
                  final currentStatus = order['order_status'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      // leading: CircleAvatar(
                      //   backgroundColor: Colors.blue,
                      //   child: Text(
                      //     (index + 1).toString(),
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      title: Text(
                        'Order ID: $orderId',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Username:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(username),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Product Count:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('$productCount'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('\₹${totalAmount.toString()}'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment Status:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(paymentStatus),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 150,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _isStatusValid(currentStatus)
                              ? currentStatus
                              : 'Confirmed',
                          onChanged: (String? newStatus) {
                            if (newStatus != null) {
                              _updateOrderStatus(orderId, newStatus);
                            }
                          },
                          items: [
                            'Confirmed',
                            'Shipped',
                            'Delivered',
                            'Cancelled',
                            'PreparedforDelivery',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
