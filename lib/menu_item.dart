part of 'tray_menu.dart';

abstract class Spec<T extends MenuItem> {
  Map<String, dynamic> toMap() => {'type': '$T'};
}

class MenuItemSeparatorSpec extends Spec<MenuItemSeparator> {}

class MenuItemLabelSpec extends Spec<MenuItemLabel> {
  final String label;
  final bool enabled;

  MenuItemLabelSpec(this.label, this.enabled);

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'label': label,
        'enabled': enabled,
      };
}

class MenuItemCheckboxSpec extends MenuItemLabelSpec {
  final bool checked;

  MenuItemCheckboxSpec(super.label, super.enabled, this.checked);

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'label': label,
        'enabled': enabled,
        'checked': checked,
      };
}

class MenuItemSubmenuSpec extends MenuItemLabelSpec {
  MenuItemSubmenuSpec(super.label, super.enabled);

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'label': label,
        'enabled': enabled,
      };
}

abstract class Factory<T extends MenuItem> extends Spec<T> {
  T create(int handle, [Function(String, MenuItem)? callback]);
}

class MenuItemSeparatorFactory extends MenuItemSeparatorSpec
    implements Factory<MenuItemSeparator> {
  @override
  MenuItemSeparator create(int handle, [Function(String, MenuItem)? callback]) {
    return MenuItemSeparator._(handle);
  }
}

class MenuItemLabelFactory extends MenuItemLabelSpec
    implements Factory<MenuItemLabel> {
  MenuItemLabelFactory(super.label, super.enabled);

  @override
  MenuItemLabel create(int handle, [Function(String, MenuItem)? callback]) {
    return MenuItemLabel._(handle, label, enabled, callback);
  }
}

class MenuItemCheckboxFactory extends MenuItemCheckboxSpec
    implements Factory<MenuItemCheckbox> {
  MenuItemCheckboxFactory(super.label, super.enabled, super.checked);

  @override
  MenuItemCheckbox create(int handle, [Function(String, MenuItem)? callback]) {
    return MenuItemCheckbox._(handle, label, enabled, checked, callback);
  }
}

class MenuItemSubmenuFactory extends MenuItemSubmenuSpec
    implements Factory<MenuItemSubmenu> {
  MenuItemSubmenuFactory(super.label, super.enabled);

  @override
  MenuItemSubmenu create(int handle, [Function(String, MenuItem)? callback]) {
    return MenuItemSubmenu._(handle, label, enabled);
  }
}

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
