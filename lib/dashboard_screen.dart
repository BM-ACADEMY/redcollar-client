import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orders Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOrderCard(
                    context,
                    'All Orders',
                    Icons.folder,
                    Colors.blue,
                    '5',
                  ),
                  _buildOrderCard(
                    context,
                    'Packaging',
                    Icons.archive,
                    Colors.yellow,
                    '3',
                  ),
                  _buildOrderCard(
                    context,
                    'Delivered',
                    Icons.local_shipping,
                    Colors.blueAccent,
                    '1',
                  ),
                  _buildOrderCard(
                    context,
                    'Completed',
                    Icons.check_circle,
                    Colors.green,
                    '1',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Order Status Chart
              const Text(
                'Orders Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.yellow,
                        value: 60,
                        title: '60%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.black),
                      ),
                      PieChartSectionData(
                        color: Colors.blue,
                        value: 20,
                        title: '20%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: 20,
                        title: '20%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Top 5 Selling Products
              const Text(
                'Top 5 Selling Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildProductRow('Nike Kids Air Max 270', '1'),
                  _buildProductRow('Adidas Copa Mundial', '2'),
                  _buildProductRow('Nike FC Barcelona Jersey', '3'),
                  _buildProductRow('Adidas Bayern Munich Jersey', '4'),
                  _buildProductRow('Nike Paris Saint-Germain', '5'),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black87,
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    String count,
  ) {
    return Expanded(
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(String productName, String rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(rank),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              productName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
