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
    namespace Ui
    {
        public static Purple.PluginPrefFrame
        get_pref_frame(Purple.Plugin plugin)
        {
            Purple.PluginPref *pref = null;
            Purple.PluginPrefFrame *frame = new Purple.PluginPrefFrame();

            pref = new Purple.PluginPref.with_label(
                _("Server:")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/server/host",
                _("Host")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/server/port",
                _("Port")
                );
            frame->add(pref);
            pref->set_bounds(0, 65535);

            pref = new Purple.PluginPref.with_label(
                _("Client:")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/client/type",
                _("Client type")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/client/name",
                _("Client name")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_label(
                _("Connection:")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/connection/timeout",
                _("Timeout (seconds, 0 to disable)")
                );
            frame->add(pref);
            pref->set_bounds(0, 3600);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/connection/max-tries",
                _("Max reconnection tries (-1 to disable, 0 for infinite)")
                );
            frame->add(pref);
            pref->set_bounds(-1, 1000);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/connection/retry-delay",
                _("Retry delay (0-3600 seconds)")
                );
            frame->add(pref);
            pref->set_bounds(0, 3600);

            pref = new Purple.PluginPref.with_label(
                _("Events:")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/new-msg",
                _("New messages")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/signed-on",
                _("Buddy signing on")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/signed-off",
                _("Buddy signing off")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/away",
                _("Buddy going away")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/idle",
                _("Buddy going idle")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/back",
                _("Buddy coming back")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/events/status-message",
                _("Status message change (or removal)")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_label(
                _("Restrictions:")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/restrictions/blocked",
                _("Even for a blocked buddy")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/restrictions/new-conv-only",
                _("Only from new conversation")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/restrictions/only-available",
                _("Only when available")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/restrictions/no-icon",
                _("Do not transmit buddy icon")
                );
            frame->add(pref);

            return (owned)frame;
        }

        private static void
        deactivate_reset_children(Purple.BlistNode node)
        {
            unowned Purple.BlistNode contact = node.get_first_child();
            for ( ; contact != null ; contact = contact.get_sibling_next() )
            {
                if ( contact.is_buddy() )
                    contact = (Purple.BlistNode)((Purple.Buddy)contact).get_contact();
                contact.remove_setting("eventc/deactivate");
            }
        }

        static void
        deactivate_reset(Purple.BlistNode node)
        {
            if ( node.is_group() )
                deactivate_reset_children(node);
            else if ( node.is_buddy() )
                node = (Purple.BlistNode)((Purple.Buddy)node).get_contact();
            node.remove_setting("eventc/deactivate");
        }

        static void
        deactivate_set(Purple.BlistNode node)
        {
            if ( node.is_group() )
                deactivate_reset_children(node);
            else if ( node.is_buddy() )
                node = (Purple.BlistNode)((Purple.Buddy)node).get_contact();
            node.set_int("eventc/deactivate", 1);
        }

        static void
        deactivate_unset(Purple.BlistNode node)
        {
            if ( node.is_buddy() )
                node = (Purple.BlistNode)((Purple.Buddy)node).get_contact();

            node.set_int("eventc/deactivate", -1);
        }

        static void
        menu_add(Purple.BlistNode node, ref GLib.List<Purple.MenuAction> menu)
        {
            if ( node.is_buddy() )
                node = (Purple.BlistNode)((Purple.Buddy)node).get_contact();

            if ( ( ( node.get_flags() & Purple.BlistNodeFlags.SAVE ) > 0 ) || ( ( ! node.is_contact() ) && ( ! node.is_group() ) ) )
                return;

            var current = node.get_int("eventc/deactivate");

            Purple.MenuAction action = null;
            if ( current == 1 )
                action = new Purple.MenuAction(_("Dispatch to eventd"), (Purple.Callback)deactivate_reset, null, new GLib.List<Purple.MenuAction>());
            else if ( ( node.is_group() ) || ( current == -1 ) )
                action = new Purple.MenuAction(_("Do not dispatch to eventd"), (Purple.Callback)deactivate_set, null, new GLib.List<Purple.MenuAction>());
            else
            {
                unowned Purple.BlistNode group = (Purple.BlistNode)((Purple.Contact)node).get_priority_buddy().get_group();
                current = group.get_int("eventc/deactivate");

                if ( current == 1 )
                    action = new Purple.MenuAction(_("Dispatch to eventd"), (Purple.Callback)deactivate_unset, null, new GLib.List<Purple.MenuAction>());
                else
                    action = new Purple.MenuAction(_("Do not dispatch to eventd"), (Purple.Callback)deactivate_set, null, new GLib.List<Purple.MenuAction>());
            }
            menu.append((owned)action);
        }

    }
}
