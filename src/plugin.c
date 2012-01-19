/*
 * purple-eventc - libpurple plugin client for eventd
 *
 * Copyright © 2011-2012 Quentin "Sardem FF7" Glidic
 *
 * This file is part of purple-eventc.
 *
 * purple-eventc is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * purple-eventc is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with purple-eventc. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <config.h>
#include <purple.h>

void purple_eventc_init(PurplePlugin *plugin, PurplePluginInfo *info);
gboolean purple_eventc_load(PurplePlugin *plugin);
gboolean purple_eventc_unload(PurplePlugin *plugin);
PurplePluginPrefFrame *purple_eventc_ui_get_pref_frame(PurplePlugin *plugin);


static PurplePluginUiInfo prefs_info = {
    .get_plugin_pref_frame = purple_eventc_ui_get_pref_frame
};

static PurplePluginInfo info = {
    .magic          = PURPLE_PLUGIN_MAGIC,
    .major_version  = PURPLE_MAJOR_VERSION,
    .minor_version  = PURPLE_MINOR_VERSION,
    .type           = PURPLE_PLUGIN_STANDARD,
    .ui_requirement = 0,
    .flags          = 0,
    .dependencies   = NULL,
    .priority       = PURPLE_PRIORITY_DEFAULT,

    .id             = PACKAGE_NAME,
    .name           = "Eventc",
    .version        = VERSION,
    .summary        = NULL,
    .description    = NULL,
    .author         = "Quentin \"Sardem FF7\" Glidic <sardemff7+pidgin@sardemff7.net>",
    .homepage       = "http://sardemff7.github.com/purple-eventc/",

    .load           = purple_eventc_load,
    .unload         = purple_eventc_unload,
    .destroy        = NULL,

    .ui_info        = NULL,
    .extra_info     = NULL,
    .prefs_info     = &prefs_info,
    .actions        = NULL
};

static void
init_plugin(PurplePlugin *plugin)
{
    purple_eventc_init(plugin, &info);
}

PURPLE_INIT_PLUGIN(eventc, init_plugin, info)
