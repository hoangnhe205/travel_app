import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';
import 'detail_page.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onThemeToggle, required this.currentThemeMode});
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '', _selectedRegion = 'Tất cả';
  Set<String> _favorites = {};
  Key _streamKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _favorites = (prefs.getStringList('favorites') ?? []).toSet());
  }

  Future<void> _toggleFav(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _favorites.contains(name) ? _favorites.remove(name) : _favorites.add(name));
    await prefs.setStringList('favorites', _favorites.toList());
  }

  Future<void> _deletePlace(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xoá địa điểm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('places').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentThemeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('TH3 - Nguyễn Việt Hoàng - 2351160522', 
             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.blue[200] : Colors.blue[900])),
        actions: [
          IconButton(icon: const Icon(Icons.favorite, color: Colors.blue), onPressed: () {}),
          IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onThemeToggle),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        key: _streamKey,
        stream: FirebaseFirestore.instance.collection('places').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 80, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Không có kết nối Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const Text('Vui lòng kiểm tra kết nối mạng và thử lại', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() => _streamKey = UniqueKey()),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingGrid();
          }

          final places = snapshot.data!.docs.map((doc) => Place.fromFirestore(doc)).toList();
          final filtered = places.where((p) {
            final matchQuery = p.name.toLowerCase().contains(_query.toLowerCase());
            final matchRegion = _selectedRegion == 'Tất cả' || p.category == _selectedRegion;
            return matchQuery && matchRegion;
          }).toList();

          return Column(
            children: [
              _buildFilters(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBar(
                  hintText: 'Tìm địa điểm...',
                  onChanged: (v) => setState(() => _query = v),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(isDark ? Colors.grey[900] : Colors.grey[100]),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _buildPlaceCard(filtered[i], isDark),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditPage())),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['Tất cả', 'Miền Bắc', 'Miền Trung', 'Miền Nam'].map((cat) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(cat),
            selected: _selectedRegion == cat,
            onSelected: (s) => setState(() => _selectedRegion = cat),
            selectedColor: Colors.blue,
            labelStyle: TextStyle(color: _selectedRegion == cat ? Colors.white : Colors.black),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPlaceCard(Place p, bool isDark) {
    final isFav = _favorites.contains(p.name);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(place: p))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: p.id,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(p.imageUrl, height: 120, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey[300], child: const Icon(Icons.image_not_supported))),
                  ),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditPage(place: p))),
                        style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.7)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                        onPressed: () => _deletePlace(p.id),
                        style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(p.shortDesc, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: Text(p.category, style: const TextStyle(fontSize: 9, color: Colors.blue))),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 12),
                          Text(p.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          GestureDetector(onTap: () => _toggleFav(p.name), child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey, size: 16)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
      itemCount: 4,
      itemBuilder: (context, i) => Card(color: Colors.grey[200], elevation: 0),
    );
  }
}
