//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <tray_menu/tray_menu_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) tray_menu_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TrayMenuPlugin");
  tray_menu_plugin_register_with_registrar(tray_menu_registrar);
}
