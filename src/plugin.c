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
#include <glib/gi18n.h>
#include <purple.h>

#include <purple-events.h>

extern PurplePlugin* purple_eventc_plugin;

static void _purple_eventc_init(PurplePlugin *plugin);
static void _purple_eventc_destroy(PurplePlugin *plugin);
gboolean purple_eventc_load(PurplePlugin *plugin);
gboolean purple_eventc_unload(PurplePlugin *plugin);
PurplePluginPrefFrame *purple_eventc_ui_get_pref_frame(PurplePlugin *plugin);

void purple_eventc_callbacks_signed_on(PurplePlugin *plugin, PurpleBuddy *buddy);
void purple_eventc_callbacks_signed_off(PurplePlugin *plugin, PurpleBuddy *buddy);
void purple_eventc_callbacks_away(PurplePlugin *plugin, PurpleBuddy *buddy, const gchar *message);
void purple_eventc_callbacks_back(PurplePlugin *plugin, PurpleBuddy *buddy, const gchar *message);
void purple_eventc_callbacks_status(PurplePlugin *plugin, PurpleBuddy *buddy, const gchar *message);
void purple_eventc_callbacks_special(PurplePlugin *plugin, PurpleBuddy *buddy, PurpleEventsEventSpecialType type, ...);
void purple_eventc_callbacks_idle(PurplePlugin *plugin, PurpleBuddy *buddy);
void purple_eventc_callbacks_idle_back(PurplePlugin *plugin, PurpleBuddy *buddy);
void purple_eventc_callbacks_message(PurplePlugin *plugin, PurpleBuddy *buddy, const gchar *message);
void purple_eventc_callbacks_action(PurplePlugin *plugin, PurpleBuddy *buddy, const gchar *message);

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

    .id             = PACKAGE_NAME,
    .name           = NULL,
    .version        = PACKAGE_VERSION,
    .summary        = NULL,
    .description    = NULL,
    .author         = "Quentin \"Sardem FF7\" Glidic <sardemff7+pidgin@sardemff7.net>",
    .homepage       = "http://sardemff7.github.com/purple-eventc/",

    .load           = purple_eventc_load,
    .unload         = purple_eventc_unload,
    .destroy        = _purple_eventc_destroy,

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

    _purple_eventc_info.dependencies = g_list_prepend(_purple_eventc_info.dependencies, "purple-events");

    PurpleEventsHandler *handler;

    handler = g_new(PurpleEventsHandler, 1);
    plugin->extra = handler;

    handler->plugin = plugin;

    handler->signed_on = purple_eventc_callbacks_signed_on;
    handler->signed_off = purple_eventc_callbacks_signed_off;

    handler->away = purple_eventc_callbacks_away;
    handler->back = purple_eventc_callbacks_back;

    handler->status = purple_eventc_callbacks_status;
    handler->special = purple_eventc_callbacks_special;

    handler->idle = purple_eventc_callbacks_idle;
    handler->idle_back = purple_eventc_callbacks_idle_back;

    handler->im_message = purple_eventc_callbacks_message;
    handler->im_action = purple_eventc_callbacks_action;

    handler->chat_message = purple_eventc_callbacks_message;
    handler->chat_action = purple_eventc_callbacks_action;

    purple_prefs_add_none("/plugins/core/eventc");

    purple_prefs_add_none("/plugins/core/eventc/server");
    purple_prefs_add_string("/plugins/core/eventc/server/host", "localhost");
    purple_prefs_add_int("/plugins/core/eventc/server/port", 0);

    purple_prefs_add_none("/plugins/core/eventc/client");
    purple_prefs_add_string("/plugins/core/eventc/client/category", "im");

    purple_prefs_add_none("/plugins/core/eventc/connection");
    purple_prefs_add_int("/plugins/core/eventc/connection/timeout", 3);
    purple_prefs_add_int("/plugins/core/eventc/connection/max-tries", 3);
    purple_prefs_add_int("/plugins/core/eventc/connection/retry-delay", 10);

    purple_prefs_add_none("/plugins/core/eventc/restrictions");
    purple_prefs_add_bool("/plugins/core/eventc/restrictions/if-no-event", TRUE);
    purple_prefs_add_bool("/plugins/core/eventc/restrictions/no-buddy-icon", FALSE);
    purple_prefs_add_bool("/plugins/core/eventc/restrictions/no-protocol-icon", FALSE);
}

static void
_purple_eventc_destroy(PurplePlugin *plugin)
{
    g_free(plugin->extra);
}

