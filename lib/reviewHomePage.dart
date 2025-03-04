import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/writeReview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReviewHomePage extends StatelessWidget {
  final String productId;
  static String? baseUrl = dotenv.env['BASE_URL'];

  const ReviewHomePage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product Reviews",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Remove default shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1), // Border height
          child: Container(
            color: Colors.grey[300], // Border color
            height: 1, // Border thickness
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteReviewPage(productId: productId),
                ),
              );
            },
            icon:
                const Icon(Icons.rate_review, color: Colors.black), // New icon
            label: const Text(
              "Add Review",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReviews(productId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              "No reviews yet.",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var review = snapshot.data![index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info & Rating
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child:
                                const Icon(Icons.person, color: Colors.black),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['userName'] ?? 'Anonymous',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                _starRating(review['rating'] ?? 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Review Comment
                      Text(
                        review['comment'] ?? 'No comment available',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),

                      // Review Images (if available)
                      if (review['images'] != null &&
                          review['images'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            height: 60,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: review['images']
                                  .map<Widget>((imagePath) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            imagePath,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _starRating(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          Icons.star,
          color: index < rating ? Color(0xFFFE0000) : Colors.grey[300],
          size: 18,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/reviews/reviews-by-product-id/$productId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data'].map((review) => {
                "comment": review["comment"] ?? "No comment available",
                "images": review["images"] ?? [],
                "userName": review["userName"] ?? "Anonymous",
                "rating": review["rating"] ?? 0,
              }));
        } else {
          print('Unexpected response format: ${response.body}');
          return [];
        }
      } else {
        print(
            'Error fetching reviews: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching reviews: $error');
      return [];
    }
  }

  String getImageUrl(String imagePath) {
    return '$baseUrl/reviews/fetch-images/${imagePath.split('/').last}';
  }
}
