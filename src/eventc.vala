/*
 * purple-eventc - libpurple plugin client for eventd
 *
 * Copyright © 2011 Quentin "Sardem FF7" Glidic
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
    static unowned Purple.Plugin plugin;
    static Eventc.Connection eventc;

    static GLib.List<weak Purple.Account> just_signed_on_accounts;

    static uint retry_source;
    static int tries;

    static uint server_info_changed_id;
    static uint server_info_changed_timeout = 0U;
    static uint client_info_changed_id;
    static uint client_info_changed_timeout = 0U;
    static uint timeout_changed_id;

    namespace Callback
    {
        static bool
        server_info_changed_apply(void *user_data)
        {
            server_info_changed_timeout = 0U;
            eventc.host = Purple.prefs_get_string("/plugins/core/eventc/server/host");
            eventc.port = (uint16)Purple.prefs_get_int("/plugins/core/eventc/server/port");
            connect();
            return false;
        }

        static void
        server_info_changed(string name, Purple.PrefType type, void *val, void *user_data)
        {
            if ( server_info_changed_timeout > 0U )
                Purple.timeout_remove(server_info_changed_timeout);
            server_info_changed_timeout = Purple.timeout_add_seconds(5, (Purple.SourceFunc)server_info_changed_apply, null);
        }

        static void
        client_info_changed_apply(void *user_data)
        {
            client_info_changed_timeout = 0U;
            eventc.category = Purple.prefs_get_string("/plugins/core/eventc/client/category");
            eventc.client_name = Purple.prefs_get_string("/plugins/core/eventc/client/name");
            eventc.rename.begin((obj, res) => {
                try
                {
                    eventc.rename.end(res);
                }
                catch ( Eventc.EventcError e )
                {
                    GLib.warning(_("Couldn’t change client info: %s"), e.message);
                    if ( ! eventc.is_connected() )
                        reconnect();
            }
            });
        }

        static void
        client_info_changed(string name, Purple.PrefType type, void *val, void *user_data)
        {
            if ( client_info_changed_timeout > 0U )
                Purple.timeout_remove(client_info_changed_timeout);
            client_info_changed_timeout = Purple.timeout_add_seconds(5, (Purple.SourceFunc)client_info_changed_apply, null);
        }

        static void
        timeout_changed(string name, Purple.PrefType type, void *val, void *user_data)
        {
            eventc.timeout = Purple.prefs_get_int("/plugins/core/eventc/connection/timeout");
        }

        static void
        signed_on(Purple.Buddy buddy, void *user_data)
        {
            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/signed-on") )
                return;
            Utils.send(buddy, "signed-on");
        }

        static void
        signed_off(Purple.Buddy buddy, void *user_data)
        {
            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/signed-off") )
                return;
            Utils.send(buddy, "signed-off");
        }

        static void
        status_changed(Purple.Buddy buddy, Purple.Status old_status, Purple.Status new_status, void *user_data)
        {
            bool old_avail = old_status.is_available();
            bool new_avail = new_status.is_available();
            unowned string msg = new_status.get_attr_string("message");
            unowned string action = null;
            if ( old_status.is_independent() )
            {
                if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/specials") )
                    return;

                action = old_status.get_id();
                /* TODO: make it work
                foreach ( unowned Purple.StatusAttr attr in old_status.get_type().get_attrs() )
                {
                    var name = attr.get_name();
                    unowned Purple.Value @value = attr.get_value();
                    switch ( @value.type )
                    {
                    case Purple.Type.STRING:
                        data.insert(name, @value.get_string());
                    break;
                    default:
                    break;
                    }
                }
                */
            }
            else if ( old_avail && ( ! new_avail ) )
            {
                if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/away") )
                    return;

                if ( msg != null )
                    action = "away-message";
                else
                    action = "away";
            }
            else if ( ( ! old_avail ) && new_avail )
            {
                if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/back") )
                    return;

                if ( msg != null )
                    action = "back-message";
                else
                    action = "back";
            }
            else if ( msg != old_status.get_attr_string("message") )
            {
                if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/status-message") )
                    return;

                if ( msg != null )
                    action = "change-status-message";
                else
                    action = "remove-status-message";
            }
            else
                return;
            Utils.send(buddy, action,
                       "message", msg
                      );
        }

        static void
        idle_changed(Purple.Buddy buddy, bool oldidle, bool newidle, void *user_data)
        {
            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/idle") )
                return;
            Utils.send(buddy, newidle ? "idle" : "back-idle");
        }

        static void
        new_im_msg(Purple.Account account, string sender, string message, int flags, void *user_data)
        {
            unowned Purple.Buddy buddy = Purple.find_buddy(account, sender);
            if ( buddy == null )
                return;
            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/new-msg") )
                return;

            Utils.send(buddy, "im-msg",
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
        }

        static void
        new_chat_msg(Purple.Account account, string sender, string message, Purple.Conversation conv, void *user_data)
        {
            unowned Purple.Buddy buddy = Purple.find_buddy(account, sender);
            if ( buddy == null )
                return;
            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/events/new-msg") )
                return;
            Utils.send(buddy, "chat-msg",
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
        }

        static bool
        account_signed_on_timeout(Purple.Account *account)
        {
            if ( ( account->get_connection() != null ) && ( ! account->is_connected() ) )
                return true;
            just_signed_on_accounts.remove(account);
            return false;
        }

        static void
        account_signed_on(Purple.Connection conn, void *data)
        {
            assert(conn != null);

            Purple.Account *account = conn.get_account();
            just_signed_on_accounts.prepend(account);
            Purple.timeout_add_seconds(5, (Purple.SourceFunc)account_signed_on_timeout, account);
        }
    }

    static new bool
    connect()
    {
        retry_source = 0;
        eventc.connect.begin((obj, res) => {
            if ( eventc == null ) return;
            try
            {
                eventc.connect.end(res);
            }
            catch ( Eventc.EventcError e )
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
        retry_source = Purple.timeout_add_seconds(Purple.prefs_get_int("/plugins/core/eventc/connection/retry-delay"), connect, null);
    }

    static void
    init(Purple.Plugin handle, Purple.PluginInfo info)
    {
        plugin = handle;
        GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");

        info.summary = _("Propagate events to eventd");
        info.description = _("Use eventd to inform the user of events");

        Purple.prefs_add_none("/plugins/core/eventc");

        Purple.prefs_add_none("/plugins/core/eventc/server");
        Purple.prefs_add_string("/plugins/core/eventc/server/host", "localhost");
        Purple.prefs_add_int("/plugins/core/eventc/server/port", 0);

        Purple.prefs_add_none("/plugins/core/eventc/client");
        Purple.prefs_add_string("/plugins/core/eventc/client/category", "im");
        Purple.prefs_add_string("/plugins/core/eventc/client/name", "libpurple");

        Purple.prefs_add_none("/plugins/core/eventc/connection");
        Purple.prefs_add_int("/plugins/core/eventc/connection/timeout", 3);
        Purple.prefs_add_int("/plugins/core/eventc/connection/max-tries", 3);
        Purple.prefs_add_int("/plugins/core/eventc/connection/retry-delay", 10);

        Purple.prefs_add_none("/plugins/core/eventc/events");
        Purple.prefs_add_bool("/plugins/core/eventc/events/new-msg", true);
        Purple.prefs_add_bool("/plugins/core/eventc/events/signed-on", true);
        Purple.prefs_add_bool("/plugins/core/eventc/events/signed-off", false);
        Purple.prefs_add_bool("/plugins/core/eventc/events/away", true);
        Purple.prefs_add_bool("/plugins/core/eventc/events/idle", true);
        Purple.prefs_add_bool("/plugins/core/eventc/events/back", true);
        Purple.prefs_add_bool("/plugins/core/eventc/events/status-message", false);
        Purple.prefs_add_bool("/plugins/core/eventc/events/specials", false);

        Purple.prefs_add_none("/plugins/core/eventc/restrictions");
        Purple.prefs_add_bool("/plugins/core/eventc/restrictions/blocked", true);
        Purple.prefs_add_bool("/plugins/core/eventc/restrictions/new-conv-only", false);
        Purple.prefs_add_bool("/plugins/core/eventc/restrictions/only-available", false);
        Purple.prefs_add_bool("/plugins/core/eventc/restrictions/no-buddy-icon", false);
        Purple.prefs_add_bool("/plugins/core/eventc/restrictions/no-protocol-icon", false);
    }

    static bool
    load(Purple.Plugin plugin)
    {
        var conv_handle = Purple.conversations_get_handle();
        var blist_handle = Purple.blist_get_handle();
        var conn_handle = Purple.connections_get_handle();

        tries = 0;

        eventc = new Eventc.Connection(
            Purple.prefs_get_string("/plugins/core/eventc/server/host"),
            (uint16)Purple.prefs_get_int("/plugins/core/eventc/server/port"),
            Purple.prefs_get_string("/plugins/core/eventc/client/category"),
            Purple.prefs_get_string("/plugins/core/eventc/client/name")
            );

        eventc.mode = Eventc.Connection.Mode.NORMAL;
        eventc.timeout = Purple.prefs_get_int("/plugins/core/eventc/connection/timeout");

        server_info_changed_id = Purple.prefs_connect_callback(plugin,
            "/plugins/core/eventc/server",
            (Purple.PrefCallback)Callback.server_info_changed, null
            );

        client_info_changed_id = Purple.prefs_connect_callback(plugin,
            "/plugins/core/eventc/client",
            (Purple.PrefCallback)Callback.client_info_changed, null
            );

        timeout_changed_id = Purple.prefs_connect_callback(plugin,
            "/plugins/core/eventc/connection/timeout",
            (Purple.PrefCallback)Callback.timeout_changed, null
            );

        connect();


        Purple.signal_connect(
            blist_handle, "buddy-signed-on", plugin,
            (Purple.Callback)Callback.signed_on, null
            );

        Purple.signal_connect(
            blist_handle, "buddy-signed-off", plugin,
            (Purple.Callback)Callback.signed_off, null
            );

        Purple.signal_connect(
            blist_handle, "buddy-status-changed", plugin,
            (Purple.Callback)Callback.status_changed, null
            );

        Purple.signal_connect(
            blist_handle, "buddy-idle-changed", plugin,
            (Purple.Callback)Callback.idle_changed, null
            );

        Purple.signal_connect(
            conv_handle, "received-im-msg", plugin,
            (Purple.Callback)Callback.new_im_msg, null
            );

        Purple.signal_connect(
            conv_handle, "received-chat-msg", plugin,
            (Purple.Callback)Callback.new_chat_msg, null
            );


        Purple.signal_connect(
            conn_handle, "signed-on", plugin,
            (Purple.Callback)Callback.account_signed_on, null
            );


        Purple.signal_connect(
            blist_handle, "blist-node-extended-menu", plugin,
            (Purple.Callback)Ui.menu_add, null
            );

        return true;
    }

    static bool
    unload(Purple.Plugin plugin)
    {
        var conv_handle = Purple.conversations_get_handle();
        var blist_handle = Purple.blist_get_handle();
        var conn_handle = Purple.connections_get_handle();

        Purple.prefs_disconnect_callback(server_info_changed_id);
        Purple.prefs_disconnect_callback(client_info_changed_id);
        Purple.prefs_disconnect_callback(timeout_changed_id);

        Purple.signal_disconnect(
            blist_handle, "buddy-signed-on", plugin,
            (Purple.Callback)Callback.signed_on
            );

        Purple.signal_disconnect(
            blist_handle, "buddy-signed-off", plugin,
            (Purple.Callback)Callback.signed_off
            );

        Purple.signal_disconnect(
            blist_handle, "buddy-status-changed", plugin,
            (Purple.Callback)Callback.status_changed
            );

        Purple.signal_disconnect(
            blist_handle, "buddy-idle-changed", plugin,
            (Purple.Callback)Callback.idle_changed
            );

        Purple.signal_disconnect(
            conv_handle, "received-im-msg", plugin,
            (Purple.Callback)Callback.new_im_msg
            );

        Purple.signal_disconnect(
            conv_handle, "received-chat-msg", plugin,
            (Purple.Callback)Callback.new_chat_msg
            );


        Purple.signal_disconnect(
            conn_handle, "signed-on", plugin,
            (Purple.Callback)Callback.account_signed_on
            );


        Purple.signal_disconnect(
            blist_handle, "blist-node-extended-menu", plugin,
            (Purple.Callback)Ui.menu_add
            );

        if ( retry_source > 0 )
        {
            GLib.Source.remove(retry_source);
            retry_source = 0;
        }

        eventc.close.begin((obj, res) => {
            try
            {
                eventc.close.end(res);
            }
            catch ( Eventc.EventcError e )
            {
                GLib.warning(_("Error closing connection to eventd: %s"), e.message);
            }

            eventc = null;
        });

        return true;
    }
}
