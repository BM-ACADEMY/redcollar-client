import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderConfirmationPage extends StatefulWidget {
  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();

  int _currentStep = 0;
  String _orderStatus = "Fetching...";
  String _updatedAt = "";
  bool _showSteps = false;
  String? baseUrl = dotenv.env['BASE_URL'];

  Future<void> _fetchOrderStatus() async {
    final String email = _emailController.text.trim();
    final String orderId = _orderIdController.text.trim();

    if (email.isEmpty || orderId.isEmpty) {
      setState(() {
        _orderStatus = "Please enter both Email and Order ID.";
        _showSteps = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/orders/fetch-order-by-for-tracking?email=$email&orderId=$orderId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['order'] != null) {
          final order = data['order'];
          final updatedAtData = order['updatedAt'];

          String updatedAt = "N/A"; // Default value
          if (updatedAtData is Map && updatedAtData.containsKey('\$date')) {
            final timestamp = updatedAtData['\$date']['\$numberLong'];
            updatedAt = DateTime.fromMillisecondsSinceEpoch(
                    timestamp is int ? timestamp : int.tryParse(timestamp) ?? 0)
                .toString();
          }

          setState(() {
            _orderStatus = order['order_status'];
            _updatedAt = updatedAt;
            _currentStep = _getStepFromStatus(_orderStatus);
            _showSteps = true;
          });
        } else {
          setState(() {
            _orderStatus = "Order not found.";
            _showSteps = false;
          });
        }
      } else {
        setState(() {
          _orderStatus = "Error fetching status. Please try again.";
          _showSteps = false;
        });
      }
    } catch (error) {
      setState(() {
        _orderStatus = "An error occurred: ${error.toString()}";
        _showSteps = false;
      });
    }
  }

  int _getStepFromStatus(String status) {
    switch (status) {
      case 'Confirmed':
        return 1;
      case 'Shipped':
        return 2;
      case 'PreparedforDelivery':
        return 3;
      case 'Delivered':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Order Confirmation get order id from user profile order page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _orderIdController,
              decoration: InputDecoration(labelText: 'Enter Order ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchOrderStatus,
              child: Text('Get Details'),
            ),
            SizedBox(height: 20),
            Text(
              _orderStatus,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _showSteps
                ? Expanded(
                    child: Stepper(
                      currentStep: _currentStep,
                      steps: [
                        Step(
                          title: Text('Order Placed'),
                          content: Text('Your order has been placed.'),
                          isActive: _currentStep >= 0,
                        ),
                        Step(
                          title: Text('Order Confirmed'),
                          content: Text('Your order has been confirmed.'),
                          isActive: _currentStep >= 1,
                        ),
                        Step(
                          title: Text('Order Shipped'),
                          content: Text('Your order has been shipped.'),
                          isActive: _currentStep >= 2,
                        ),
                        Step(
                          title: Text('Prepared for Delivery'),
                          content: Text(
                              'Your order is being prepared for delivery.'),
                          isActive: _currentStep >= 3,
                        ),
                        Step(
                          title: Text('Order Delivered'),
                          content: Text('Your order has been delivered.'),
                          isActive: _currentStep >= 4,
                        ),
                      ],
                    ),
                  )
                : Container(), // Hide stepper initially
          ],
        ),
      ),
    );
  }
}
