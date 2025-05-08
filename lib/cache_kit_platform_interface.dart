import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cache_kit_method_channel.dart';

abstract class CacheKitPlatform extends PlatformInterface {
  /// Constructs a CacheKitPlatform.
  CacheKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static CacheKitPlatform _instance = MethodChannelCacheKit();

  /// The default instance of [CacheKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelCacheKit].
  static CacheKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CacheKitPlatform] when
  /// they register themselves.
  static set instance(CacheKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Clears all application data stored in the cache.
  ///
  /// This method should be implemented by platform-specific subclasses
  /// to perform a full cleanup of the app's cache data. The implementation
  /// should ensure that all cached files and data are removed, effectively
  /// resetting the application's cache state.
  ///
  /// Returns a [Future] that completes with a boolean indicating whether
  /// the cache was successfully cleared.
  Future<bool> clearAppData() {
    throw UnimplementedError('clearAppData() has not been implemented.');
  }
}
