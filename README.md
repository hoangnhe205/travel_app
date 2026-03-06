# Ứng Dụng Du Lịch Việt Nam (Flutter & Firebase)
**Sinh viên thực hiện:** TH3-Nguyễn Việt Hoàng-2351160522

---

## I. TỔNG QUAN VỀ CHỨC NĂNG VÀ GIAO DIỆN CHUNG

Ứng dụng là một nền tảng khám phá địa điểm du lịch hiện đại, được xây dựng bằng Flutter với ngôn ngữ thiết kế **Material Design 3**.

### 1. Chức năng chính:
*   **Quản lý dữ liệu (CRUD):** Thêm mới, chỉnh sửa và xóa các địa điểm du lịch trực tiếp trên nền tảng Cloud Firestore.
*   **Tích hợp Bản đồ:** Mỗi địa điểm có tọa độ GPS riêng. Người dùng có thể nhấn "XEM TRÊN BẢN ĐỒ" để định vị địa điểm qua bản đồ tương tác (OpenStreetMap).
*   **Đánh giá (Rating):** Hiển thị điểm đánh giá sao cho từng địa điểm, giúp người dùng dễ dàng lựa chọn.
*   **Tìm kiếm & Lọc:** Thanh tìm kiếm thời gian thực và hệ thống Chip Filter theo vùng miền (Miền Bắc, Miền Trung, Miền Nam).
*   **Yêu thích (Favorites):** Lưu trữ danh sách địa điểm yêu thích bền vững trên thiết bị.
*   **Chế độ Giao diện:** Chuyển đổi linh hoạt Light Mode/Dark Mode và tự động ghi nhớ lựa chọn.

### 2. Đặc điểm Giao diện:
*   **Layout nâng cao:** Sử dụng `CustomScrollView` và `SliverAppBar` tạo hiệu ứng cuộn mượt mà và ảnh bìa co giãn.
*   **Hiệu ứng mượt mà:** Tích hợp **Hero Animation** để chuyển tiếp hình ảnh giữa màn hình danh sách và chi tiết.
*   **Bản đồ Marker:** Đánh dấu vị trí chính xác của địa điểm bằng biểu tượng Marker trên màn hình bản đồ riêng biệt.

---

## II. LUỒNG ỨNG DỤNG VÀ NGUỒN DỮ LIỆU

### 1. Nguồn dữ liệu (Data Source):
*   **Cloud Firestore:** Lưu trữ tập trung Tên, Ảnh, Mô tả, Vùng miền, Tọa độ (Lat/Lng) và Rating.
*   **Shared Preferences:** Lưu trữ cục bộ trạng thái giao diện và danh sách yêu thích.

### 2. Luồng ứng dụng (App Flow):
1.  **Màn hình Home:** Nhận dữ liệu từ Firestore qua `Stream`. Sắp xếp danh sách theo tên và lọc theo vùng miền đã chọn.
2.  **Màn hình Chi tiết:** Nhận đối tượng `Place` từ Home. Hiển thị thông tin mô tả chi tiết, điểm đánh giá và tọa độ.
3.  **Màn hình Bản đồ:** Được mở từ trang chi tiết thông qua `Navigator`. Sử dụng plugin `flutter_map` để hiển thị vị trí thực tế của địa điểm trên bản đồ toàn cầu.

---

## III. CẤU TRÚC MÃ NGUỒN

*   **Model (`Place`):** Định nghĩa cấu trúc dữ liệu gồm các trường: name, imageUrl, shortDesc, longDesc, region, lat, lng, rating.
*   **Màn hình chính:** `HomePage`, `DetailPage`, `MapScreen` (Màn hình bản đồ mới), `AddEditPage`.
*   **Thư viện sử dụng:** `firebase_core`, `cloud_firestore`, `flutter_map`, `latlong2`, `shared_preferences`.

---

## Hướng dẫn chạy ứng dụng

1. Đóng các bản chạy cũ để tránh lỗi xung đột file (errno 32).
2. Chạy lệnh:
   ```bash
   flutter clean
   flutter pub get
   ```
3. Nhấn Run trên Android Studio hoặc dùng lệnh:
   ```bash
   flutter run
   ```
