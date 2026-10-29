import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../models/post.dart';

/// Semua komunikasi dengan server ada di kelas ini.
///
/// Layar (screens) cukup memanggil method di sini, tanpa perlu tahu
/// alamat URL, header, atau cara membaca JSON.
///
/// Setiap method mengikuti RESEP 4 LANGKAH yang sama:
///   1. Buat alamat (Uri)
///   2. Kirim request, lalu tunggu response (await)
///   3. Cek status code
///   4. Ubah JSON menjadi objek Dart
class PostService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Batas waktu menunggu server. Lewat dari ini, request dianggap gagal.
  static const Duration timeout = Duration(seconds: 10);

  /// Client bisa diganti dengan MockClient saat testing
  /// (lihat test/post_service_test.dart).
  final http.Client client;

  PostService({http.Client? client}) : client = client ?? http.Client();

  /// GET /posts — ambil semua pengumuman.
  Future<List<Post>> fetchPosts() async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts');

    // 2. Kirim request
    final response = await client.get(url).timeout(timeout);

    // 3. Cek status code (200 = OK)
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat pengumuman (kode ${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Post.fromJson(item)).toList();
  }

  /// GET /posts/{id}/comments — ambil komentar milik satu pengumuman.
  Future<List<Comment>> fetchComments(int postId) async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts/$postId/comments');

    // 2. Kirim request
    final response = await client.get(url).timeout(timeout);

    // 3. Cek status code
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat komentar (kode ${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Comment.fromJson(item)).toList();
  }

  /// POST /posts — kirim pengumuman baru.
  ///
  /// Server membalas dengan pengumuman yang sudah diberi `id`.
  Future<Post> createPost(Post post) async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts');

    // 2. Kirim request beserta header dan body JSON
    final response = await client
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(post.toJson()),
        )
        .timeout(timeout);

    // 3. Cek status code (201 = Created, data baru berhasil dibuat)
    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim pengumuman (kode ${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    return Post.fromJson(jsonDecode(response.body));
  }

  /// DELETE /posts/{id} — hapus pengumuman.
  Future<void> deletePost(int id) async {
    // 1. Buat alamat
    final url = Uri.parse('$baseUrl/posts/$id');

    // 2. Kirim request
    final response = await client.delete(url).timeout(timeout);

    // 3. Cek status code
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pengumuman (kode ${response.statusCode})');
    }

    // 4. Tidak ada data yang perlu dibaca dari response DELETE.
  }
}
