import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.8),
              colorBlendMode: BlendMode.darken,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.red, size: 40),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Smart Parking',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Experience seamless parking with real-time slot availability, smart predictions, and effortless access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  
                  // Added Fast and Secure Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureIcon(Icons.bolt, 'FAST'),
                      const SizedBox(width: 24),
                      _buildFeatureIcon(Icons.shield, 'SECURE'),
                      const SizedBox(width: 24),
                      _buildFeatureIcon(Icons.psychology, 'SMART'),
                    ],
                  ),
                  
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/driver/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.local_parking, color: Colors.white, size: 28,),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Find Parking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('Locate available parking spots in real time', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  '© 2024 Smart Parking. All rights reserved.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }
}
