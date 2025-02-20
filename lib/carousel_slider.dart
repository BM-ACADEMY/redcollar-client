import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carousel Slider Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CarouselSliderScreen(),
    );
  }
}

class CarouselSliderScreen extends StatelessWidget {
  const CarouselSliderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the carousel
    final List<String> imageUrls = [
      'https://via.placeholder.com/600x400/FF5733/FFFFFF?text=First+Slide',
      'https://via.placeholder.com/600x400/33C1FF/FFFFFF?text=Second+Slide',
      'https://via.placeholder.com/600x400/28A745/FFFFFF?text=Third+Slide',
      'https://via.placeholder.com/600x400/FFC300/FFFFFF?text=Fourth+Slide',
      'https://via.placeholder.com/600x400/DC3545/FFFFFF?text=Fifth+Slide',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Slider Example'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Carousel Slider
          CarouselSlider(
            options: CarouselOptions(
              height: 200, // Height of the carousel
              autoPlay: true, // Auto play slides
              enlargeCenterPage: true, // Enlarge the center item
              viewportFraction: 0.8, // Visible fraction of each item
              aspectRatio: 16 / 9, // Aspect ratio
              autoPlayInterval:
                  const Duration(seconds: 3), // Interval for auto play
            ),
            items: imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Another Carousel Slider for text or categories
          const Text(
            'Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CarouselSlider(
            options: CarouselOptions(
              height: 80,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.4,
              aspectRatio: 16 / 9,
            ),
            items: ['Popular', 'New', 'Sale', 'Trending'].map((category) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blueAccent.withOpacity(0.2),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
