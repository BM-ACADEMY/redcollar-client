import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define the categories' endpoints
final List<String> categoryUrls = [
  'http://10.0.2.2:6000/clothes',
  'http://10.0.2.2:6000/hoodies',
  'http://10.0.2.2:6000/jeans',
  'http://10.0.2.2:6000/accesories',
  'http://10.0.2.2:6000/overseas',
];

class Product {
  final String name;
  final String docId;
  final String image;

  Product({required this.name, required this.docId, required this.image});

  // Factory method to create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      docId: json['docId'],
      image: json['image'],
    );
  }

  get price => null;
}

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch products from the API
  Future<void> _fetchProducts() async {
    List<Product> fetchedProducts = [];
    for (var url in categoryUrls) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          for (var item in data) {
            fetchedProducts.add(Product.fromJson(item));
          }
        } else {
          throw Exception('Failed to load data from $url');
        }
      } catch (e) {
        print('Error fetching data from $url: $e');
      }
    }

    setState(() {
      products = fetchedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
    );
  }

  // Widget to display each product
  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              product.image,
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('₹ 0.00'), // Placeholder for price, adjust if needed
          ),
        ],
      ),
    );
  }
}
