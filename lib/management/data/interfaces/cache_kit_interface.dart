import 'dart:io';
import 'dart:typed_data';

import 'package:cache_kit/management/data/models/media_type.dart';

/// Contract that defines all cache‑management operations used by *cache_kit*.
///
/// Platform‑specific implementations (e.g. Android, iOS, Desktop) must
/// implement this interface so that the package can:
/// * save media bytes to persistent storage,
/// * retrieve files on demand,
/// * compute statistics (count / size),
/// * and perform selective or full clean‑ups.
///
/// All methods are asynchronous and must never block the UI thread.
abstract class CacheKitInterface {
  /// Default constant constructor (allows subclasses to be `const`).
  const CacheKitInterface();

  /// Persist raw [bytes] to cache.  
  /// If [mediaType] is omitted the type is inferred from [fileName]'s extension.
  Future<void> save(Uint8List bytes, {required String fileName, MediaType? mediaType});

  /// Return a cached file by [fileName] (or `null` if it does not exist).
  Future<File?> getFile(String fileName, {MediaType? mediaType});

  /// Root directory used by *cache_kit* to store all cached data.
  Future<Directory> get getCacheDirectory;

  /// Sub‑directory for a given [mediaType] (e.g. video/, image/).
  Future<Directory> getMediaDirectory(MediaType mediaType);

  /// Total number of cached files of the specified [mediaType].
  Future<int> getFileCount(MediaType mediaType);

  /// Aggregate size in bytes of cached files of the specified [mediaType].
  Future<int> getTotalSize(MediaType mediaType);

  /// Delete cached files for the provided [types]; if `null`, clears *all* caches.
  Future<void> clearCache({List<MediaType>? types});

  /// Remove application‑level cache and temp data (may be platform‑limited).
  Future<void> clearAppData();
}
