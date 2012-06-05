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
    signed_on(Purple.Plugin plugin, void *event, Purple.Buddy buddy)
    {
        Utils.send(event as Eventd.Event, buddy, "signed-on");
    }

    public static void
    signed_off(Purple.Plugin plugin, void *event, Purple.Buddy buddy)
    {
        Utils.send(event as Eventd.Event, buddy, "signed-off");
    }

    public static void
    away(Purple.Plugin plugin, void *event, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            Utils.send(event as Eventd.Event, buddy, "away-message", "message", message);
        else
            Utils.send(event as Eventd.Event, buddy, "away");
    }

    public static void
    back(Purple.Plugin plugin, void *event, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            Utils.send(event as Eventd.Event, buddy, "back-message", "message", message);
        else
            Utils.send(event as Eventd.Event, buddy, "back");
    }

    public static void
    status(Purple.Plugin plugin, void *event, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            Utils.send(event as Eventd.Event, buddy, "change-status-message", "message", message);
        else
            Utils.send(event as Eventd.Event, buddy, "remove-status-message");
    }

    public static void
    special(Purple.Plugin plugin, void *event, Purple.Buddy buddy, PurpleEvents.EventSpecialType type, ...)
    {
    }

    public static void
    idle(Purple.Plugin plugin, void *event, Purple.Buddy buddy)
    {
        Utils.send(event as Eventd.Event, buddy, "idle");
    }

    public static void
    idle_back(Purple.Plugin plugin, void *event, Purple.Buddy buddy)
    {
        Utils.send(event as Eventd.Event, buddy, "back-idle");
    }

    public static void
    im_message(Purple.Plugin plugin, void *event, Purple.Buddy buddy, string message)
    {
        Utils.send(event as Eventd.Event, buddy, "im-msg",
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message)
                  );
    }

    public static void
    im_action(Purple.Plugin plugin, void *event, Purple.Buddy buddy, string message)
    {
        Utils.send(event as Eventd.Event, buddy, "im-action",
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message).substring(4)
                  );
    }

    public static void
    chat_message(Purple.Plugin plugin, void *event, Purple.Conversation conv, Purple.Buddy buddy, string message)
    {
        Utils.send(event as Eventd.Event, buddy, "chat-msg",
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message)
                  );
    }

    public static void
    chat_action(Purple.Plugin plugin, void *event, Purple.Conversation conv, Purple.Buddy buddy, string message)
    {
        Utils.send(event as Eventd.Event, buddy, "chat-action",
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message).substring(4)
                  );
    }

    public static void
    end_event(Purple.Plugin plugin, void *_event)
    {
        unowned Eventd.Event event = (_event as Eventd.Event);
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
