import 'package:flutter_test/flutter_test.dart';
// import 'package:cache_kit/cache_kit.dart';
import 'package:cache_kit/cache_kit_platform_interface.dart';
import 'package:cache_kit/cache_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCacheKitPlatform with MockPlatformInterfaceMixin implements CacheKitPlatform {
  @override
  Future<bool> clearAppData() => Future.value(true);
}

void main() {
  final CacheKitPlatform initialPlatform = CacheKitPlatform.instance;

  test('$MethodChannelCacheKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCacheKit>());
  });

  test('clear_app_data', () async {
    final fakePlatform = MockCacheKitPlatform();
    CacheKitPlatform.instance = fakePlatform;
    expect(await CacheKitPlatform.instance.clearAppData(), isTrue);
  });
}

