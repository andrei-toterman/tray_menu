#include "include/tray_menu/tray_menu_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tray_menu_plugin.h"

void TrayMenuPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  tray_menu::TrayMenuPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
