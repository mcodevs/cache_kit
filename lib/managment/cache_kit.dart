import 'dart:io' show Directory, File, Platform;
import 'dart:typed_data' show Uint8List;

import 'package:cache_kit/cache_kit_platform_interface.dart';
import 'package:cache_kit/managment/data/extensions/extensions.dart';
import 'package:cache_kit/managment/data/interfaces/cache_kit_interface.dart';
import 'package:cache_kit/managment/data/models/media_type.dart';
import 'package:path_provider/path_provider.dart';

/// Main entry point for *cache_kit*: a platform‑agnostic cache manager.
///
/// Implements [CacheKitInterface] and exposes high‑level APIs to save, fetch,
/// inspect, and purge cached media. Each instance stores its data under the
/// provided [saveDirectory] inside the system temporary folder.
///
/// Use one shared `CacheKit` object for the whole app to avoid duplicated
/// directories.
class CacheKit extends CacheKitInterface {
  final String saveDirectory;

  const CacheKit({required this.saveDirectory});

  /// Persist [bytes] on disk under [fileName].  
  /// If [mediaType] is not supplied it is inferred from the filename’s extension.
  @override
  Future<void> save(Uint8List bytes, {required String fileName, MediaType? mediaType}) async {
    mediaType ??= _getMediaTypeFromFileName(fileName);
    final directory = await getMediaDirectory(mediaType);
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return;
  }

  /// Infer [MediaType] from a filename, throwing [FormatException] if no valid extension exists.
  MediaType _getMediaTypeFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension.isEmpty || !fileName.contains('.')) {
      throw FormatException(
        'Invalid file name: "$fileName". Please include a valid extension, for example "photo.jpg".',
      );
    }
    return _mediaTypeFromExtension(extension);
  }

  /// Map a lowercase file extension to its corresponding [MediaType].
  MediaType _mediaTypeFromExtension(String extension) {
    return switch (extension) {
      String value when Extensions.video.contains(value) => MediaType.video,
      String value when Extensions.image.contains(value) => MediaType.image,
      String value when Extensions.music.contains(value) => MediaType.music,
      _ => MediaType.file,
    };
  }

  /// Lazily create & return the root cache directory (`<tmp>/<saveDirectory>`).
  @override
  Future<Directory> get getCacheDirectory async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$saveDirectory';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Return (or create) the sub‑directory dedicated to [mediaType].
  @override
  Future<Directory> getMediaDirectory(MediaType mediaType) async {
    final directory = await getCacheDirectory;
    final path = '${directory.path}/${mediaType.directory}';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Fetch a cached file by name; returns `null` if it does not exist.
  @override
  Future<File?> getFile(String fileName, {MediaType? mediaType}) async {
    mediaType ??= _getMediaTypeFromFileName(fileName);

    final directory = await getMediaDirectory(mediaType);

    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);

    if (!await file.exists()) return null;

    return file;
  }

  /// Delete cached files for the provided [types], or all media types when omitted.
  @override
  Future<void> clearCache({List<MediaType>? types}) async {
    final mediaTypes = types ?? MediaType.values;
    for (final type in mediaTypes) {
      final dir = await getMediaDirectory(type);
      final files = dir.listSync().whereType<File>();
      for (final file in files) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  /// Count cached files belonging to [mediaType].
  @override
  Future<int> getFileCount(MediaType mediaType) async {
    final directory = await getMediaDirectory(mediaType);
    final files = directory.listSync().whereType<File>();
    return files.length;
  }

  /// Compute total size (bytes) of cached files for [mediaType].
  @override
  Future<int> getTotalSize(MediaType mediaType) async {
    final directory = await getMediaDirectory(mediaType);
    final files = directory.listSync().whereType<File>();
    int totalBytes = 0;
    for (final file in files) {
      try {
        totalBytes += await file.length();
      } catch (_) {}
    }
    return totalBytes;
  }

  /// Invoke platform‑native full‑data clean‑up; falls back to manual deletion.
  @override
  Future<void> clearAppData() async {
    final bool success = await CacheKitPlatform.instance.clearAppData();
    if (success) return;
    _clearByDeletingFiles();
  }

  /// Fallback strategy when platform‑native clear fails: delete known app directories.
  Future<void> _clearByDeletingFiles() async {
    final docDir = await getApplicationDocumentsDirectory();
    await _deleteDirContents(docDir.parent);

    final cacheDir = await getTemporaryDirectory();
    await _deleteDirContents(cacheDir);

    if (Platform.isIOS) {
      final supportDir = await getApplicationSupportDirectory();
      await _deleteDirContents(supportDir);
    }
  }

  /// Recursively delete all files and sub‑directories inside [dir].
  Future<void> _deleteDirContents(Directory dir) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list(recursive: false)) {
      try {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        } else {
          await entity.delete(recursive: true);
        }
      } catch (_) {}
    }
  }
}
