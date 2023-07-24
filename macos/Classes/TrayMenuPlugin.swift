import Cocoa
import FlutterMacOS

extension NSMenu {
  func findItem(_ tag: Int) -> NSMenuItem? {
    for item in items {
      if item.tag == tag {
        return item
      }
      if let submenu = item.submenu, let foundItem = submenu.findItem(tag) {
        return foundItem
      }
    }
    return nil
  }
}

public class TrayMenuPlugin: NSObject, FlutterPlugin {
  var nextTag = 0
  var statusItem: NSStatusItem?
  let menu = NSMenu()
  let channel: FlutterMethodChannel

  var handlers: [String: (Any?, FlutterResult) -> Void] = [:]
  var constructors: [String: ([String: Any]) -> NSMenuItem] = [:]

  init(_ channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
    menu.autoenablesItems = false
    handlers = [
      "showTrayIcon": self.showTrayIcon,
      "addMenuItem": self.addMenuItem,
      "removeMenuItem": self.removeMenuItem,
      "getMenuItemLabel": self.getMenuItemLabel,
      "setMenuItemLabel": self.setMenuItemLabel,
      "getMenuItemEnabled": self.getMenuItemEnabled,
      "setMenuItemEnabled": self.setMenuItemEnabled,
      "getMenuItemChecked": self.getMenuItemChecked,
      "setMenuItemChecked": self.setMenuItemChecked,
    ]
    constructors = [
      "_MenuItemLabel": self.createLabelMenuItem,
      "_MenuItemSeparator": self.createSeparatorMenuItem,
      "_MenuItemCheckbox": self.createCheckboxMenuItem,
      "_MenuItemSubmenu": self.createSubmenuMenuItem,
    ]
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tray_menu", binaryMessenger: registrar.messenger)
    let instance = TrayMenuPlugin(channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let handler = handlers[call.method] {
      handler(call.arguments, result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  func showTrayIcon(args: Any?, result: FlutterResult) {
    if statusItem != nil {
      return result(nil)
    }
    let imagePath = args as! String
    let image = NSImage(contentsOfFile: imagePath)!
    image.size = NSSize(width: 18, height: 18)
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem?.button?.image = image
    statusItem?.menu = menu
    result(nil)
  }

  func addMenuItem(args: Any?, result: FlutterResult) {
    let map = args as! [String: Any]

    let type = map["type"] as! String
    let constructor = constructors[type]!
    var parentMenu = menu
    if let submenuTag = map["submenu"] as? Int {
      let item = menu.findItem(submenuTag)
      if let submenu = item?.submenu {
        parentMenu = submenu
      } else {
        return result(FlutterError(code: "Invalid handle", message: nil, details: nil))
      }
    }

    let item = constructor(map)
    item.tag = nextTag
    nextTag += 1
    if let beforeTag = map["before"] as? Int {
      let index = parentMenu.indexOfItem(withTag: beforeTag)
      parentMenu.insertItem(item, at: index)
    } else {
      parentMenu.addItem(item)
    }

    result(item.tag)
  }

  func removeMenuItem(args: Any?, result: FlutterResult) {
    let tag = args as! Int
    if let item = menu.findItem(tag) {
      item.menu?.removeItem(item)
      result(nil)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  func getMenuItemLabel(args: Any?, result: FlutterResult) {
    let tag = args as! Int
    if let item = menu.findItem(tag) {
      result(item.title)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  func setMenuItemLabel(args: Any?, result: FlutterResult) {
    let map = args as! [String: Any]
    let tag = map["handle"] as! Int
    let label = map["label"] as! String
    if let item = menu.findItem(tag) {
      item.title = label
      result(nil)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  func getMenuItemEnabled(args: Any?, result: FlutterResult) {
    let tag = args as! Int
    if let item = menu.findItem(tag) {
      result(item.isEnabled)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  func setMenuItemEnabled(args: Any?, result: FlutterResult) {
    let map = args as! [String: Any]
    let tag = map["handle"] as! Int
    let enabled = map["enabled"] as! Bool
    if let item = menu.findItem(tag) {
      item.isEnabled = enabled
      result(nil)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  func getMenuItemChecked(args: Any?, result: FlutterResult) {
    let tag = args as! Int
    if let item = menu.findItem(tag) {
      result(item.state == .on)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  func setMenuItemChecked(args: Any?, result: FlutterResult) {
    let map = args as! [String: Any]
    let tag = map["handle"] as! Int
    let checked = map["checked"] as! Bool
    if let item = menu.findItem(tag) {
      item.state = checked ? .on : .off
      result(nil)
    } else {
      result(FlutterError(code: "Invalid handle", message: nil, details: nil))
    }
  }

  @objc func checkboxItemCallback(item: NSMenuItem) {
    item.state = item.state == .on ? .off : .on
    labelItemCallback(item: item)
  }

  @objc func labelItemCallback(item: NSMenuItem) {
    channel.invokeMethod("itemCallback", arguments: item.tag)
  }

  func createLabelMenuItem(_ args: [String: Any]) -> NSMenuItem {
    let item = NSMenuItem()
    item.title = args["label"] as! String
    item.isEnabled = args["enabled"] as! Bool
    item.target = self
    item.action = #selector(labelItemCallback)
    return item
  }

  func createSeparatorMenuItem(_ args: [String: Any]) -> NSMenuItem {
    return NSMenuItem.separator()
  }

  func createCheckboxMenuItem(_ args: [String: Any]) -> NSMenuItem {
    let item = NSMenuItem()
    item.title = args["label"] as! String
    item.isEnabled = args["enabled"] as! Bool
    item.state = args["checked"] as! Bool ? .on : .off
    item.target = self
    item.action = #selector(checkboxItemCallback)
    return item
  }

  func createSubmenuMenuItem(_ args: [String: Any]) -> NSMenuItem {
    let item = NSMenuItem()
    item.title = args["label"] as! String
    item.isEnabled = args["enabled"] as! Bool
    item.submenu = NSMenu()
    return item
  }
}
