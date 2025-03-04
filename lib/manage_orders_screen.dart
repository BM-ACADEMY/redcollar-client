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
import 'package:flutter/services.dart';
import 'package:flutter_application_1/orderConfirmationPage.dart';

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
  final String? baseUrl = dotenv.env['BASE_URL'];
  Map<String, bool> copiedOrderIds = {};

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

  void _copyToClipboard(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId)).then((_) {
      setState(() {
        copiedOrderIds[orderId] = true;
      });

      // Reset icon after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          copiedOrderIds[orderId] = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders',
            style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Border height
          child: Container(
            color: Colors.black26, // Border color
            height: 1.0, // Border thickness
          ),
        ),
        // centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: orders.isEmpty && !isLoading
            ? const Center(
                child: Text(
                  "No orders available",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: orders.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == orders.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                          child: CircularProgressIndicator(color: Colors.red)),
                    );
                  }

                  final order = orders[index];
                  final orderId = order['_id'];
                  final username = order['user']['username'];
                  final productCount = order['products'].length;
                  final totalAmount = order['total_amount'];
                  final paymentStatus = order['payment']['payment_status'];
                  final currentStatus = order['order_status'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID & Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Order ID: $orderId',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Prevents overflow
                                        maxLines: 1,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        copiedOrderIds[orderId] == true
                                            ? Icons.check
                                            : Icons.copy,
                                        color: copiedOrderIds[orderId] == true
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                      onPressed: () =>
                                          _copyToClipboard(orderId),
                                    ),
                                  ],
                                ),
                              ),
                              _statusBadge(currentStatus),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Order Details
                          _orderDetailRow("👤 Username:", username),
                          _orderDetailRow("📦 Product Count:", '$productCount'),
                          _orderDetailRow(
                              "💰 Amount:", '₹${totalAmount.toString()}'),
                          _orderDetailRow("💳 Payment Status:", paymentStatus),

                          const SizedBox(height: 12),

                          // Order Status Dropdown
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              value: _isStatusValid(currentStatus)
                                  ? currentStatus
                                  : 'Confirmed',
                              onChanged: (String? newStatus) {
                                if (newStatus != null) {
                                  _updateOrderStatus(orderId, newStatus);
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                'Confirmed',
                                'Shipped',
                                'Delivered',
                                'Cancelled',
                                'PreparedforDelivery',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Go to Tracking Page Button (Bottom Right)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Button color
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderConfirmationPage()),
                                );
                              },
                              child: const Text(
                                'Go to Tracking Page >>',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Order Status Badge
  Widget _statusBadge(String status) {
    Color statusColor;
    switch (status) {
      case "Shipped":
        statusColor = Colors.blue;
        break;
      case "Delivered":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Order Detail Row
  Widget _orderDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // bool _isStatusValid(String status) {
  //   return ['Confirmed', 'Shipped', 'Delivered', 'Cancelled', 'PreparedforDelivery'].contains(status);
  // }

  // void _updateOrderStatus(String orderId, String newStatus) {
  //   // TODO: Implement status update logic
  //   setState(() {
  //     orders = orders.map((order) {
  //       if (order['_id'] == orderId) {
  //         return {...order, 'order_status': newStatus};
  //       }
  //       return order;
  //     }).toList();
  //   });
  // }
}
