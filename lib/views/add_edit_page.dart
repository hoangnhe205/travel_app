import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

class AddEditPage extends StatefulWidget {
  const AddEditPage({super.key, this.place});
  final Place? place;

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _url, _short, _long, _lat, _lng, _rating;
  
  // Danh sách vùng miền chuẩn
  final List<String> _categories = ['Miền Bắc', 'Miền Trung', 'Miền Nam', 'Tất cả'];
  String _cat = 'Miền Bắc';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.place?.name);
    _url = TextEditingController(text: widget.place?.imageUrl);
    _short = TextEditingController(text: widget.place?.shortDesc);
    _long = TextEditingController(text: widget.place?.longDesc);
    _lat = TextEditingController(text: (widget.place?.lat ?? 21.0285).toString());
    _lng = TextEditingController(text: (widget.place?.lng ?? 105.8542).toString());
    _rating = TextEditingController(text: (widget.place?.rating ?? 4.5).toString());
    
    // KHẮC PHỤC LỖI CHỈNH SỬA:
    if (widget.place != null) {
      // Nếu danh mục cũ không có trong danh sách mới (vd: "Biển đảo"), ép về "Tất cả" để không crash
      if (_categories.contains(widget.place!.category)) {
        _cat = widget.place!.category;
      } else {
        _cat = 'Tất cả'; 
      }
    }
  }

  @override
  void dispose() {
    _name.dispose(); _url.dispose(); _short.dispose(); _long.dispose();
    _lat.dispose(); _lng.dispose(); _rating.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final col = FirebaseFirestore.instance.collection('places');
      final data = {
        'name': _name.text.trim(),
        'imageUrl': _url.text.trim(),
        'shortDesc': _short.text.trim(),
        'longDesc': _long.text.trim(),
        'category': _cat,
        'lat': double.tryParse(_lat.text) ?? 21.0285,
        'lng': double.tryParse(_lng.text) ?? 105.8542,
        'rating': double.tryParse(_rating.text) ?? 4.5,
      };

      try {
        if (widget.place == null) {
          await col.add(data);
        } else {
          await col.doc(widget.place!.id).update(data);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu dữ liệu thành công'), behavior: SnackBarBehavior.floating),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.place != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Địa Điểm' : 'Thêm Địa Điểm Mới'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField(_name, 'Tên địa điểm', Icons.map, 'Vui lòng nhập tên'),
            const SizedBox(height: 16),
            _buildField(_url, 'Link ảnh (URL)', Icons.image, 'Vui lòng nhập link ảnh'),
            const SizedBox(height: 16),
            _buildField(_short, 'Mô tả ngắn', Icons.short_text, 'Vui lòng nhập mô tả ngắn'),
            const SizedBox(height: 16),
            _buildField(_long, 'Mô tả chi tiết', Icons.description, 'Vui lòng nhập chi tiết', maxLines: 5),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField(_lat, 'Vĩ độ (Lat)', Icons.location_on, 'Nhập vĩ độ', isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildField(_lng, 'Kinh độ (Lng)', Icons.location_on, 'Nhập kinh độ', isNumber: true)),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(_rating, 'Đánh giá (1-5 sao)', Icons.star, 'Nhập điểm 1-5', isNumber: true),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _cat,
              decoration: InputDecoration(
                labelText: 'Vùng miền',
                prefixIcon: const Icon(Icons.category, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.blue[50]!.withOpacity(0.3),
              ),
              items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _cat = v!),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'CẬP NHẬT THAY ĐỔI' : 'LƯU ĐỊA ĐIỂM', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, String error, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true, fillColor: Colors.grey[50],
      ),
      validator: (v) => v == null || v.isEmpty ? error : null,
    );
  }
}
