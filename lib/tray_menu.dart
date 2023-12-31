import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'menu_item.dart';
part 'tray_menu_method_channel.dart';
part 'tray_menu_platform_interface.dart';

mixin Menu {
  final Map<String, MenuItem> _items = {};
  final Map<int, String> _keysByHandle = {};

  Iterable<String> get keys => _items.keys;

  Future<int> _addItem(_MenuItem item, String? before) {
    final beforeHandle = _items[before]?._handle;
    return TrayMenuPlatform.instance.add(item, before: beforeHandle);
  }

  Future<MenuItemLabel> addLabel(
    String key, {
    String? before,
    required String label,
    bool enabled = true,
    Function(String, MenuItem)? callback,
  }) async {
    if (_items.containsKey(key)) throw ArgumentError('Key $key already in use');
    final handle = await _addItem(_MenuItemLabel(label, enabled), before);
    final item = MenuItemLabel._(handle, label, enabled, callback);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  Future<MenuItemSeparator> addSeparator(String key, {String? before}) async {
    if (_items.containsKey(key)) throw ArgumentError('Key $key already in use');
    final handle = await _addItem(_MenuItemSeparator(), before);
    final item = MenuItemSeparator._(handle);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  Future<MenuItemCheckbox> addCheckbox(
    String key, {
    String? before,
    required String label,
    bool enabled = true,
    bool checked = false,
    Function(String, MenuItem)? callback,
  }) async {
    if (_items.containsKey(key)) throw ArgumentError('Key $key already in use');
    final handle = await _addItem(
      _MenuItemCheckbox(label, enabled, checked),
      before,
    );
    final item = MenuItemCheckbox._(handle, label, enabled, checked, callback);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  Future<MenuItemSubmenu> addSubmenu(
    String key, {
    String? before,
    required String label,
    bool enabled = true,
  }) async {
    if (_items.containsKey(key)) throw ArgumentError('Key $key already in use');
    final handle = await _addItem(_MenuItemSubmenu(label, enabled), before);
    var item = MenuItemSubmenu._(handle, label, enabled);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  Future<void> remove(String key) async {
    final handle = _items.remove(key)?._handle;
    if (handle == null) return;
    _keysByHandle.remove(handle);
    await TrayMenuPlatform.instance.remove(handle);
  }

  T? get<T extends MenuItem>(String key) {
    final item = _items[key];
    return item is T ? item : null;
  }

  (String, MenuItem)? _getByHandle(int handle) {
    final key = _keysByHandle[handle];
    if (key != null) return (key, _items[key]!);
    for (final submenu in _items.values.whereType<MenuItemSubmenu>()) {
      final item = submenu._getByHandle(handle);
      if (item != null) return item;
    }
    return null;
  }
}

class TrayMenu with Menu {
  TrayMenu._() {
    TrayMenuPlatform.instance.init();
    TrayMenuPlatform.instance.setCallbackHandler(_handleCallbacks);
  }

  static final instance = TrayMenu._();

  Future<void> show(String iconPath) =>
      TrayMenuPlatform.instance.show(iconPath);

  static Future<void> _handleCallbacks(MethodCall methodCall) async {
    if (methodCall.method == 'itemCallback') {
      final handle = methodCall.arguments as int;
      final pair = instance._getByHandle(handle);
      if (pair == null) return;
      final (key, item) = pair;
      item.callback?.call(key, item);
    }
  }
}
