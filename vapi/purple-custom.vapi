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

namespace PurpleCustom
{
	[CCode (cheader_filename = "purple-events.h", cname = "purple_buddy_icon_get_data", array_length_type = "size_t")]
	public unowned uchar[] buddy_icon_get_data(Purple.BuddyIcon icon);

	[CCode (cheader_filename = "glib.h", has_target = false, cname = "GSourceFunc")]
	public delegate bool SourceFunc(void *data);
	[CCode (cheader_filename = "purple.h", cname = "purple_timeout_add")]
	public static uint timeout_add(uint interval, SourceFunc function, void *data);
	[CCode (cheader_filename = "purple.h", cname = "purple_timeout_add_seconds")]
	public static uint timeout_add_seconds(uint interval, SourceFunc function, void *data);

	[CCode (cheader_filename = "purple.h", has_target = false, cname = "PurplePrefCallback")]
	public delegate void PrefCallback (string name, Purple.PrefType type, void* val, void* data);
	[CCode (cheader_filename = "purple.h", cname = "purple_prefs_connect_callback")]
	public static uint prefs_connect_callback (void* handle, string name, PrefCallback cb, void* data);
}
