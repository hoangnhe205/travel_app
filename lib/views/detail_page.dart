import 'package:flutter/material.dart';
import '../models/place.dart';
import 'map_screen.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300, 
            pinned: true, 
            flexibleSpace: FlexibleSpaceBar(
              title: Text(place.name, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 10)])), 
              background: Hero(tag: place.id, child: Image.network(place.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey)))
            )
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20), 
                      Text(place.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                    ]
                  ),
                  const SizedBox(height: 16),
                  const Text('Mô tả', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(place.longDesc, style: const TextStyle(fontSize: 16, height: 1.6)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(place: place))), 
                    icon: const Icon(Icons.map), 
                    label: const Text('Xem trên bản đồ'), 
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56))
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
