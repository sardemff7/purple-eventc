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
        return Utils.send(plugin, event, buddy, "signed-on", null);
    }

    public static Eventd.Event?
    signed_off(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send(plugin, event, buddy, "signed-off", null);
    }

    public static Eventd.Event?
    away(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            return Utils.send(plugin, event, buddy, "away-message", null, "message", message);
        else
            return Utils.send(plugin, event, buddy, "away", null);
    }

    public static Eventd.Event?
    back(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            return Utils.send(plugin, event, buddy, "back-message", null, "message", message);
        else
            return Utils.send(plugin, event, buddy, "back", null);
    }

    public static Eventd.Event?
    status(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            return Utils.send(plugin, event, buddy, "change-status-message", null, "message", message);
        else
            return Utils.send(plugin, event, buddy, "remove-status-message", null);
    }

    public static Eventd.Event?
    special(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, PurpleEvents.EventSpecialType type, ...)
    {
        return null;
    }

    public static Eventd.Event?
    idle(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send(plugin, event, buddy, "idle", null);
    }

    public static Eventd.Event?
    idle_back(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy)
    {
        return Utils.send(plugin, event, buddy, "back-idle", null);
    }

    public static Eventd.Event?
    im_message(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string message)
    {
        return Utils.send(plugin, event, buddy, "im-msg", null,
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message)
                  );
    }

    public static Eventd.Event
    im_action(Purple.Plugin plugin, Eventd.Event? event, Purple.Buddy buddy, string message)
    {
        return Utils.send(plugin, event, buddy, "im-action", null,
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message).substring(4)
                  );
    }

    public static Eventd.Event
    chat_message(Purple.Plugin plugin, Eventd.Event? event, Purple.Conversation conv, Purple.Buddy buddy, string message)
    {
        return Utils.send(plugin, event, buddy, "chat-msg", conv,
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message)
                  );
    }

    public static Eventd.Event
    chat_action(Purple.Plugin plugin, Eventd.Event? event, Purple.Conversation conv, Purple.Buddy buddy, string message)
    {
        return Utils.send(plugin, event, buddy, "chat-action", conv,
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message).substring(4)
                  );
    }

    public static void
    end_event(Purple.Plugin plugin, owned Eventd.Event event)
    {
        eventc.event_end(event, (obj, res) => {
            try
            {
                eventc.event_end.end(res);
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
