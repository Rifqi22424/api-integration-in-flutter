import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Mengubah error teknis menjadi kalimat yang dimengerti pengguna.
String pesanError(Object error) {
  if (error is TimeoutException) {
    return 'Server terlalu lama merespons. Coba lagi sebentar lagi.';
  }
  if (error is http.ClientException) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  return error.toString().replaceFirst('Exception: ', '');
}

/// Tampilan saat request gagal: pesan + tombol "Coba Lagi".
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              pesanError(error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
