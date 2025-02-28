import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminProductDetailsPage extends StatefulWidget {
  final String category;
  final bool isAdmin;
  final String documentId;
  final String collectionName;

  const AdminProductDetailsPage({
    Key? key,
    required this.category,
    required this.documentId,
    required this.collectionName,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  _AdminProductDetailsPageState createState() =>
      _AdminProductDetailsPageState();
}

class _AdminProductDetailsPageState extends State<AdminProductDetailsPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> types = [];
  // List to store picked images from the file picker (used in the form)
  List<XFile>? _pickedImages;
  static String? baseUrl = dotenv.env['BASE_URL'];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
    fetchTypes();
  }

  late String userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId;
  }

  // Fetch all categories for the dropdown.
  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/category/fetch-all-categories-for-admin'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          // API returns: { "message": "...", "data": [ ... ] }
          categories = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchTypes() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/types/get-all-types'));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          types = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  // Fetch products by category (using documentId as parameter).
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/products/fetch-product-by-category/${widget.documentId}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Construct full image URL from a relative path.
  String getImageUrl(String imagePath) {
    return '$baseUrl/products/fetch-product-image/${imagePath.split('/').last}';
  }

  Future<void> toggleFavorite(String productId, bool wasFavorite) async {
    final url = wasFavorite
        ? '$baseUrl/linkedproducts/delete-favorite'
        : '$baseUrl/linkedproducts/create-favorite';
    print(productId);
    print(wasFavorite);
    print('userId,$userId');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "productId": productId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchProducts(); // Refresh product list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                wasFavorite ? 'Removed from favorites' : 'Added to favorites'),
          ),
        );
      } else {
        throw Exception('Failed to toggle favorite');
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  // Add a new product via POST API call.
  Future<void> addProduct(Map<String, dynamic> newProduct) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products/create-products'),
      );

      // Add other product details as form fields
      newProduct.forEach((key, value) {
        if (value is List) {
          request.fields[key] =
              jsonEncode(value); // Convert list to JSON string
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Attach images if available
      if (_pickedImages != null && _pickedImages!.isNotEmpty) {
        for (var image in _pickedImages!) {
          var imageFile = await http.MultipartFile.fromPath(
            'images', // This should match the field name expected by your backend
            image.path,
          );
          request.files.add(imageFile);
        }
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully')),
        );
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      print("Error adding product: $e");
    }
  }

  // Update an existing product via PUT API call.
  Future<void> updateProduct(
      String id, Map<String, dynamic> updatedProduct) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/products/update-products/$id'),
      );

      // Add other product details as form fields
      updatedProduct.forEach((key, value) {
        if (value is List) {
          request.fields[key] =
              jsonEncode(value); // Convert list to JSON string
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Attach images only if new images are picked
      if (_pickedImages != null && _pickedImages!.isNotEmpty) {
        for (var image in _pickedImages!) {
          var imageFile = await http.MultipartFile.fromPath(
            'images', // This should match the backend field name
            image.path,
          );
          request.files.add(imageFile);
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  // Delete a product via DELETE API call.
  Future<void> deleteProduct(String id) async {
    try {
      print('id,$id');
      final response =
          await http.delete(Uri.parse('$baseUrl/products/delete-products/$id'));
      if (response.statusCode == 200) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product deleted successfully')));
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  // Use image_picker to allow the user to pick multiple images.
  Future<void> pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _pickedImages = images;
      });
    }
  }

  void showProductForm({Map<String, dynamic>? product}) {
    // Create controllers with initial values if product exists.
    final TextEditingController nameController =
        TextEditingController(text: product?['name'] ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: product?['description'] ?? '');
    final TextEditingController brandController =
        TextEditingController(text: product?['brand'] ?? '');
    final TextEditingController priceController = TextEditingController(
        text: product?['original_price']?.toString() ?? '');
    final TextEditingController discountController = TextEditingController(
        text: product?['discount_percentage']?.toString() ?? '');
    final TextEditingController colorController = TextEditingController(
        text: product != null
            ? (product['color'] as List<dynamic>).join(', ')
            : '');
    final TextEditingController sizesController = TextEditingController(
        text: product != null
            ? (product['sizes'] as List<dynamic>).join(', ')
            : '');
    final TextEditingController stockController = TextEditingController(
        text: product?['stock_quantity']?.toString() ?? '');
    // For images, we use the file picker. Also create a fallback controller.
    final TextEditingController imagesController = TextEditingController(
        text: product != null
            ? (product['images'] as List<dynamic>).join(', ')
            : '');
    final TextEditingController ratingController =
        TextEditingController(text: product?['rating']?.toString() ?? '');
    final TextEditingController deliveryOptionController =
        TextEditingController(text: product?['deliveryOption'] ?? '');

    // Dropdown values for gender, age category, and category.
    String? _selectedGender = product?['gender'] ?? 'Male';
    String? _selectedAgeCategory = product?['age_category'] ?? 'Adults';
    String? _selectedCategory;
    if (product != null) {
      if (product['category'] is String) {
        _selectedCategory = product['category'];
      } else {
        _selectedCategory = product['category']['\$oid'];
      }
    } else {
      _selectedCategory = (categories.isNotEmpty) ? categories[0]['_id'] : '';
    }
    String? _selectedType;
    if (product != null) {
      if (product['type'] is String) {
        _selectedType = product['type'];
      } else {
        _selectedType = product['type']['\$oid'];
      }
    } else {
      _selectedType = (types.isNotEmpty) ? types[0]['_id'] : '';
    }

    // Reset picked images when opening the form.
    _pickedImages = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name')),
                TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description')),
                // Category dropdown using fetched categories.
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['_id'],
                      child: Text(cat['name']),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val;
                    });
                  },
                  items: types.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['_id'],
                      child: Text(cat['name']),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Types'),
                ),
                TextField(
                    controller: brandController,
                    decoration: InputDecoration(labelText: 'Brand')),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Original Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(labelText: 'Discount Percentage'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                    controller: colorController,
                    decoration:
                        InputDecoration(labelText: 'Colors (comma separated)')),
                TextField(
                    controller: sizesController,
                    decoration:
                        InputDecoration(labelText: 'Sizes (comma separated)')),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                ),
                // Instead of a text field for images, use a button to pick images.
                ElevatedButton(
                  onPressed: pickImages,
                  child: Text('Pick Images'),
                ),
                if (_pickedImages != null && _pickedImages!.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _pickedImages!
                        .map((xfile) => Chip(label: Text(xfile.name)))
                        .toList(),
                  ),
                // Gender dropdown.
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (val) {
                    _selectedGender = val;
                  },
                  items: ['Male', 'Female', 'Unisex'].map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                // Age category dropdown.
                DropdownButtonFormField<String>(
                  value: _selectedAgeCategory,
                  onChanged: (val) {
                    _selectedAgeCategory = val;
                  },
                  items: ['Adults', 'Kids', 'Baby'].map((ageCat) {
                    return DropdownMenuItem<String>(
                      value: ageCat,
                      child: Text(ageCat),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Age Category'),
                ),
                TextField(
                  controller: ratingController,
                  decoration: InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                    controller: deliveryOptionController,
                    decoration: InputDecoration(labelText: 'Delivery Option')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                final Map<String, dynamic> formData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': _selectedCategory ?? '',
                  'type': _selectedType ?? '',
                  'brand': brandController.text,
                  'original_price': int.tryParse(priceController.text) ?? 0,
                  'discount_percentage':
                      int.tryParse(discountController.text) ?? 0,
                  'color': colorController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  'sizes': sizesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  'stock_quantity': int.tryParse(stockController.text) ?? 0,
                  // For images, if new images are picked, use them; otherwise, use fallback from imagesController.
                  'images': _pickedImages != null && _pickedImages!.isNotEmpty
                      ? _pickedImages!.map((x) => x.path).toList()
                      : imagesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                  'gender': _selectedGender,
                  'age_category': _selectedAgeCategory,
                  'rating': int.tryParse(ratingController.text) ?? 0,
                  'deliveryOption': deliveryOptionController.text,
                };
                if (product == null) {
                  addProduct(formData);
                } else {
                  updateProduct(product['_id'], formData);
                }
                Navigator.pop(context);
              },
              child: Text(product == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Products'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          // Calculate discounted price.
          double originalPrice = (product['original_price'] as num).toDouble();
          double discountPercentage =
              (product['discount_percentage'] as num).toDouble();
          double discountedPrice =
              originalPrice - (originalPrice * discountPercentage / 100);

          // Get image URL from the first image in the list.
          // final imageUrl = getImageUrl(product['images']?[0] ?? '');

          final imageUrl = product['images']?[0] ?? '';
          return GestureDetector(
            onTap: () {
              // Optional: Navigate to a detailed product page if desired.
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Stack(
                children: [
                  // Product Image.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                  // Product Details Container at Bottom.
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'Unnamed',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product['brand'] ?? 'Brand',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '₹${discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (originalPrice != discountedPrice)
                            Text(
                              '₹${originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite Icon at Top-Right.
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        product['isFavorite'] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product['isFavorite'] == true
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () {
                        bool wasFavorite = product['isFavorite'] == true;
                        setState(() {
                          product['isFavorite'] = !wasFavorite;
                        });
                        toggleFavorite(product['_id'], wasFavorite);
                      },
                    ),
                  ),
                  // Edit Icon at Top-Left.
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showProductForm(product: product);
                      },
                    ),
                  ),
                  // Delete Icon at Bottom-Right.
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteProduct(product['_id']);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                showProductForm();
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
