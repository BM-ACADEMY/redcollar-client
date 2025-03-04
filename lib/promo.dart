import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/notifi_service.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ManagePromotionsScreen extends StatefulWidget {
  const ManagePromotionsScreen({super.key});

  @override
  _ManagePromotionsScreenState createState() => _ManagePromotionsScreenState();
}

class _ManagePromotionsScreenState extends State<ManagePromotionsScreen> {
  static String? baseUrl = dotenv.env['BASE_URL']; // Emulator localhost
  late Future<List<Map<String, dynamic>>> promotionsFuture;

  @override
  void initState() {
    super.initState();
    promotionsFuture = _fetchPromotions();
  }

  Future<List<Map<String, dynamic>>> _fetchPromotions() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/promotions/promotions-getAll'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load promotions');
      }
    } catch (e) {
      throw Exception('Failed to load promotions: $e');
    }
  }

  Future<void> _deletePromotion(String promoId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/promotions/promotions-delete/$promoId'));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Promotion deleted successfully.",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        setState(() {
          promotionsFuture = _fetchPromotions();
        });
      } else {
        throw Exception('Failed to delete promotion');
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error deleting promotion: $e",
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  Future<void> _addOrUpdatePromotion(BuildContext context,
      {String? promoId,
      String? currentTitle,
      String? currentImageUrl,
      String? currentMessage}) async {
    final titleController = TextEditingController(text: currentTitle ?? '');
    final messageController = TextEditingController(text: currentMessage ?? '');
    File? _selectedImage;
    final picker = ImagePicker();

    Future<void> _pickImage(Function setState) async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            promoId == null ? 'Add Promotion' : 'Update Promotion',
            style: TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    // prefixIcon: const Icon(Icons.title, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    // prefixIcon: const Icon(Icons.message, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async => await _pickImage(setState),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey, width: 2), // Solid border
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      color: Colors.grey[100], // Light background
                    ),
                    alignment: Alignment.center,
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file,
                                  size: 40, color: Colors.grey),
                              const SizedBox(height: 5),
                              Text(
                                "Upload Image",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white, // White background
                foregroundColor: Colors.black, // Black text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  side: const BorderSide(color: Colors.black), // Black border
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final message = messageController.text.trim();

                if (title.isEmpty || message.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Title and Message are required.",
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                try {
                  var request = http.MultipartRequest(
                    promoId == null ? 'POST' : 'PUT',
                    Uri.parse(
                      promoId == null
                          ? '$baseUrl/promotions/promotions-create'
                          : '$baseUrl/promotions/promotions-update/$promoId',
                    ),
                  );

                  request.fields['title'] = title;
                  request.fields['message'] = message;

                  if (_selectedImage != null) {
                    request.files.add(
                      await http.MultipartFile.fromPath(
                          'Image', _selectedImage!.path),
                    );
                  }

                  var responseStream = await request.send();
                  var responseBody =
                      await responseStream.stream.bytesToString();

                  if (responseStream.statusCode ==
                      (promoId == null ? 201 : 200)) {
                    Fluttertoast.showToast(
                      msg: promoId == null
                          ? "Promotion added successfully."
                          : "Promotion updated successfully.",
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                    NotifiService().showNotification(
                      title: "New Promotion!",
                      body: "Check out the latest offer: $title",
                    );
                    Navigator.pop(context);

                    Future.delayed(Duration(milliseconds: 300), () {
                      setState(() {
                        promotionsFuture = _fetchPromotions();
                      });
                    });
                  } else {
                    throw Exception('Failed: $responseBody');
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Error: $e",
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black background
                foregroundColor: Colors.white, // White text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child:
                  Text(promoId == null ? 'Add Promotion' : 'Update Promotion'),
            ),
          ],
        ),
      ),
    );
  }

  String getImageUrl(String imagePath) {
    return '$baseUrl/promotions/get-image/${imagePath.split('/').last}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Border height
            child: Container(
              color: Colors.black26, // Border color
              height: 1.0, // Border thickness
            ),
          ),
          title: const Text(
            'Manage Promotions',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: promotionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No promotions found.'));
          }

          final promotions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promo = promotions[index];
              final promoId = promo['_id'];
              // final imageUrl =
              //     promo['Image'] != null ? getImageUrl(promo['Image']) : null;
              final imageUrl = promo['Image'] != null ? promo['Image'] : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl,
                              width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.campaign, color: Colors.teal),
                  title: Text(promo['title'] ?? 'No Title'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrUpdatePromotion(context,
                            promoId: promoId,
                            currentTitle: promo['title'],
                            currentMessage: promo['message'],
                            currentImageUrl: imageUrl),
                      ),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePromotion(promoId)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdatePromotion(context),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
