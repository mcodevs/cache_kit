import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cache_kit_platform_interface.dart';

/// An implementation of [CacheKitPlatform] that uses method channels.
class MethodChannelCacheKit extends CacheKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cache_kit');

  @override
  Future<bool> clearAppData() async {
    return await methodChannel.invokeMethod<bool>('clear_app_data') ?? false;
  }
}
