import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

class WriteReviewPage extends StatefulWidget {
  final String productId;

  const WriteReviewPage({super.key, required this.productId});

  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final _formKey = GlobalKey<FormState>();
  List<XFile>? _selectedImages = [];
  static String? baseUrl = dotenv.env['BASE_URL'];
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  final ImagePicker _picker = ImagePicker();
  late String userId = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the UserProvider inside didChangeDependencies
    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId;
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    var uri = Uri.parse('$baseUrl/reviews/create-reviews');
    var request = http.MultipartRequest('POST', uri);

    // Adding the form fields
    request.fields['user'] = userId;
    request.fields['product'] = widget.productId;
    request.fields['comment'] = _commentController.text;
    request.fields['rating'] = _rating.toString();

    // Adding images with content-type based on file extension
    for (var image in _selectedImages!) {
      String fileType = image.path.split('.').last; // Extract file extension
      print('Uploading image: ${image.path} with file type: $fileType');

      // Dynamically set content type based on file extension
      MediaType mediaType = MediaType('image', fileType);

      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: mediaType,
      ));
    }

    // Sending the request
    var response = await request.send();
    print('Response Status: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.stream.toString()}');

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review submitted!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Write a Review")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Button
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text("Upload Images"),
              ),

              // Show Selected Images
              if (_selectedImages!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedImages!
                      .map((img) => Image.file(File(img.path), width: 80))
                      .toList(),
                ),

              const SizedBox(height: 20),

              // Comment Input Field
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: "Your Comment"),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? "Please enter a comment" : null,
              ),

              const SizedBox(height: 20),

              // Rating Dropdown
              DropdownButtonFormField<int>(
                value: _rating,
                items: List.generate(
                    5,
                    (index) => DropdownMenuItem(
                          value: index + 1,
                          child:
                              Text("${index + 1} Star${index > 0 ? 's' : ''}"),
                        )),
                onChanged: (value) => setState(() => _rating = value!),
                decoration: const InputDecoration(labelText: "Rating"),
              ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text("Submit Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
