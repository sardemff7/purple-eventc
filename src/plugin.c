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

gpointer purple_eventc_callbacks_signed_on(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy);
gpointer purple_eventc_callbacks_signed_off(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy);
gpointer purple_eventc_callbacks_away(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy, const gchar *message);
gpointer purple_eventc_callbacks_back(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy, const gchar *message);
gpointer purple_eventc_callbacks_status(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy, const gchar *message);
gpointer purple_eventc_callbacks_special(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy, PurpleEventsEventSpecialType type, ...);
gpointer purple_eventc_callbacks_idle(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy);
gpointer purple_eventc_callbacks_idle_back(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy);
gpointer purple_eventc_callbacks_im_message(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy, const gchar *message);
gpointer purple_eventc_callbacks_im_action(PurplePlugin *plugin, gpointer event, PurpleBuddy *buddy, const gchar *message);
gpointer purple_eventc_callbacks_chat_message(PurplePlugin *plugin, gpointer event, PurpleConversation *conv, PurpleBuddy *buddy, const gchar *message);
gpointer purple_eventc_callbacks_chat_action(PurplePlugin *plugin, gpointer event, PurpleConversation *conv, PurpleBuddy *buddy, const gchar *message);
void purple_eventc_callbacks_end_event(PurplePlugin *plugin, gpointer event);

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

    _purple_eventc_info.dependencies = g_list_prepend(_purple_eventc_info.dependencies, (gpointer) purple_events_get_plugin_id());

    PurpleEventsHandler *handler;

    handler = purple_events_handler_new(plugin);
    plugin->extra = handler;

    purple_events_handler_add_signed_on_callback(handler, purple_eventc_callbacks_signed_on);
    purple_events_handler_add_signed_off_callback(handler, purple_eventc_callbacks_signed_off);

    purple_events_handler_add_away_callback(handler, purple_eventc_callbacks_away);
    purple_events_handler_add_back_callback(handler, purple_eventc_callbacks_back);

    purple_events_handler_add_status_callback(handler, purple_eventc_callbacks_status);
    purple_events_handler_add_special_callback(handler, purple_eventc_callbacks_special);

    purple_events_handler_add_idle_callback(handler, purple_eventc_callbacks_idle);
    purple_events_handler_add_idle_back_callback(handler, purple_eventc_callbacks_idle_back);

    purple_events_handler_add_im_message_callback(handler, purple_eventc_callbacks_im_message);
    purple_events_handler_add_im_action_callback(handler, purple_eventc_callbacks_im_action);

    purple_events_handler_add_chat_message_callback(handler, purple_eventc_callbacks_chat_message);
    purple_events_handler_add_chat_action_callback(handler, purple_eventc_callbacks_chat_action);

    purple_events_handler_add_end_event_callback(handler, purple_eventc_callbacks_end_event);

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
    purple_events_handler_free(plugin->extra);
}

