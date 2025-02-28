import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final String? baseUrl = dotenv.env['BASE_URL'];
  @override
  void initState() {
    super.initState();
    getReviews(widget.userId);
  }

  Future<void> getReviews(String userId) async {
    final String apiUrl = "$baseUrl/reviews/reviewsById/$userId";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Reviews",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load reviews"))
              : reviews.isEmpty
                  ? const Center(child: Text("No reviews found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final user = review['user'];
                        final product = review['product'];
                        final rating = review['rating'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🟡 User Info & Rating
                                Row(
                                  children: [
                                    // User Avatar with Initials if No Image
                                    CircleAvatar(
                                      backgroundColor:
                                          Colors.black, // Background color
                                      radius: 20,
                                      backgroundImage: user['avatar'] != null
                                          ? NetworkImage(user['avatar'])
                                          : null,
                                      child: user['avatar'] == null
                                          ? Text(
                                              (user['username'] ?? 'U')
                                                  .substring(0, 2)
                                                  .toUpperCase(), // First two letters
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    // Username & Rating
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['username'] ?? 'Unknown User',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        buildStars(rating),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // 📝 Review Comment
                                Text(
                                  review['comment'] ?? 'No comment available',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 10),

                                // 📸 Multiple Product Images
                                // 📸 Multiple Review Images
                                if (review['images'] != null &&
                                    (review['images'] as List).isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                          (review['images'] as List<dynamic>)
                                              .map<Widget>((image) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              image
                                                  .toString(), // Ensure image is a valid string URL
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 70,
                                                  width: 70,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  // ⭐ Build Star Rating Widget
  Widget buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: const Color.fromARGB(255, 243, 91, 91),
          size: 18,
        );
      }),
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
