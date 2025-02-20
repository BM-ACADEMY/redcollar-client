import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressService extends StatefulWidget {
  @override
  _AddressServiceState createState() => _AddressServiceState();
}

class _AddressServiceState extends State<AddressService> {
  // Replace with your backend URL and port
  static String? baseUrl = dotenv.env['BASE_URL'];

  /// Fetches all addresses for the currently logged-in user.
  /// It retrieves the userId from the UserProvider.
  Future<List<dynamic>> fetchAllAddresses(BuildContext context) async {
    // Retrieve userId from your UserProvider
    String userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId.isEmpty) {
      throw Exception("User is not logged in. UserId is empty.");
    }

    print("Fetching addresses for userId: $userId");

    try {
      // Call the API endpoint (e.g., GET /user/:userId)
      final response = await http
          .get(Uri.parse('$baseUrl/address/fetch-address-by-userId/$userId'));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else {
          throw Exception("Unexpected response format: $data");
        }
      } else if (response.statusCode == 404) {
        // No addresses found
        return [];
      } else {
        throw Exception(
            'Failed to load addresses. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching addresses: $error');
    }
  }

  /// Helper method to format the full address string
  String buildFullAddress(Map<String, dynamic> address) {
    String addressLine1 = address['address_line1'] ?? '';
    String addressLine2 = address['address_line2'] ?? '';
    String city = address['city'] ?? '';
    String state = address['state'] ?? '';
    String postalCode = address['postal_code'] ?? '';
    String country = address['country'] ?? '';

    // Build a multi-line address string
    String fullAddress = addressLine1;
    if (addressLine2.isNotEmpty) {
      fullAddress += ', $addressLine2';
    }
    fullAddress += '\n$city, $state $postalCode\n$country';

    return fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Addresses")),
      body: FutureBuilder<List<dynamic>>(
        future: fetchAllAddresses(context),
        builder: (context, snapshot) {
          // While waiting for data, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display errors if any
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // When no addresses are found
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No addresses found.'));
          }
          // Display the list of addresses
          else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var address = snapshot.data![index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),
                    title: Text(buildFullAddress(address)),
                    subtitle:
                        Text('Phone: ${address['phone_number'] ?? 'N/A'}'),
                    trailing: address['is_default'] == true
                        ? const Icon(Icons.star, color: Colors.yellow)
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
