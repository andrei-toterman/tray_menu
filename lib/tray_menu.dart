import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'menu_item.dart';
part 'tray_menu_method_channel.dart';
part 'tray_menu_platform_interface.dart';

/// A container that holds multiple [MenuItem]s
mixin Menu {
  /// A mapping from user-provided keys to menu items.
  final Map<String, MenuItem> _items = {};

  /// A mapping from implementation-provided menu item handles to their user-provided keys.
  final Map<int, String> _keysByHandle = {};

  /// An iterator of all the keys used in this menu. Does not include submenus.
  Iterable<String> get keys => _items.keys;

  /// The handle of the current submenu. If this is the root menu, it's null.
  int? get _submenuHandle => null;

  /// Creates a menu item at the platform level using the given item representation.
  /// Returns an implementation-defined handle for the newly created item.
  Future<int> _addItem(String key, _MenuItem item, String? before) {
    return _items.containsKey(key)
        ? throw ArgumentError("Key '$key' already in use")
        : TrayMenuPlatform.instance.add(
            item,
            before: _items[before]?._handle,
            submenu: _submenuHandle,
          );
  }

  /// Adds a menu item with the given [key] that displays the [label] text.
  /// [callback] will be called with [key] and this newly created [MenuItem] when it is [enabled] and it is clicked.
  /// If [before] is not null and refers to a key of another item within current menu, this new item will be inserted before it.
  /// Otherwise, this new item is inserted at the end of the current menu.
  Future<MenuItemLabel> addLabel(
    String key, {
    String? before,
    required String label,
    bool enabled = true,
    Function(String, MenuItem)? callback,
  }) async {
    final handle = await _addItem(key, _MenuItemLabel(label, enabled), before);
    final item = MenuItemLabel._(handle, label, enabled, callback);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  /// Adds a menu item with the given [key] that is just a horizontal line.
  /// If [before] is not null and refers to a key of another item within current menu, this new item will be inserted before it.
  /// Otherwise, this new item is inserted at the end of the current menu.
  Future<MenuItemSeparator> addSeparator(String key, {String? before}) async {
    final handle = await _addItem(key, _MenuItemSeparator(), before);
    final item = MenuItemSeparator._(handle);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  /// Adds a menu item with the given [key] that displays the [label] text and can be checked/unchecked on click.
  /// [callback] will be called with [key] and this newly created [MenuItem] when it is [enabled] and it is clicked.
  /// If [before] is not null and refers to a key of another item within current menu, this new item will be inserted before it.
  /// Otherwise, this new item is inserted at the end of the current menu.
  Future<MenuItemCheckbox> addCheckbox(
    String key, {
    String? before,
    required String label,
    bool enabled = true,
    bool checked = false,
    Function(String, MenuItem)? callback,
  }) async {
    final handle = await _addItem(
      key,
      _MenuItemCheckbox(label, enabled, checked),
      before,
    );
    final item = MenuItemCheckbox._(handle, label, enabled, checked, callback);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  /// Adds a menu item with the given [key] that holds a new menu which has its own items.
  /// If [before] is not null and refers to a key of another item within current menu, this new item will be inserted before it.
  /// Otherwise, this new item is inserted at the end of the current menu.
  Future<MenuItemSubmenu> addSubmenu(
    String key, {
    String? before,
    required String label,
    bool enabled = true,
  }) async {
    final handle = await _addItem(
      key,
      _MenuItemSubmenu(label, enabled),
      before,
    );
    var item = MenuItemSubmenu._(handle, label, enabled);
    _items[key] = item;
    _keysByHandle[handle] = key;
    return item;
  }

  /// Removes the item with the given [key].
  Future<void> remove(String key) async {
    final handle = _items.remove(key)?._handle;
    if (handle == null) return;
    _keysByHandle.remove(handle);
    await TrayMenuPlatform.instance.remove(handle);
  }

  /// Retrieves the [MenuItem] referred to by [key], downcasted to [T].
  /// If the [key] is not found or the [MenuItem] is not of type [T], null is returned.
  T? get<T extends MenuItem>(String key) {
    final item = _items[key];
    return item is T ? item : null;
  }

  /// Retrieves a [MenuItem] referred to by the implementation-given [handle], along with its related the user-given key.
  /// This function recursively searches submenus.
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

  static final root = TrayMenu._();

  Future<void> show(String iconPath) =>
      TrayMenuPlatform.instance.show(iconPath);

  static Future<void> _handleCallbacks(MethodCall methodCall) async {
    if (methodCall.method != 'itemCallback') return;

    final handle = methodCall.arguments as int;
    final itemWithKey = root._getByHandle(handle);
    if (itemWithKey == null) return;
    final (key, item) = itemWithKey;
    item.callback?.call(key, item);
  }
}
