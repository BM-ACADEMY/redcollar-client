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
        title: const Text("Reviews"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WriteReviewPage(productId: productId)),
              );
            },
            icon:
                const Icon(Icons.edit, color: Color.fromARGB(255, 13, 13, 13)),
            label: const Text("Write Review",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReviews(productId), // Fetch reviews from API
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No reviews yet."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var review = snapshot.data![index];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                    review['userName'] ?? 'Anonymous'), // Handle null userName
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['comment'] ??
                        'No comment available'), // Handle null comment
                    Row(
                      children: List.generate(
                        (review['rating'] ?? 0), // Handle null rating
                        (index) => const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                      ),
                    ),
                    // Show images if available
                    if (review['images'] != null && review['images'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Flex(
                          direction: Axis
                              .horizontal, // You can also use Axis.vertical if you want a column layout
                          children: review['images']
                              .map<Widget>((imagePath) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.network(
                                      getImageUrl(imagePath),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit
                                          .cover, // Adjust the image fit as required
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    print(productId);
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
