import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cache_kit/cache_kit_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCacheKit platform = MethodChannelCacheKit();
  const MethodChannel channel = MethodChannel('cache_kit');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return switch (methodCall.method) {
        'clear_app_data' => true,
        _ => throw MissingPluginException('not implemented'),
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('clear_app_data', () async {
    expect(await platform.clearAppData(), true);
  });
}

