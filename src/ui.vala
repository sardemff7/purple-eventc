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
                "/plugins/core/eventc/client/category",
                _("Category")
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
                _("Restrictions:")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/restrictions/no-buddy-icon",
                _("Do not transmit buddy icon")
                );
            frame->add(pref);

            pref = new Purple.PluginPref.with_name_and_label(
                "/plugins/core/eventc/restrictions/no-protocol-icon",
                _("Do not transmit protocol icon")
                );
            frame->add(pref);

            return (owned)frame;
        }
    }
}
