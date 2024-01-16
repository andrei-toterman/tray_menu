part of 'tray_menu.dart';

abstract class _MenuItem {
  Map<String, dynamic> toMap() => {'type': '$runtimeType'};
}

class _MenuItemSeparator extends _MenuItem {}

class _MenuItemLabel extends _MenuItem {
  final String label;
  final bool enabled;

  _MenuItemLabel(this.label, this.enabled);

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'label': label,
        'enabled': enabled,
      };
}

class _MenuItemCheckbox extends _MenuItemLabel {
  bool checked;

  _MenuItemCheckbox(super.label, super.enabled, this.checked);

  @override
  Map<String, dynamic> toMap() => {...super.toMap(), 'checked': checked};
}

class _MenuItemSubmenu extends _MenuItemLabel {
  _MenuItemSubmenu(super.label, super.enabled);
}

class MenuItem {
  final int _handle;
  Function(String, MenuItem)? callback;

  MenuItem._(this._handle, [this.callback]);
}

class MenuItemSeparator extends MenuItem {
  MenuItemSeparator._(super.handle) : super._();
}

class MenuItemLabel extends MenuItem {
  String _label;
  bool _enabled;

  String get label => _label;

  bool get enabled => _enabled;

  MenuItemLabel._(super.handle, this._label, this._enabled, [super.callback])
      : super._();

  Future<String> getLabel() async {
    _label = await TrayMenuPlatform.instance.getMenuItemLabel(_handle);
    return label;
  }

  Future<void> setLabel(String value) async {
    await TrayMenuPlatform.instance.setMenuItemLabel(_handle, value);
    _label = value;
  }

  Future<bool> getEnabled() async {
    _enabled = await TrayMenuPlatform.instance.getMenuItemEnabled(_handle);
    return enabled;
  }

  Future<void> setEnabled(bool value) async {
    await TrayMenuPlatform.instance.setMenuItemEnabled(_handle, value);
    _enabled = value;
  }
}

class MenuItemCheckbox extends MenuItemLabel {
  bool _checked;

  bool get checked => _checked;

  MenuItemCheckbox._(
    super.handle,
    super._label,
    super._enabled,
    this._checked,
    super.callback,
  ) : super._();

  Future<bool> getChecked() async {
    _checked = await TrayMenuPlatform.instance.getMenuItemChecked(_handle);
    return checked;
  }

  Future<void> setChecked(bool value) async {
    await TrayMenuPlatform.instance.setMenuItemChecked(_handle, value);
    _checked = value;
  }
}

class MenuItemSubmenu extends MenuItemLabel with Menu {
  MenuItemSubmenu._(super.hadle, super._label, super._enabled) : super._();

  @override
  int? get _submenuHandle => _handle;
}
