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
    namespace Utils
    {
        static unowned string
        get_best_buddy_name(Purple.Buddy buddy)
        {
            unowned string name = null;

            if ( buddy.get_contact_alias() != null )
                name = buddy.get_contact_alias();
            else if ( buddy.get_alias() != null )
                name = buddy.get_alias();
            else if ( buddy.get_server_alias() != null )
                name = buddy.get_server_alias();
            else
                name = buddy.get_name();

            return name;
        }

        static bool
        is_buddy_dispatch(Purple.Buddy buddy)
        {
            #if DEBUG
            return true;
            #endif

            unowned Purple.Account account = buddy.get_account();

            if ( just_signed_on_accounts.find(account) != null )
                return false;

            if ( ( Purple.prefs_get_bool("/plugins/core/eventc/restrictions/only-available") )
            && ( ! account.get_active_status().is_available() ) )
                return false;

            unowned string name = buddy.get_name();

            if ( ( ! Purple.privacy_check(account, name) )
                && ( Purple.prefs_get_bool("/plugins/core/eventc/restrictions/blocked") ) )
                return false;

            unowned Purple.Conversation conv = Purple.find_conversation_with_account(Purple.ConversationType.IM, name, account);
            if ( ( conv != null )
                && (
                    ( conv.has_focus() )
                    || ( Purple.prefs_get_bool("/plugins/core/eventc/restrictions/new-conv-only") )
                ) )
                return false;

            unowned Purple.BlistNode contact = (Purple.BlistNode *)(&(buddy.get_contact().node));
            int deactivate = contact.get_int("eventc/deactivate");
            if ( deactivate == 0 )
            {
                unowned Purple.BlistNode group = (Purple.BlistNode *)(&(buddy.get_group().node));
                deactivate = group.get_int("eventc/deactivate");
            }
            return ( deactivate != 1 );
        }

        static void
        send(Purple.Buddy buddy, string type, GLib.HashTable<string, string>? e_data)
        {
            if ( ( ! eventc.is_connected() ) || ( ! is_buddy_dispatch(buddy) ) )
                return;
            unowned string name = get_best_buddy_name(buddy);

            var data = e_data;

            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/restrictions/no-icon") )
            {
                if ( data == null )
                    data = new GLib.HashTable<string, string>(string.hash, GLib.str_equal);

                var buddy_icon = buddy.get_icon();
                if ( buddy_icon != null )
                    data.insert("buddy-icon", GLib.Base64.encode(buddy_icon.get_data()));

                unowned Purple.PluginProtocolInfo info = Purple.find_prpl(buddy.account.get_protocol_id()).get_protocol_info();
                string protoname = null;
                if ( info.list_icon != null )
                    protoname = info.list_icon(buddy.account, null);

                string filename = null;
                if ( protoname != null )
                    filename = GLib.Path.build_filename(Config.PURPLE_DATADIR, "pixmaps", "pidgin", "protocols", "scalable", protoname + ".svg");

                if ( ( filename != null ) && ( GLib.FileUtils.test(filename, GLib.FileTest.IS_REGULAR) ) )
                {
                    var file = GLib.File.new_for_path(filename);
                    try
                    {
                        string protocol_icon_data;
                        file.load_contents(null, out protocol_icon_data, null);
                        data.insert("protocol-icon", GLib.Base64.encode(protocol_icon_data.data));
                    }
                    catch ( GLib.Error e )
                    {
                        GLib.warning(_("Couldn’t load protocol icon file: %s"), e.message);
                    }
                }
            }

            try
            {
                eventc.event(type, name, data);
            }
            catch ( Eventd.EventcError e )
            {
                GLib.warning(_("Error dispatching event: %s"), e.message);
                if ( ! eventc.is_connected() )
                    reconnect();
            }
        }
    }
}
