# NusaInfo Kampus — Contoh Proyek Sesi 6

Pemrograman Perangkat Mobile (IF31033) · Sesi 6: Integrasi API dan HTTP Package
Program Studi Teknik Informatika, Universitas Nusa Putra

Aplikasi ini mengambil pengumuman dari internet, menampilkan komentarnya,
mengirim pengumuman baru, dan menghapus pengumuman. Datanya berasal dari
[JSONPlaceholder](https://jsonplaceholder.typicode.com), API latihan gratis
yang tidak memerlukan pendaftaran.

## Menjalankan

```bash
flutter pub get
flutter run
```

Jalankan test (tidak butuh internet):

```bash
flutter test
```

## Isi proyek

```
lib/
├── main.dart                     Titik awal aplikasi
├── models/
│   ├── post.dart                 Post: fromJson() dan toJson()
│   └── comment.dart              Comment: fromJson()
├── services/
│   └── post_service.dart         Semua request HTTP ada di sini
├── screens/
│   ├── post_list_screen.dart     Daftar pengumuman (GET, DELETE)
│   ├── post_detail_screen.dart   Isi + komentar (GET)
│   └── add_post_screen.dart      Formulir pengumuman baru (POST)
└── widgets/
    └── error_view.dart           Pesan error + tombol "Coba Lagi"
test/
└── post_service_test.dart        Test model dan service dengan MockClient
```

Alurnya selalu satu arah: **Screen → PostService → Model**. Layar tidak
pernah membuat request sendiri; ia meminta ke `PostService`.

## Resep 4 langkah

Setiap method di `PostService` ditulis dengan urutan yang sama. Kalau Anda
hafal resep ini, Anda bisa membuat request apa pun:

| Langkah | Kode |
|---|---|
| 1. Buat alamat | `final url = Uri.parse('$baseUrl/posts');` |
| 2. Kirim request | `final response = await client.get(url).timeout(timeout);` |
| 3. Cek status code | `if (response.statusCode != 200) throw Exception(...);` |
| 4. Ubah JSON menjadi objek | `jsonDecode(response.body)` lalu `Post.fromJson(...)` |

## Membangun dari nol: 6 langkah praktik

Ikuti langkah ini di proyek baru Anda sendiri. Setiap langkah diakhiri
**Cek**: hal yang harus Anda lihat sebelum lanjut.

### Langkah 1 — Siapkan proyek

```bash
flutter create --org com.nusaputra.ppm nusainfo
cd nusainfo
flutter pub add http
```

Tambahkan izin internet di `android/app/src/main/AndroidManifest.xml`,
di atas tag `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Untuk macOS, tambahkan ke `macos/Runner/DebugProfile.entitlements` dan
`Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

**Cek:** `flutter run` berjalan tanpa error.

### Langkah 2 — Buat model `Post`

Buka https://jsonplaceholder.typicode.com/posts/1 di browser dan lihat
bentuk JSON-nya. Lalu tulis `lib/models/post.dart`. Setiap key JSON menjadi
satu field.

**Cek:** test `Post fromJson membaca semua field` lulus.

### Langkah 3 — Ambil data dengan `fetchPosts()`

Tulis `lib/services/post_service.dart`, cukup method `fetchPosts()` dulu.
Coba panggil dari `main()`:

```dart
void main() async {
  final posts = await PostService().fetchPosts();
  print('Jumlah pengumuman: ${posts.length}');
}
```

**Cek:** konsol menampilkan `Jumlah pengumuman: 100`.

### Langkah 4 — Tampilkan dengan `FutureBuilder`

Tulis `lib/screens/post_list_screen.dart` dan `lib/widgets/error_view.dart`.
Perhatikan tiga keadaan di `_buildBody()`: menunggu, gagal, berhasil.

**Cek:** daftar pengumuman tampil. Matikan Wi-Fi/data emulator, lalu tarik
layar ke bawah → pesan error muncul, aplikasi tidak crash.

### Langkah 5 — Halaman detail dan komentar

Tambahkan `Comment`, `fetchComments()`, dan `post_detail_screen.dart`.

**Cek:** ketuk satu pengumuman → isi dan 5 komentar tampil.

### Langkah 6 — Kirim (POST) dan hapus (DELETE)

Tambahkan `createPost()`, `deletePost()`, dan `add_post_screen.dart`.

**Cek:** tombol **Buat** → isi formulir → **Kirim** → pengumuman baru muncul
paling atas dengan id 101. Geser pengumuman ke kiri → terhapus.

## Endpoint yang dipakai

| Metode | Endpoint | Dipakai di | Status sukses |
|---|---|---|---|
| GET | `/posts` | `fetchPosts()` | 200 OK |
| GET | `/posts/{id}/comments` | `fetchComments()` | 200 OK |
| POST | `/posts` | `createPost()` | 201 Created |
| DELETE | `/posts/{id}` | `deletePost()` | 200 OK |

**Penting:** JSONPlaceholder hanya *berpura-pura* menyimpan. POST dan DELETE
dibalas sukses, tetapi data di server tidak berubah. Karena itu aplikasi
menambah/menghapus item di daftar lokal setelah server membalas sukses, dan
setiap pengumuman baru selalu mendapat id 101.

## Kesalahan yang sering terjadi

| Gejala | Penyebab | Solusi |
|---|---|---|
| Jalan di debug, gagal di APK release | Izin INTERNET belum ditambahkan | Tambahkan `<uses-permission ...INTERNET/>` di `src/main/AndroidManifest.xml` |
| `type 'List<dynamic>' is not a subtype of type 'List<Post>'` | Hasil `jsonDecode` langsung dianggap `List<Post>` | Petakan satu per satu: `data.map((item) => Post.fromJson(item)).toList()` |
| Request terkirim berulang-ulang | `fetchPosts()` dipanggil di dalam `build()` | Panggil sekali di `initState()`, simpan di variabel `Future` |
| Server di laptop tidak bisa diakses dari emulator Android | `localhost` di emulator berarti emulator itu sendiri | Pakai alamat `10.0.2.2` |
| Error CORS saat `flutter run -d chrome` | Aturan keamanan browser | Pakai emulator/HP, atau server yang mengizinkan CORS |
| `type 'Null' is not a subtype of type 'String'` | Key JSON salah ketik (`'userID'` vs `'userId'`) | Samakan dengan JSON asli, perhatikan huruf besar/kecil |
