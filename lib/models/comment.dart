/// Satu komentar pada pengumuman.
///
/// Contoh JSON dari GET /posts/1/comments:
///
/// ```json
/// {
///   "postId": 1,
///   "id": 1,
///   "name": "id labore ex et quam laborum",
///   "email": "Eliseo@gardner.biz",
///   "body": "laudantium enim quasi ..."
/// }
/// ```
class Comment {
  final int id;
  final String name;
  final String email;
  final String body;

  const Comment({
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}
