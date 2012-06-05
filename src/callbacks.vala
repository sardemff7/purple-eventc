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
        Utils.send(buddy, "signed-on");
    }

    public static void
    signed_off(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send(buddy, "signed-off");
    }

    public static void
    away(Purple.Plugin plugin, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            Utils.send(buddy, "away-message", "message", message);
        else
            Utils.send(buddy, "away");
    }

    public static void
    back(Purple.Plugin plugin, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            Utils.send(buddy, "back-message", "message", message);
        else
            Utils.send(buddy, "back");
    }

    public static void
    status(Purple.Plugin plugin, Purple.Buddy buddy, string? message)
    {
        if ( message != null )
            Utils.send(buddy, "change-status-message", "message", message);
        else
            Utils.send(buddy, "remove-status-message");
    }

    public static void
    special(Purple.Plugin plugin, Purple.Buddy buddy, PurpleEvents.EventSpecialType type, ...)
    {
    }

    public static void
    idle(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send(buddy, "idle");
    }

    public static void
    idle_back(Purple.Plugin plugin, Purple.Buddy buddy)
    {
        Utils.send(buddy, "back-idle");
    }

    public static void
    message(Purple.Plugin plugin, Purple.Buddy buddy, string message)
    {
        Utils.send(buddy, "im-msg",
                   "unstripped-message", message.dup(),
                   "message", Purple.markup_strip_html(message)
                  );
    }

    public static void
    action(Purple.Plugin plugin, Purple.Buddy buddy, string message)
    {
        string msg = Purple.markup_strip_html(message);
        Utils.send(buddy, "im-action",
                   "unstripped-message", message.dup(),
                   "message", msg.substring(4)
                  );
    }
}
