import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/error_view.dart';
import 'add_post_screen.dart';
import 'post_detail_screen.dart';

/// Halaman utama: daftar pengumuman dari server.
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key, required this.service});

  final PostService service;

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  // Future disimpan di state dan dibuat SEKALI di initState().
  // Jika fetchPosts() dipanggil di dalam build(), request akan terkirim
  // ulang setiap kali layar digambar ulang.
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = widget.service.fetchPosts();
  }

  /// Dipanggil oleh tarik-untuk-muat-ulang dan tombol "Coba Lagi".
  Future<void> _reload() async {
    setState(() {
      _postsFuture = widget.service.fetchPosts();
    });
    try {
      await _postsFuture;
    } catch (_) {
      // Error sudah ditampilkan oleh FutureBuilder, tidak perlu apa-apa lagi.
    }
  }

  Future<void> _openAddPost(List<Post> posts) async {
    // AddPostScreen mengembalikan Post baru jika berhasil dikirim.
    final newPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => AddPostScreen(service: widget.service)),
    );
    if (newPost == null || !mounted) return;

    // JSONPlaceholder tidak benar-benar menyimpan data,
    // jadi kita tambahkan sendiri ke daftar yang sedang tampil.
    setState(() => posts.insert(0, newPost));
    _showMessage('Pengumuman terkirim. Server memberi id ${newPost.id}.');
  }

  /// Dipanggil saat kartu digeser. Mengembalikan true jika boleh dihapus.
  Future<bool> _deletePost(Post post) async {
    try {
      await widget.service.deletePost(post.id);
      _showMessage('"${post.title}" dihapus.');
      return true;
    } catch (error) {
      _showMessage(pesanError(error));
      return false; // Gagal: kartu dikembalikan ke tempatnya.
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('NusaInfo Kampus')),
          body: _buildBody(snapshot),
          floatingActionButton: snapshot.hasData
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddPost(snapshot.data!),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Post>> snapshot) {
    // Keadaan 1: masih menunggu response
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Keadaan 2: request gagal
    if (snapshot.hasError) {
      return ErrorView(error: snapshot.error!, onRetry: _reload);
    }

    // Keadaan 3: data berhasil diterima
    final posts = snapshot.data!;
    if (posts.isEmpty) {
      return const Center(child: Text('Belum ada pengumuman.'));
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: posts.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final post = posts[index];
          return Dismissible(
            // ObjectKey, bukan ValueKey(post.id): semua post baru dari
            // JSONPlaceholder mendapat id yang sama (101).
            key: ObjectKey(post),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_outline),
            ),
            confirmDismiss: (_) => _deletePost(post),
            onDismissed: (_) => setState(() => posts.remove(post)),
            child: ListTile(
              leading: CircleAvatar(child: Text('${post.id}')),
              title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: post, service: widget.service),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
