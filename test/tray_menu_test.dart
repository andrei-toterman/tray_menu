// import 'package:flutter_test/flutter_test.dart';
// import 'package:tray_menu/tray_menu.dart';
// import 'package:tray_menu/tray_menu_platform_interface.dart';
// import 'package:tray_menu/tray_menu_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockTrayMenuPlatform
//     with MockPlatformInterfaceMixin
//     implements TrayMenuPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final TrayMenuPlatform initialPlatform = TrayMenuPlatform.instance;

//   test('$MethodChannelTrayMenu is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelTrayMenu>());
//   });

//   test('getPlatformVersion', () async {
//     TrayMenu trayMenuPlugin = TrayMenu();
//     MockTrayMenuPlatform fakePlatform = MockTrayMenuPlatform();
//     TrayMenuPlatform.instance = fakePlatform;

//     expect(await trayMenuPlugin.getPlatformVersion(), '42');
//   });
// }
