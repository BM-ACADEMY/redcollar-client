import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:flutter_dash/flutter_dash.dart';

class AddOrEditTypeScreen extends StatefulWidget {
  final String? id;
  final String? existingName;
  final String? existingDescription;
  final String? existingImage;

  const AddOrEditTypeScreen({
    Key? key,
    this.id,
    this.existingName,
    this.existingDescription,
    this.existingImage,
  }) : super(key: key);

  @override
  _AddOrEditTypeScreenState createState() => _AddOrEditTypeScreenState();
}

class _AddOrEditTypeScreenState extends State<AddOrEditTypeScreen> {
  final String? baseUrl = dotenv.env['BASE_URL'];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.existingName ?? '';
    descriptionController.text = widget.existingDescription ?? '';
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void showSnackBarMessage(context, String message,
      {Color color = Colors.red}) {
    if (!context.mounted) return; // Ensure the widget is mounted before calling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Optional: Floating snackbar
      ),
    );
  }

  Future<void> saveType() async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Please fill all fields")),
      // );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var uri = Uri.parse(widget.id == null
          ? "$baseUrl/types/create-type"
          : "$baseUrl/types/update-type/${widget.id}");

      var request =
          http.MultipartRequest(widget.id == null ? "POST" : "PUT", uri);

      // ✅ Add text fields
      request.fields["name"] = nameController.text;
      request.fields["description"] = descriptionController.text;

      // ✅ Attach Image (If Selected)
      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", selectedImage!.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonData = json.decode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('added successfully');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Type ${widget.id == null ? 'created' : 'updated'} successfully")),
        // );
        // Navigator.pop(context, true);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(jsonData["message"] ?? "Something went wrong")),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Error: $e")),
      // );
      print('$e,failed to upload');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id == null ? "Add Type" : "Update Type",
          style: TextStyle(
            fontSize: 18, // Medium text size
            fontWeight: FontWeight.bold,
            color: Colors.black, // Visible on white background
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5), // Shadow effect
                blurRadius: 3.0,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 4.0, // Provides drop shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(), // Outlined border
              ),
            ),
            const SizedBox(height: 10),
            // Description Field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(), // Outlined border
              ),
            ),
            const SizedBox(height: 20),

            // Image Upload Section
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Dash(
                            direction: Axis.horizontal,
                            length: constraints.maxWidth, // Finite width
                            dashLength: 5,
                            dashColor: Colors.grey,
                          ),
                        ),
                        Positioned.fill(
                          child: Dash(
                            direction: Axis.vertical,
                            length: constraints.maxHeight, // Finite height
                            dashLength: 5,
                            dashColor: Colors.grey,
                          ),
                        ),
                        selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(selectedImage!,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    fit: BoxFit.cover),
                              )
                            : widget.existingImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(widget.existingImage!,
                                        width: constraints.maxWidth,
                                        height: constraints.maxHeight,
                                        fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.upload,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 5),
                                      Text("Tap to upload",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveType,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black background
                  padding: const EdgeInsets.symmetric(
                      vertical: 15), // Better touch size
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
