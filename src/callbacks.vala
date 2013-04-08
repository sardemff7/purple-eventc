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
    public static Eventd.Event?
    signed_on(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send_buddy_event(plugin, event, buddy, "presence", "signed-on", null);
    }

    public static Eventd.Event?
    signed_off(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send_buddy_event(plugin, event, buddy, "presence", "signed-off", null);
    }

    public static Eventd.Event?
    away(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string? message)
    {
        return Utils.send_buddy_event(plugin, buddy, "presence", "away", null, "message", message);
    }

    public static Eventd.Event?
    back(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string? message)
    {
        return Utils.send_buddy_event(plugin, buddy, "presence", "back", null, "message", message);
    }

    public static Eventd.Event?
    status(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string? message)
    {
        return Utils.send_buddy_event(plugin, buddy, "presence", "message", null, "message", message);
    }

    public static Eventd.Event?
    special(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, PurpleEvents.EventSpecialType type, ...)
    {
        return null;
    }

    public static Eventd.Event?
    idle(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send_buddy_event(plugin, event, buddy, "presence", "idle", null);
    }

    public static Eventd.Event?
    idle_back(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send_buddy_event(plugin, event, buddy, "presence", "idle-back", null);
    }

    public static Eventd.Event?
    im_message(Purple.Plugin plugin, Eventd.Event? event, PurpleEvents.MessageType type, Purple.Buddy? buddy, string sender, string message)
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
            return Utils.send_buddy_event(plugin, event, buddy, "im", name, null,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
        else
            return Utils.send_event(plugin, event, "im", name, null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
    }

    public static Eventd.Event
    chat_message(Purple.Plugin plugin, Eventd.Event? event, PurpleEvents.MessageType type, Purple.Conversation conv, Purple.Buddy? buddy, string sender, string message)
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
            return Utils.send_buddy_event(plugin, event, buddy, "chat", name, null,
                       "unstripped-message", message.dup(),
                       "message", msg
                      );
        else
            return Utils.send_event(plugin, event, "chat", name, null,
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
