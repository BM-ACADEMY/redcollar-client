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
  static String? baseUrl = dotenv.env['BASE_URL'];

  /// Fetch user details including the default address
  Future<Map<String, dynamic>?> fetchUserById(BuildContext context) async {
    String userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId.isEmpty) throw Exception("User is not logged in.");

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/fetch-user-by-id/$userId'));

      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);
        print("User Data: $userData"); // Debugging log
        return userData;
      } else {
        throw Exception('Failed to fetch user. Status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching user: $error');
    }
  }

  /// Fetch all shipping addresses (excluding the default address)
  Future<List<dynamic>> fetchAllAddresses(BuildContext context) async {
    String userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId.isEmpty) throw Exception("User is not logged in.");

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/address/fetch-address-by-userId/$userId'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Addresses Data: $data"); // Debugging log
        return data is List ? data : [];
      } else {
        return [];
      }
    } catch (error) {
      throw Exception('Error fetching addresses: $error');
    }
  }

  /// Helper method to format the full address string
  String buildFullAddress(Map<String, dynamic> address) {
    return "${address['addressLine1'] ?? address['address_line1'] ?? ''}, "
        "${address['addressLine2'] ?? address['address_line2'] ?? ''}\n"
        "${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['pincode'] ?? address['postal_code'] ?? ''}\n"
        "${address['country'] ?? ''}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Addresses")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserById(context), // Ensure context is passed here
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }

          var userData = userSnapshot.data;
          if (userData == null || userData.isEmpty) {
            return const Center(child: Text("User data not found."));
          }

          var defaultAddress = userData['address'];

          return FutureBuilder<List<dynamic>>(
            future: fetchAllAddresses(context),
            builder: (context, addressSnapshot) {
              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (addressSnapshot.hasError) {
                return Center(child: Text('Error: ${addressSnapshot.error}'));
              }

              var addresses = addressSnapshot.data ?? [];

              return ListView(
                children: [
                  // Show Default Address (from fetchUserById)
                  if (defaultAddress != null) ...[
                    Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 5,
                      color: const Color.fromARGB(255, 244, 186, 186),
                      child: ListTile(
                        leading: const Icon(Icons.home, color: Colors.red),
                        title: const Text(
                          "Default Address",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(buildFullAddress(defaultAddress)),
                        trailing: const Icon(Icons.star,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                    const Divider(),
                  ],

                  // Show Additional Shipping Addresses (from fetchAllAddresses)
                  if (addresses.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No additional addresses found."),
                      ),
                    )
                  else
                    ...addresses.map((address) {
                      bool isDefault = address['is_default'] ?? false;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 3,
                        color: isDefault ? Colors.blue.shade50 : Colors.white,
                        child: ListTile(
                          leading:
                              const Icon(Icons.location_on, color: Colors.red),
                          title: Text(buildFullAddress(address)),
                          subtitle: Text(
                              'Phone: ${address['phone_number'] ?? 'N/A'}'),
                        ),
                      );
                    }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
