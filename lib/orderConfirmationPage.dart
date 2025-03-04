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
  bool _showTracking = false;
  String? _orderId = '';
  String? _estimatedDate = '';
  final List<Map<String, dynamic>> _trackingSteps = [
    {"title": "Order Placed", "description": "We have received your order."},
    {"title": "Order Confirmed", "description": "Your order is confirmed."},
    {"title": "Shipped", "description": "Your order is on the way!"},
    {"title": "Out for Delivery", "description": "Almost there!"},
    {"title": "Delivered", "description": "Your order has been delivered."},
  ];
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
            _orderId = order['_id'];
            _estimatedDate = order['updatedAt'];
            _updatedAt = updatedAt;
            _currentStep = _getStepFromStatus(_orderStatus);
            _showSteps = true;
            _showTracking = true;
          });
        } else {
          setState(() {
            _orderStatus = "Order not found.";
            _showSteps = false;
            _showTracking = false;
          });
        }
      } else {
        setState(() {
          _orderStatus = "Error fetching status. Please try again.";
          _showSteps = false;
          _showTracking = false;
        });
      }
    } catch (error) {
      setState(() {
        _orderStatus = "An error occurred: ${error.toString()}";
        _showSteps = false;
        _showTracking = false;
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
      backgroundColor: Colors.white, // Light grey background
      appBar: AppBar(
        title: const Text(
          'Track Your Order',
          style: TextStyle(fontSize: 16),
        ),
        // centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Border height
          child: Container(
            color: Colors.black26, // Border color
            height: 1.0, // Border thickness
          ),
        ),
        // elevation: 4,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Fields
            _buildInputField(_emailController, "Enter Email"),
            const SizedBox(height: 12),
            _buildInputField(_orderIdController, "Enter Order ID"),
            const SizedBox(height: 20),

            // Fetch Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchOrderStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tracking Status Section
            if (_showTracking) _buildTrackingSection(),
          ],
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  String _formatDateWithOffset(String isoDate, int daysToAdd) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      DateTime newDate = parsedDate.add(Duration(days: daysToAdd));
      return "${newDate.day}/${newDate.month}/${parsedDate.year}";
    } catch (e) {
      return "N/A"; // In case of an error
    }
  }

  // Order Tracking Section
  Widget _buildTrackingSection() {
    return Column(
      children: [
        // Order Summary Card
        Card(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _orderInfoRow(
                    "Order ID:", "$_orderId", Icons.confirmation_number),
                _orderInfoRow("Status:", _trackingSteps[_currentStep]["title"],
                    Icons.local_shipping),
                _orderInfoRow(
                    "Order Date:",
                    _formatDateWithOffset("$_estimatedDate", 5),
                    Icons.calendar_today),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Tracking Progress
        Column(
          children: List.generate(_trackingSteps.length, (index) {
            return _trackingStep(
              title: _trackingSteps[index]["title"],
              description: _trackingSteps[index]["description"],
              isActive: index <= _currentStep,
            );
          }),
        ),
      ],
    );
  }

  Widget _orderInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Prevents stretching
        children: [
          Icon(icon, color: Colors.red, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            // Prevents overflow
            child: Text(
              value.length > 10 ? '${value.substring(0, 5)}...' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis, // Prevents breaking layout
              maxLines: 1,
              softWrap: false, // Ensures text stays in one line
            ),
          ),
        ],
      ),
    );
  }

  // Tracking Step Widget
  Widget _trackingStep(
      {required String title,
      required String description,
      required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: isActive ? Colors.red : Colors.grey[300],
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
            if (title != "Order Delivered")
              Container(
                width: 2,
                height: 40,
                color: isActive ? Colors.red : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
