import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewsPage extends StatefulWidget {
  final String userId;

  const ReviewsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    getReviews(widget.userId);
  }

  Future<void> getReviews(String userId) async {
    final String apiUrl =
        "http://10.0.2.2:6000/api/reviews/reviewsById/$userId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          if (responseData.containsKey("data")) {
            final data = responseData["data"];
            if (data is List) {
              reviews = List<Map<String, dynamic>>.from(
                  data.map((e) => Map<String, dynamic>.from(e)));
            } else if (data is Map) {
              reviews = [Map<String, dynamic>.from(data)];
            } else {
              hasError = true;
            }
          } else {
            hasError = true;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(
        rating,
        (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Reviews")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load reviews"))
              : reviews.isEmpty
                  ? const Center(child: Text("No reviews found"))
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final user = review['user'];
                        final product = review['product'];
                        final rating =
                            review['rating'] is int ? review['rating'] : 0;

                        return GestureDetector(
                          onTap: () {
                            if (product != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductPage(productId: product['id']),
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.brown, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Rating: ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      buildStars(rating),
                                    ],
                                  ),
                                  Text('User:',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '${user != null ? user['username'] : 'Unknown'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  Text('Review: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('${review['comment'] ?? 'No comment'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  if (product != null &&
                                      product['images'] != null &&
                                      product['images'].isNotEmpty)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: product['images']
                                            .map<Widget>((image) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Image.network(
                                                'http://10.0.2.2:6000$image',
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class ProductPage extends StatelessWidget {
  final String productId;

  const ProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(child: Text('Product details for product ID: $productId')),
    );
  }
}
