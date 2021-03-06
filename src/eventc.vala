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

namespace PurpleEventc
{
    static Eventc.Connection eventc;

    static uint retry_source;
    static int tries;

    static uint server_info_changed_id;
    static uint server_info_changed_timeout = 0U;

    static bool
    server_info_changed_apply(void *user_data)
    {
        server_info_changed_timeout = 0U;
        var uri = Purple.prefs_get_string("/plugins/core/eventc/connection/uri");
        try
        {
            if ( eventc == null )
                eventc = new Eventc.Connection(uri);
            else
                eventc.set_uri(uri);
            connect();
        }
        catch ( GLib.Error e )
        {

        }
        return false;
    }

    static void
    server_info_changed(string name, Purple.PrefType type, void *val, void *user_data)
    {
        if ( server_info_changed_timeout > 0U )
            Purple.timeout_remove(server_info_changed_timeout);
        server_info_changed_timeout = PurpleCustom.timeout_add_seconds(5, (PurpleCustom.SourceFunc)server_info_changed_apply, null);
    }

    static new bool
    connect()
    {
        retry_source = 0;
        if ( eventc == null )
            return false;

        eventc.connect.begin((obj, res) => {
            if ( eventc == null ) return;
            try
            {
                eventc.connect.end(res);
            }
            catch ( GLib.Error e )
            {
                GLib.warning(_("Error connecting to eventd: %s"), e.message);
                var max_tries = Purple.prefs_get_int("/plugins/core/eventc/connection/max-tries");
                if ( ( max_tries == 0 ) || ( ++tries < max_tries ) )
                {
                    reconnect();
                    return;
                }
            }
            tries = 0;
        });

        return false;
    }

    static void
    reconnect()
    {
        retry_source = PurpleCustom.timeout_add_seconds(Purple.prefs_get_int("/plugins/core/eventc/connection/retry-delay"), connect, null);
    }

    public static bool
    load(Purple.Plugin plugin)
    {
        tries = 0;
        var uri = Purple.prefs_get_string("/plugins/core/eventc/connection/uri");

        try
        {
            eventc = new Eventc.Connection(uri);
            connect();
        }
        catch ( GLib.Error e )
        {

        }

        server_info_changed_id = PurpleCustom.prefs_connect_callback(plugin,
            "/plugins/core/eventc/connection/uri",
            (PurpleCustom.PrefCallback)server_info_changed, null
            );


        unowned Purple.Plugin handle = Purple.plugins_find_with_id(PurpleEvents.get_plugin_id());

        Purple.signal_connect(
            handle, "user_presence-online", plugin,
            (Purple.Callback) Callbacks.signed_on, plugin
        );
        Purple.signal_connect(
            handle, "user_presence-offline", plugin,
            (Purple.Callback) Callbacks.signed_off, plugin
        );
        Purple.signal_connect(
            handle, "user_presence-away", plugin,
            (Purple.Callback) Callbacks.away, plugin
        );
        Purple.signal_connect(
            handle, "user_presence-back", plugin,
            (Purple.Callback) Callbacks.back, plugin
        );
        Purple.signal_connect(
            handle, "user_presence-idle", plugin,
            (Purple.Callback) Callbacks.idle, plugin
        );
        Purple.signal_connect(
            handle, "user_presence-idle-back", plugin,
            (Purple.Callback) Callbacks.idle_back, plugin
        );
        Purple.signal_connect(
            handle, "user_presence-message", plugin,
            (Purple.Callback) Callbacks.status, plugin
        );

        Purple.signal_connect(
            handle, "user_im-received", plugin,
            (Purple.Callback) Callbacks.im_message, plugin
        );
        Purple.signal_connect(
            handle, "user_im-highlight", plugin,
            (Purple.Callback) Callbacks.im_highlight, plugin
        );
        Purple.signal_connect(
            handle, "user_chat-received", plugin,
            (Purple.Callback) Callbacks.chat_message, plugin
        );
        Purple.signal_connect(
            handle, "user_chat-highlight", plugin,
            (Purple.Callback) Callbacks.chat_highlight, plugin
        );

        return true;
    }

    public static bool
    unload(Purple.Plugin plugin)
    {
        unowned Purple.Plugin handle = Purple.plugins_find_with_id(PurpleEvents.get_plugin_id());

        Purple.signal_disconnect(
            handle, "user_presence-online", plugin,
            (Purple.Callback) Callbacks.signed_on
        );
        Purple.signal_disconnect(
            handle, "user_presence-offline", plugin,
            (Purple.Callback) Callbacks.signed_off
        );
        Purple.signal_disconnect(
            handle, "user_presence-away", plugin,
            (Purple.Callback) Callbacks.away
        );
        Purple.signal_disconnect(
            handle, "user_presence-back", plugin,
            (Purple.Callback) Callbacks.back
        );
        Purple.signal_disconnect(
            handle, "user_presence-idle", plugin,
            (Purple.Callback) Callbacks.idle
        );
        Purple.signal_disconnect(
            handle, "user_presence-idle-back", plugin,
            (Purple.Callback) Callbacks.idle_back
        );
        Purple.signal_disconnect(
            handle, "user_presence-message", plugin,
            (Purple.Callback) Callbacks.status
        );

        Purple.signal_disconnect(
            handle, "user_im-received", plugin,
            (Purple.Callback) Callbacks.im_message
        );
        Purple.signal_disconnect(
            handle, "user_im-highlight", plugin,
            (Purple.Callback) Callbacks.im_highlight
        );
        Purple.signal_disconnect(
            handle, "user_chat-received", plugin,
            (Purple.Callback) Callbacks.chat_message
        );
        Purple.signal_disconnect(
            handle, "user_chat-highlight", plugin,
            (Purple.Callback) Callbacks.chat_highlight
        );

        Purple.prefs_disconnect_callback(server_info_changed_id);

        if ( retry_source > 0 )
        {
            GLib.Source.remove(retry_source);
            retry_source = 0;
        }

        try
        {
            eventc.close();
        }
        catch ( GLib.Error e )
        {
            GLib.warning(_("Error closing connection to eventd: %s"), e.message);
        }

        eventc = null;

        return true;
    }
}
