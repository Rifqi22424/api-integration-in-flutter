/// Satu pengumuman kampus.
///
/// Data ini datang dari server dalam bentuk JSON, contohnya:
///
/// ```json
/// {
///   "userId": 1,
///   "id": 1,
///   "title": "Jadwal UTS semester ganjil",
///   "body": "UTS dimulai tanggal ..."
/// }
/// ```
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// JSON -> Post. Dipakai setelah MENERIMA data dari server.
  ///
  /// Nama key ('userId', 'title', ...) harus sama persis dengan JSON.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Post -> JSON. Dipakai saat MENGIRIM data ke server.
  ///
  /// `id` tidak dikirim karena server yang akan membuatkannya.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}
