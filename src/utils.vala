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
    namespace Utils
    {
        static void
        send(Eventd.Event? old_event, Purple.Buddy buddy, string type, ...)
        {
            if ( old_event != null )
                return;

            try
            {
                if ( ! eventc.is_connected() )
                    return;
            }
            catch ( Eventc.EventcError e )
            {
                GLib.warning(_("Error dispatching event: %s"), e.message);
                reconnect();
                return;
            }

            var event = new Eventd.Event(type);

            var l = va_list();
            while ( true )
            {
                string? key = l.arg();
                if ( key == null )
                    break;
                string? val = l.arg();
                if ( val != null )
                    event.add_data(key, val);
            }

            event.add_data("buddy-name", PurpleEvents.Utils.buddy_get_best_name(buddy));

            if ( ! Purple.prefs_get_bool("/plugins/core/eventc/restrictions/no-buddy-icon") )
            {
                var buddy_icon = buddy.get_icon();
                if ( buddy_icon != null )
                    event.add_data("buddy-icon", GLib.Base64.encode(PurpleCustom.buddy_icon_get_data(buddy_icon)));
            }

            unowned string protoname = PurpleEvents.Utils.buddy_get_protocol(buddy);

            event.add_data("protocol-name", protoname);

            if ( ( ! Purple.prefs_get_bool("/plugins/core/eventc/restrictions/no-protocol-icon") ) && ( protoname != null ) )
            {
                string filename = PurpleEvents.Utils.protocol_get_icon_uri(protoname, PurpleEvents.UtilsIconFormat.SVG).substring(7);

                if ( ( filename != null ) && ( GLib.FileUtils.test(filename, GLib.FileTest.IS_REGULAR) ) )
                {
                    var file = GLib.File.new_for_path(filename);
                    try
                    {
                        uint8[] protocol_icon_data;
                        file.load_contents(null, out protocol_icon_data, null);
                        event.add_data("protocol-icon", GLib.Base64.encode(protocol_icon_data));
                    }
                    catch ( GLib.Error e )
                    {
                        GLib.warning(_("Couldn’t load protocol icon file: %s"), e.message);
                    }
                }
            }

            eventc.event.begin(event, (obj, res) => {
                try
                {
                    eventc.event.end(res);
                }
                catch ( Eventc.EventcError e )
                {
                    GLib.warning(_("Error dispatching event: %s"), e.message);
                    try
                    {
                        /*
                         * The only error that could be throwed
                         * here is the one we’re processing
                         */
                        if ( ! eventc.is_connected() )
                            reconnect();
                    }
                    catch ( Eventc.EventcError e ) {}
                }
            });
        }
    }
}
