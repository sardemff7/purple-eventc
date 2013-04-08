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

namespace PurpleEventc.Callbacks
{
    public static void
    signed_on(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "signed-on", null);
    }

    public static void
    signed_off(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "signed-off", null);
    }

    public static void
    away(Purple.Plugin plugin, Purple.Buddy buddy, string? message)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "away", null, "message", message);
    }

    public static void
    back(Purple.Plugin plugin, Purple.Buddy buddy, string? message)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "back", null, "message", message);
    }

    public static void
    status(Purple.Plugin plugin, Purple.Buddy buddy, string? message)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "message", null, "message", message);
    }

    public static void
    idle(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "idle", null);
    }

    public static void
    idle_back(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "idle-back", null);
    }

    public static void
    im_message(Purple.Plugin plugin, PurpleEvents.MessageType type, Purple.Buddy? buddy, string sender, string message)
    {
        unowned string name = "im-msg";
        string msg = null;
        switch ( type )
        {
        case PurpleEvents.MessageType.NORMAL:
            name = "received";
            msg = Purple.markup_strip_html(message);
        break;
        case PurpleEvents.MessageType.HIGHLIGHT:
            name = "highlight";
            msg = Purple.markup_strip_html(message);
        break;
        case PurpleEvents.MessageType.ACTION:
            name = "action";
            msg = Purple.markup_strip_html(message).substring(4);
        break;
        }
        if ( buddy != null )
            Utils.send_buddy_event(plugin, buddy, "im", name, null,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
        else
            Utils.send_event(plugin, "im", name, null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
    }

    public static void
    chat_message(Purple.Plugin plugin, PurpleEvents.MessageType type, Purple.Conversation conv, Purple.Buddy? buddy, string sender, string message)
    {
        unowned string name = "chat-msg";
        string msg = null;
        switch ( type )
        {
        case PurpleEvents.MessageType.NORMAL:
            name = "received";
            msg = Purple.markup_strip_html(message);
        break;
        case PurpleEvents.MessageType.HIGHLIGHT:
            name = "highlight";
            msg = Purple.markup_strip_html(message);
        break;
        case PurpleEvents.MessageType.ACTION:
            name = "action";
            msg = Purple.markup_strip_html(message).substring(4);
        break;
        }

        if ( buddy != null )
            Utils.send_buddy_event(plugin, buddy, "chat", name, null,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
        else
            Utils.send_event(plugin, "chat", name, null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
    }

    public static void
    end_event(Purple.Plugin plugin, owned Eventd.Event event)
    {
        try
        {
            eventc.event_end(event);
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
    }
}
