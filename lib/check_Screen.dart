// import 'package:flutter/material.dart';
// import 'profile_screen.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({
//     Key? key,
//     required this.cart,
//     required this.discount,
//     required this.subtotal,
//     required this.total,
//   }) : super(key: key);

//   final List<Map<String, dynamic>> cart;
//   final double discount;
//   final double subtotal;
//   final double total;

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _formKey = GlobalKey<FormState>();
//   int _currentStep = 0;

//   // User data
//   final Map<String, String> _addressData = {
//     'fullName': '',
//     'email': '',
//     'phone': '',
//     'address': '',
//     'city': '',
//     'country': ''
//   };

//   final Map<String, String> _paymentData = {
//     'cardHolderName': '',
//     'cardNumber': '',
//     'expiryDate': '',
//     'cvv': ''
//   };

//   bool _saveShipping = false;
//   bool _saveCard = false;

//   // Simulate payment processing
//   void _processPayment() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );

//     await Future.delayed(const Duration(seconds: 2)); // Simulate a delay

//     // Save payment data if the user opted to save the card
//     if (_saveCard) {
//       _savePaymentData();
//     }

//     Navigator.pop(context); // Close the loading dialog
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const PaymentCompleteScreen(),
//       ),
//     );
//   }

//   void _saveShippingAddress() {
//     // Save address data (this could be to a backend or local storage)
//     if (_saveShipping) {
//       print("Saving shipping address: $_addressData");
//     }
//   }

//   void _savePaymentData() {
//     // Save payment data securely (e.g., to encrypted storage or backend)
//     print("Saving payment data: $_paymentData");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Checkout',
//           style: TextStyle(color: Colors.brown),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.brown),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               // Navigate to ProfileScreen
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => MyInformationScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stepper(
//         type: StepperType.horizontal,
//         currentStep: _currentStep,
//         onStepContinue: () {
//           if (_currentStep == 0 && _formKey.currentState!.validate()) {
//             _formKey.currentState!.save();
//             _saveShippingAddress();
//             setState(() {
//               _currentStep++;
//             });
//           } else if (_currentStep == 1) {
//             _processPayment();
//           }
//         },
//         onStepCancel: () {
//           if (_currentStep > 0) {
//             setState(() {
//               _currentStep--;
//             });
//           } else {
//             Navigator.pop(context);
//           }
//         },
//         steps: [
//           Step(
//             title: const Text('Address'),
//             isActive: _currentStep >= 0,
//             state: _currentStep > 0 ? StepState.complete : StepState.indexed,
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInputField(
//                     label: 'Full Name',
//                     hint: 'Enter your full name',
//                     onSave: (value) => _addressData['fullName'] = value!,
//                     validator: (value) =>
//                         value == null || value.isEmpty ? 'Required' : null,
//                   ),
//                   _buildInputField(
//                     label: 'Email',
//                     hint: 'Enter your email',
//                     keyboardType: TextInputType.emailAddress,
//                     onSave: (value) => _addressData['email'] = value!,
//                     validator: (value) => value == null || !value.contains('@')
//                         ? 'Enter a valid email'
//                         : null,
//                   ),
//                   _buildInputField(
//                     label: 'Phone',
//                     hint: 'Enter your phone number',
//                     keyboardType: TextInputType.phone,
//                     onSave: (value) => _addressData['phone'] = value!,
//                     validator: (value) => value == null || value.length < 10
//                         ? 'Enter a valid phone number'
//                         : null,
//                   ),
//                   _buildInputField(
//                     label: 'Address',
//                     hint: 'Type your home address',
//                     onSave: (value) => _addressData['address'] = value!,
//                     validator: (value) =>
//                         value == null || value.isEmpty ? 'Required' : null,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildInputField(
//                           label: 'City',
//                           hint: 'Enter here',
//                           onSave: (value) => _addressData['city'] = value!,
//                           validator: (value) => value == null || value.isEmpty
//                               ? 'Required'
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _buildInputField(
//                           label: 'Country',
//                           hint: 'Your country',
//                           onSave: (value) => _addressData['country'] = value!,
//                           validator: (value) => value == null || value.isEmpty
//                               ? 'Required'
//                               : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                   CheckboxListTile(
//                     title: const Text('Save shipping address'),
//                     value: _saveShipping,
//                     onChanged: (value) {
//                       setState(() {
//                         _saveShipping = value!;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Step(
//             title: const Text('Complete'),
//             isActive: _currentStep >= 1,
//             state: _currentStep > 1 ? StepState.complete : StepState.indexed,
//             content: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInputField(
//                   label: 'Card Holder Name',
//                   hint: 'Your card holder name',
//                   onSave: (value) => _paymentData['cardHolderName'] = value!,
//                   validator: (value) =>
//                       value == null || value.isEmpty ? 'Required' : null,
//                 ),
//                 _buildInputField(
//                   label: 'Card Number',
//                   hint: 'Your card number',
//                   keyboardType: TextInputType.number,
//                   onSave: (value) => _paymentData['cardNumber'] = value!,
//                   validator: (value) => value == null || value.length < 16
//                       ? 'Enter a valid card number'
//                       : null,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildInputField(
//                         label: 'Month/Year',
//                         hint: 'mm/yy',
//                         keyboardType: TextInputType.datetime,
//                         onSave: (value) => _paymentData['expiryDate'] = value!,
//                         validator: (value) =>
//                             value == null || value.isEmpty ? 'Required' : null,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildInputField(
//                         label: 'CVV',
//                         hint: '***',
//                         keyboardType: TextInputType.number,
//                         onSave: (value) => _paymentData['cvv'] = value!,
//                         validator: (value) => value == null || value.length != 3
//                             ? 'Invalid CVV'
//                             : null,
//                       ),
//                     ),
//                   ],
//                 ),
//                 CheckboxListTile(
//                   title: const Text('Save this card'),
//                   value: _saveCard,
//                   onChanged: (value) {
//                     setState(() {
//                       _saveCard = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Input field builder
//   Widget _buildInputField({
//     required String label,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     required void Function(String?) onSave,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         keyboardType: keyboardType,
//         onSaved: onSave,
//         validator: validator,
//         decoration: InputDecoration(
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/orderConfirmationPage.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  final dynamic cart;
  final dynamic discount;
  final dynamic subtotal;
  final dynamic total;

  const CheckoutScreen({
    Key? key,
    required this.cart,
    required this.discount,
    required this.subtotal,
    required this.total,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  bool _addingNewAddress = false;
  String? _selectedAddressId;
  String globalUserId = '';
  String _orderStatus = 'Order Confirmed';
  String orderId = '';
  List<Map<String, dynamic>> _savedAddresses = [];
  static String? baseUrl = dotenv.env['BASE_URL'];

  late Razorpay _razorpay;
  final Map<String, String> _newAddress = {
    'address_line1': '',
    'address_line2': '',
    'city': '',
    'state': '',
    'country': '',
    'postal_code': '',
    'phone_number': ''
  };

  bool _saveShipping = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    globalUserId = userProvider.userId;

    if (globalUserId.isNotEmpty) {
      _fetchSavedAddresses(globalUserId);
    } else {
      print("User ID is empty. Cannot fetch addresses.");
    }
  }

  void _updateOrderStatus(String status) {
    setState(() {
      _orderStatus = status; // This variable will hold the current order status
    });
  }
// class TrackerData {
//   final String title;
//   final String date;
//   final List<TrackerDetails> trackerDetails;

//   TrackerData({required this.title, required this.date, required this.trackerDetails});

//   factory TrackerData.fromJson(Map<String, dynamic> json) {
//     var details = json['tracker_details'] as List;
//     List<TrackerDetails> trackerDetailsList = details.map((i) => TrackerDetails.fromJson(i)).toList();
//     return TrackerData(
//       title: json['title'],
//       date: json['date'],
//       trackerDetails: trackerDetailsList,
//     );
//   }
// }

  Future<void> _createOrder() async {
    final String orderApiUrl = '$baseUrl/orders/create-order';
    try {
      final response = await http.post(
        Uri.parse(orderApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'userId': globalUserId,
          'products': widget.cart,
          'delivery_address': _selectedAddressId,
          'total_amount': widget.total,
        }),
      );
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _openRazorpayCheckout(responseData['razorpayOrder'],
            responseData['user'], responseData['order']);
      } else {
        print('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  void _openRazorpayCheckout(
      dynamic razorpayOrder, dynamic userData, dynamic order) {
    var options = {
      'key': dotenv.env['RAZORPAY_KEY'],
      'amount': razorpayOrder['amount_due'], // Ensure it's in paisa
      'order_id': razorpayOrder['id'], // Correct field name
      'name': 'Red Collar',
      'description': 'Payment for Order',
      'prefill': {
        'contact': userData['phoneNumber'], // Corrected field name
        'email': userData['email'], // Corrected field name
      },
      'theme': {'color': '#FF0000'},
    };
    setState(() {
      orderId = order['_id'];
    });
    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
    }
  }

  Future<void> _confirmOrder(String? paymentId, String? razorpayOrderId,
      String? razorpaySignature) async {
    final String confirmApiUrl = '$baseUrl/orders/verify-payment';
    try {
      final response = await http.post(
        Uri.parse(confirmApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature, // Added missing field
        }),
      );
      if (response.statusCode == 200) {
        print('Order confirmed successfully!');
      } else {
        print('Failed to confirm order: ${response.body}');
      }
    } catch (e) {
      print('Error confirming order: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment successful! Response: ${response.toString()}");
    await _confirmOrder(
        response.paymentId, response.orderId, response.signature);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet selected: ${response.walletName}");
  }

  // Fetch saved addresses from the server
  void _fetchSavedAddresses(String userId) async {
    final String apiUrl = '$baseUrl/address/fetch-address-by-userId/$userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> addressData = jsonDecode(response.body);

        setState(() {
          _savedAddresses = addressData.map((address) {
            return {
              'id': address['_id'],
              'address':
                  '${address['address_line1']}, ${address['city']}, ${address['state']}, ${address['country']}',
            };
          }).toList();
          _selectedAddressId =
              _savedAddresses.isNotEmpty ? _savedAddresses[0]['id'] : null;
        });
      } else {
        print('Failed to load addresses: ${response.body}');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 &&
              (_selectedAddressId != null || _addingNewAddress)) {
            setState(() {
              _currentStep++;
            });
          } else if (_currentStep == 1) {
            _createOrder();
            setState(() {
              _currentStep++;
            });
          } else if (_currentStep == 2) {
            // Proceed to the confirmation step
            _updateOrderStatus('Order Confirmed');
            setState(() {
              _currentStep++;
            });
          }
        },
        steps: [
          Step(
            title: Text('Address'),
            content: _addingNewAddress
                ? _buildNewAddressForm()
                : _buildSavedAddressSelection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text('Payment'),
            content: ElevatedButton(
              onPressed: () {
                _createOrder();
                setState(() {
                  _currentStep++;
                });
              },
              child: Text('Pay Amount'),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text('Order Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderConfirmationPage(),
                      ),
                    );
                  },
                  child: Text('Proceed to Order Confirmation'),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAddressSelection() {
    return Column(
      children: [
        if (_savedAddresses.isNotEmpty)
          Column(
            children: _savedAddresses.map((address) {
              return RadioListTile(
                title: Text(address['address']!),
                value: address['id'],
                groupValue: _selectedAddressId,
                onChanged: (value) {
                  setState(() {
                    _selectedAddressId = value as String?;
                  });
                },
              );
            }).toList(),
          ),
        TextButton(
          onPressed: () {
            setState(() {
              _addingNewAddress = true;
            });
          },
          child: const Text('Add New Address'),
        ),
      ],
    );
  }

  Widget _buildNewAddressForm() {
    return Column(
      children: [
        _buildInputField(
            'Address Line 1', (value) => _newAddress['address_line1'] = value),
        _buildInputField(
            'Address Line 2', (value) => _newAddress['address_line2'] = value),
        _buildInputField('City', (value) => _newAddress['city'] = value),
        _buildInputField('State', (value) => _newAddress['state'] = value),
        _buildInputField('Country', (value) => _newAddress['country'] = value),
        _buildInputField(
            'Postal Code', (value) => _newAddress['postal_code'] = value),
        _buildInputField(
            'Phone Number', (value) => _newAddress['phone_number'] = value),
        CheckboxListTile(
          title: Text('Save Shipping Address'),
          value: _saveShipping,
          onChanged: (value) {
            setState(() {
              _saveShipping = value!;
            });
          },
        ),
        ElevatedButton(
          onPressed: _saveNewAddress,
          child: Text('Save Address'),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, Function(String) onSave) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        onChanged: onSave,
      ),
    );
  }

  void _saveNewAddress() async {
    if (_saveShipping) {
      print("Saving new shipping address: $_newAddress");

      final newAddressData = {
        'user': globalUserId,
        'address_line1': _newAddress['address_line1'],
        'address_line2': _newAddress['address_line2'],
        'city': _newAddress['city'],
        'state': _newAddress['state'],
        'country': _newAddress['country'],
        'postal_code': _newAddress['postal_code'],
        'phone_number': _newAddress['phone_number'],
        'save_address': true
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/address/create-addresses'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(newAddressData),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final addressId = responseData['address']['_id'];
          _fetchSavedAddresses(globalUserId);

          setState(() {
            _addingNewAddress = false;
            _newAddress['address_line1'] = '';
            _newAddress['address_line2'] = '';
            _newAddress['city'] = '';
            _newAddress['state'] = '';
            _newAddress['country'] = '';
            _newAddress['postal_code'] = '';
            _newAddress['phone_number'] = '';
          });

          print("New address ID: $addressId");
        } else {
          print('Failed to save address: ${response.body}');
        }
      } catch (e) {
        print('Error saving new address: $e');
      }
    }
  }
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/provider/userProvider.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class CheckoutScreen extends StatefulWidget {
//   final dynamic cart;
//   final dynamic discount;
//   final dynamic subtotal;
//   final dynamic total;

//   const CheckoutScreen({
//     Key? key,
//     required this.cart,
//     required this.discount,
//     required this.subtotal,
//     required this.total,
//   }) : super(key: key);

//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   int _currentStep = 0;
//   bool _addingNewAddress = false;
//   String? _selectedAddressId;
//   String globalUserId = '';
//   List<Map<String, dynamic>> _savedAddresses = [];
//   static String? baseUrl = dotenv.env['BASE_URL'];

//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _razorpay.clear();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final userProvider = Provider.of<UserProvider>(context);
//     globalUserId = userProvider.userId;
//     if (globalUserId.isNotEmpty) {
//       _fetchSavedAddresses(globalUserId);
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     print("Payment successful! Response: ${response.toString()}");
//     await _confirmOrder(
//         response.paymentId, response.orderId, response.signature);
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     print("Payment failed: ${response.message}");
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("External Wallet selected: ${response.walletName}");
//   }

//   Future<void> _fetchSavedAddresses(String userId) async {
//     final String apiUrl = '$baseUrl/address/fetch-address-by-userId/$userId';
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final List<dynamic> addressData = jsonDecode(response.body);
//         setState(() {
//           _savedAddresses = addressData.map((address) {
//             return {
//               'id': address['_id'],
//               'address':
//                   '${address['address_line1']}, ${address['city']}, ${address['state']}, ${address['country']}',
//             };
//           }).toList();
//           _selectedAddressId =
//               _savedAddresses.isNotEmpty ? _savedAddresses[0]['id'] : null;
//         });
//       }
//     } catch (e) {
//       print('Error fetching addresses: $e');
//     }
//   }

//   Future<void> _createOrder() async {
//     final String orderApiUrl = '$baseUrl/orders/create-order';
//     try {
//       final response = await http.post(
//         Uri.parse(orderApiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           'userId': globalUserId,
//           'products': widget.cart,
//           'delivery_address': _selectedAddressId,
//           'total_amount': widget.total,
//         }),
//       );
//       if (response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         _openRazorpayCheckout(
//             responseData['razorpayOrder'], responseData['user']);
//       } else {
//         print('Failed to create order: ${response.body}');
//       }
//     } catch (e) {
//       print('Error creating order: $e');
//     }
//   }

//   void _openRazorpayCheckout(dynamic razorpayOrder, dynamic userData) {
//     var options = {
//       'key': dotenv.env['RAZORPAY_KEY'],
//       'amount': razorpayOrder['amount_due'], // Ensure it's in paisa
//       'order_id': razorpayOrder['id'], // Correct field name
//       'name': 'Red Collar',
//       'description': 'Payment for Order',
//       'prefill': {
//         'contact': userData['phoneNumber'], // Corrected field name
//         'email': userData['email'], // Corrected field name
//       },
//       'theme': {'color': '#FF0000'},
//     };
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print("Error opening Razorpay: $e");
//     }
//   }

//   Future<void> _confirmOrder(String? paymentId, String? razorpayOrderId,
//       String? razorpaySignature) async {
//     final String confirmApiUrl = '$baseUrl/orders/verify-payment';
//     try {
//       final response = await http.post(
//         Uri.parse(confirmApiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           'razorpay_payment_id': paymentId,
//           'razorpay_order_id': razorpayOrderId,
//           'razorpay_signature': razorpaySignature, // Added missing field
//         }),
//       );
//       if (response.statusCode == 200) {
//         print('Order confirmed successfully!');
//       } else {
//         print('Failed to confirm order: ${response.body}');
//       }
//     } catch (e) {
//       print('Error confirming order: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Checkout')),
//       body: Stepper(
//         currentStep: _currentStep,
//         onStepContinue: () {
//           if (_currentStep == 0 && _selectedAddressId != null) {
//             setState(() {
//               _currentStep++;
//             });
//           } else if (_currentStep == 1) {
//             _createOrder();
//           }
//         },
//         steps: [
//           Step(
//             title: Text('Address'),
//             content: Text(_savedAddresses.isNotEmpty
//                 ? _savedAddresses[0]['address']!
//                 : 'No address found'),
//             isActive: _currentStep >= 0,
//           ),
//           Step(
//             title: Text('Payment'),
//             content: ElevatedButton(
//               onPressed: _createOrder,
//               child: Text('Proceed to Pay'),
//             ),
//             isActive: _currentStep >= 1,
//           ),
//         ],
//       ),
//     );
//   }
// }
