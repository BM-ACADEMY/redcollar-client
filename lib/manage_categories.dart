import 'dart:convert';
import 'dart:io';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({Key? key}) : super(key: key);

  @override
  _AdminCategoryScreenState createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  List<dynamic> categories = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool isEditing = false;
  String? editingId;
  final String? baseUrl = dotenv.env['BASE_URL'];

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  bool _isHovering = false;
  @override
  void initState() {
    super.initState();
    fetchCategories();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.95) {
        fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories({bool isRefresh = false}) async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isRefresh) {
        categories.clear();
        currentPage = 1;
        hasMore = true;
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/category/fetch-all-categories?page=$currentPage&limit=10'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          categories.addAll(responseData['data']);
          currentPage++;
          hasMore = responseData['data'].length == 10;
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      _showSnackbar('Error fetching categories: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      var request;
      if (isEditing) {
        request = http.MultipartRequest(
            "PUT", Uri.parse('$baseUrl/category/update-categories/$editingId'));
      } else {
        request = http.MultipartRequest(
            "POST", Uri.parse('$baseUrl/category/create-categories'));
      }

      request.fields['name'] = _nameController.text;

      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('images', _image!.path));
      }

      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          isEditing = false;
          editingId = null;
          _nameController.clear();
          _image = null;
        });
        await fetchCategories(isRefresh: true);
        _showSnackbar(isEditing ? 'Category updated' : 'Category added');
      } else {
        throw Exception('Failed to save category');
      }
    } catch (error) {
      _showSnackbar('Error submitting category: $error');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/category/delete-categories/$id'));

      if (response.statusCode == 200) {
        setState(() {
          categories.removeWhere((category) => category['_id'] == id);
        });
        _showSnackbar('Category deleted');
      } else {
        throw Exception('Failed to delete category');
      }
    } catch (error) {
      _showSnackbar('Error deleting category: $error');
    }
  }

  void editCategory(Map category) {
    setState(() {
      isEditing = true;
      editingId = category['_id'];
      _nameController.text = category['name'];
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    List<String> splitPath = imagePath.split('/');
    String imageName = splitPath.last;
    return '$baseUrl/category/fetch-category-image/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'Enter category name', // Placeholder
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded border
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10), // Padding inside field
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter a category name' : null,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                      ),
                      child: _image == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload,
                                      size: 40, color: Colors.grey),
                                  Text("Tap to upload image",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_image!, fit: BoxFit.fitHeight),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, // Full-width button
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click, // Cursor pointer effect
                      onEnter: (_) =>
                          setState(() => _isHovering = true), // Hover start
                      onExit: (_) =>
                          setState(() => _isHovering = false), // Hover end
                      child: AnimatedOpacity(
                        duration:
                            Duration(milliseconds: 200), // Smooth transition
                        opacity:
                            _isHovering ? 0.8 : 1.0, // Opacity effect on hover
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFF3F2010), // Button background
                            foregroundColor: Colors.brown, // Button text color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Border radius
                              side: BorderSide(
                                  color: Colors.brown), // Brown border
                            ),
                            padding:
                                EdgeInsets.symmetric(vertical: 15), // Padding
                          ),
                          onPressed: submitCategory,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isEditing ? "Update Category" : "Add Category",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8), // Spacing
                              Icon(Icons.add,
                                  color: Colors.white,
                                  size: 18), // Icon always visible
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                thickness: 6,
                radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == categories.length) {
                            return hasMore
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : const SizedBox.shrink();
                          }

                          var category = categories[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  bottomLeft: Radius.circular(50),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(2, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  bottomLeft: Radius.circular(50),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    // Full-width Cover Image
                                    Image.network(
                                      // getImageUrl(category['images']),
                                      category['images'],
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.image,
                                                  size: 50, color: Colors.grey),
                                    ),

                                    // Overlay with Category Name & Actions
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(50),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Category Name
                                            Text(
                                              category['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            // Edit & Delete Icons
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Iconsax.edit,
                                                      color: Colors.blue),
                                                  onPressed: () =>
                                                      editCategory(category),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Iconsax.trash,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      deleteCategory(
                                                          category['_id']),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
