import 'package:cache_kit/cache_kit.dart';
import 'package:cache_kit/management/data/interfaces/cache_kit_interface.dart';
import 'package:flutter/material.dart';

class CacheKitScope extends StatelessWidget {
  const CacheKitScope({super.key, required this.child, required this.saveDirectory});

  final Widget child;
  final String saveDirectory;

  static CacheKitInterface of(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<CacheKitScopeProvider>();
    if (element == null) {
      throw Exception('StorageManagerScope not found in context');
    }
    final provider = element.widget as CacheKitScopeProvider;
    return provider.storageManager;
  }

  @override
  Widget build(BuildContext context) =>
      CacheKitScopeProvider(storageManager: CacheKit(saveDirectory: saveDirectory), child: child);
}

class CacheKitScopeProvider extends InheritedWidget {
  const CacheKitScopeProvider({super.key, required this.storageManager, required super.child});
  final CacheKitInterface storageManager;

  @override
  bool updateShouldNotify(CacheKitScopeProvider oldWidget) => false;
}
