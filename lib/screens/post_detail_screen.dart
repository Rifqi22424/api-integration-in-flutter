import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/error_view.dart';

/// Isi lengkap satu pengumuman beserta komentarnya.
///
/// Isi pengumuman sudah kita punya dari halaman daftar,
/// jadi yang perlu diambil dari server hanya komentarnya.
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post, required this.service});

  final Post post;
  final PostService service;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.service.fetchComments(widget.post.id);
  }

  void _reload() {
    setState(() {
      _commentsFuture = widget.service.fetchComments(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #${widget.post.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.post.title, style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(widget.post.body, style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Komentar', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Comment>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return ErrorView(error: snapshot.error!, onRetry: _reload);
              }
              final comments = snapshot.data!;
              return Column(
                children: [
                  for (final comment in comments)
                    Card(
                      child: ListTile(
                        title: Text(comment.name),
                        subtitle: Text('${comment.email}\n${comment.body}'),
                        isThreeLine: true,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
