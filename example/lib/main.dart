import 'dart:typed_data';

import 'package:cache_kit/cache_kit.dart';
import 'models/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

// ============================================================================
// • UTILITIES
// ============================================================================

/// Quick byte‑size formatter used across the demo.
extension ByteFormat on num {
  String toBytes([int decimals = 1]) {
    if (this <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(decimals)} ${units[i]}';
  }
}

void main() => runApp(const CacheKitExampleApp());

// ============================================================================
// • ROOT
// ============================================================================

/// Wraps the demo with [CacheKitScope] so every widget can access cache APIs.
class CacheKitExampleApp extends StatelessWidget {
  const CacheKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CacheKitScope(
      saveDirectory: 'CacheKitExample',
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'cache_kit Demo',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
        home: const HomePage(),
      ),
    );
  }
}

// ============================================================================
// • HOME PAGE
// ============================================================================

/// Two‑tab layout:
/// * **Chat** – download/open media with cache_k​it.
/// * **Storage** – stats & selective/​full cache cleaning.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _clearAll() async {
    await CacheKitScope.of(context).clearAppData();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cache_kit Example'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
            Tab(icon: Icon(Icons.storage), text: 'Storage'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Clear ALL caches',
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Clear application data?'),
                  content: const Text('This will delete ALL cached files produced by this demo.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
          );
          if (confirmed == true) await _clearAll();
        },
        child: const Icon(Icons.cleaning_services),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_ChatTab(dio: _dio, refresh: () => setState(() {})), const _StorageTab()],
      ),
    );
  }
}

// ============================================================================
// • CHAT TAB
// ============================================================================

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.dio, required this.refresh});

  final Dio dio;
  final VoidCallback refresh;

  Future<void> _downloadAndOpen(BuildContext context, Message msg) async {
    final cache = CacheKitScope.of(context);
    final fileName = msg.fileName;
    if (fileName == null) return;

    // Already cached?
    final cached = await cache.getFile(fileName);
    if (cached != null) {
      await OpenFilex.open(cached.path);
      return;
    }

    // Progress indicator.
    final progress = ValueNotifier<double>(0);
    final snack = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(minutes: 5),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, value, __) => Text('Downloading ${(value * 100).toStringAsFixed(0)} %'),
        ),
      ),
    );

    try {
      final res = await dio.get<List<int>>(
        msg.content,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (rec, total) {
          if (total > 0) progress.value = rec / total;
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        await cache.save(Uint8List.fromList(res.data!), fileName: fileName);
        progress.value = 1;
        snack.close();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to cache ✅')));
        refresh();
      } else {
        throw Exception('Download failed (${res.statusCode})');
      }
    } catch (e) {
      snack.close();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      progress.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: demoMessages.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, i) {
        final m = demoMessages[i];
        return ListTile(
          leading: Icon(switch (m.type) {
            MessageType.text => Icons.text_snippet,
            MessageType.image => Icons.image,
            MessageType.video => Icons.videocam,
            MessageType.audio => Icons.audiotrack,
            MessageType.file  => Icons.insert_drive_file,
          }),
          title: Text(switch (m.type) {
            MessageType.text => m.content,
            _ => m.fileName ?? m.content,
          }),
          subtitle: Text(_since(m.timestamp)),
          onTap: () => _downloadAndOpen(context, m),
          trailing:
              m.type == MessageType.text
                  ? null
                  : FutureBuilder(
                    future: CacheKitScope.of(context).getFile(m.fileName!),
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      final exists = snap.data != null;
                      return Icon(exists ? Icons.open_in_new : Icons.cloud_download_outlined);
                    },
                  ),
        );
      },
    );
  }

  String _since(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ============================================================================
// • STORAGE TAB
// ============================================================================

class _StorageTab extends StatelessWidget {
  const _StorageTab();

  @override
  Widget build(BuildContext context) {
    final cache = CacheKitScope.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MediaType.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final mediaType = MediaType.values[idx];

        return Card(
          child: ListTile(
            title: Text(mediaType.name[0].toUpperCase() + mediaType.name.substring(1)),
            subtitle: FutureBuilder(
              future: Future.wait([cache.getFileCount(mediaType), cache.getTotalSize(mediaType)]),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(minHeight: 2);
                }
                if (snap.hasError) return const Text('Error');
                final count = snap.data![0];
                final size = snap.data![1];
                return Text('$count files • ${(size).toBytes()}');
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: Text('Clear ${mediaType.name} cache?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                        ],
                      ),
                );
                if (ok == true) {
                  await cache.clearCache(types: [mediaType]);
                  (context as Element).markNeedsBuild();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
