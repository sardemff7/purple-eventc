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
    signed_on(Purple.Buddy buddy, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "signed-on", null);
    }

    public static void
    signed_off(Purple.Buddy buddy, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "signed-off", null);
    }

    public static void
    away(Purple.Buddy buddy, string? message, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "away", null, "message", message);
    }

    public static void
    back(Purple.Buddy buddy, string? message, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "back", null, "message", message);
    }

    public static void
    status(Purple.Buddy buddy, string? message, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "message", null, "message", message);
    }

    public static void
    idle(Purple.Buddy buddy, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "idle", null);
    }

    public static void
    idle_back(Purple.Buddy buddy, Purple.Plugin plugin)
    {
        Utils.send_buddy_event(plugin, buddy, "presence", "idle-back", null);
    }

    public static void
    im_message(Purple.Account account, string sender, string message, Purple.Conversation conv, Purple.MessageFlags flags, Purple.Plugin plugin)
    {
        unowned Purple.Buddy buddy = Purple.find_buddy(account, sender);
        if ( buddy != null )
            Utils.send_buddy_event(plugin, buddy, "im", "received", null,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
        else
            Utils.send_event(plugin, "im", "received", null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
    }

    public static void
    im_highlight(Purple.Account account, string sender, string message, Purple.Conversation conv, Purple.MessageFlags flags, Purple.Plugin plugin)
    {
        unowned Purple.Buddy buddy = Purple.find_buddy(account, sender);
        if ( buddy != null )
            Utils.send_buddy_event(plugin, buddy, "im", "highlight", null,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
        else
            Utils.send_event(plugin, "im", "highlight", null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
    }

    public static void
    chat_message(Purple.Account account, string sender, string message, Purple.Conversation conv, Purple.MessageFlags flags, Purple.Plugin plugin)
    {
        unowned Purple.Buddy buddy = Purple.find_buddy(account, sender);
        if ( buddy != null )
            Utils.send_buddy_event(plugin, buddy, "chat", "received", null,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
        else
            Utils.send_event(plugin, "chat", "received", null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
    }

    public static void
    chat_highlight(Purple.Account account, string sender, string message, Purple.Conversation conv, Purple.MessageFlags flags, Purple.Plugin plugin)
    {
        unowned Purple.Buddy buddy = Purple.find_buddy(account, sender);
        if ( buddy != null )
            Utils.send_buddy_event(plugin, buddy, "chat", "highlight", null,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
        else
            Utils.send_event(plugin, "chat", "highlight", null,
                       "buddy-name", sender,
                       "unstripped-message", message.dup(),
                       "message", Purple.markup_strip_html(message)
                      );
    }
}
