import 'package:flutter/material.dart';
// Import the Cart Screen

class ProductDetailPage1 extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage1(
      {super.key,
      required this.product,
      required List cart,
      required List favorites});

  @override
  State<ProductDetailPage1> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage1> {
  String selectedSize = "L";
  String selectedColor = "Teal";

  final List<String> sizes = ["L", "XL", "XXL"];
  final List<String> colors = ["Teal", "Choco", "Blume"];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DETAILS",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Product Image
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _getImageWidget(product['image']),
              ),
            ),
          ),

          // Product Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CULTURES",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Size Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sizes.map((size) {
                    final isSelected = size == selectedSize;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.orange : Colors.grey,
                          ),
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Add to Cart Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add product to cart
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Image Widget with fallback
  Widget _getImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/default_image.png',
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          imageUrl,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
