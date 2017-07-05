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

#include <glib.h>
#include <glib/gi18n-lib.h>
#include <purple.h>

#include <purple-events.h>

extern PurplePlugin* purple_eventc_plugin;

static void _purple_eventc_init(PurplePlugin *plugin);
gboolean purple_eventc_load(PurplePlugin *plugin);
gboolean purple_eventc_unload(PurplePlugin *plugin);
PurplePluginPrefFrame *purple_eventc_ui_get_pref_frame(PurplePlugin *plugin);

static PurplePluginUiInfo _purple_eventc_ui_info = {
    .get_plugin_pref_frame = purple_eventc_ui_get_pref_frame
};

static PurplePluginInfo _purple_eventc_info = {
    .magic          = PURPLE_PLUGIN_MAGIC,
    .major_version  = PURPLE_MAJOR_VERSION,
    .minor_version  = PURPLE_MINOR_VERSION,
    .type           = PURPLE_PLUGIN_STANDARD,
    .ui_requirement = 0,
    .flags          = 0,
    .dependencies   = NULL,
    .priority       = PURPLE_PRIORITY_DEFAULT,

    .id             = "core-sardemff7-" PACKAGE_NAME,
    .name           = NULL,
    .version        = PACKAGE_VERSION,
    .summary        = NULL,
    .description    = NULL,
    .author         = "Quentin \"Sardem FF7\" Glidic <sardemff7+pidgin@sardemff7.net>",
    .homepage       = "https://clients.eventd.org/purple/",

    .load           = purple_eventc_load,
    .unload         = purple_eventc_unload,
    .destroy        = NULL,

    .ui_info        = NULL,
    .extra_info     = NULL,
    .prefs_info     = &_purple_eventc_ui_info,
    .actions        = NULL
};

PURPLE_INIT_PLUGIN(eventc, _purple_eventc_init, _purple_eventc_info)

static void
_purple_eventc_init(PurplePlugin *plugin)
{
#if ENABLE_NLS
    bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
#endif /* ENABLE_NLS */

    _purple_eventc_info.name = _("Client for eventd");
    _purple_eventc_info.summary = _("Propagate events to eventd");
    _purple_eventc_info.description = _("Use eventd to inform the user of events");

    _purple_eventc_info.dependencies = g_list_prepend(_purple_eventc_info.dependencies, (gpointer) purple_events_get_plugin_id());

    purple_prefs_add_none("/plugins/core/eventc");

    purple_prefs_add_none("/plugins/core/eventc/connection");
    purple_prefs_add_string("/plugins/core/eventc/connection/uri", "");
    purple_prefs_add_int("/plugins/core/eventc/connection/max-tries", 3);
    purple_prefs_add_int("/plugins/core/eventc/connection/retry-delay", 10);

    purple_prefs_add_none("/plugins/core/eventc/restrictions");
    purple_prefs_add_bool("/plugins/core/eventc/restrictions/no-buddy-icon", FALSE);
    purple_prefs_add_bool("/plugins/core/eventc/restrictions/no-protocol-icon", FALSE);
}
