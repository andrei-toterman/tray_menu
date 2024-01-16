import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tray_menu/tray_menu.dart';

void main() {
  runApp(const MaterialApp(home: MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> initTrayMenu() async {
    await TrayMenu.root.addLabel('aaa', label: 'aaa', callback: (key, _) {
      TrayMenu.root.get<MenuItemSubmenu>('ccc')?.remove('aaa');
    });
    await TrayMenu.root.addSeparator('sep');
    await TrayMenu.root
        .addLabel('bbb', label: 'bbb', callback: (key, _) => print(key));
    await TrayMenu.root
        .addSubmenu('ccc', label: 'submenu', before: 'sep')
        .then((menu) async {
      await menu.addLabel('aaa',
          label: 'aaa', callback: (key, _) => print(key));
      await menu.addLabel('ccc',
          label: 'ccc', callback: (key, _) => print(key));
      await menu.addLabel('bbb',
          label: 'bbb', before: 'ccc', callback: (key, _) => print(key));
    });
    await TrayMenu.root.show('/home/andrei/icon.ico');
    Timer(const Duration(seconds: 10), () {
      TrayMenu.root
          .addSubmenu('ddd', label: 'submenu 2', before: 'sep')
          .then((menu) async {
        await menu.addLabel('aaa',
            label: 'aaa', callback: (key, _) => print(key));
        await menu.addLabel('ccc',
            label: 'ccc', callback: (key, _) => print(key));
        await menu.addLabel('bbb',
            label: 'bbb', before: 'ccc', callback: (key, _) => print(key));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: initTrayMenu,
      ),
    );
  }
}
