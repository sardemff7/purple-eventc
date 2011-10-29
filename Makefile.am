ACLOCAL_AMFLAGS = -I m4

plugindir = $(libdir)/purple/plugins

plugin_LTLIBRARIES =

CLEANFILES =

AM_CFLAGS += \
	-I $(top_builddir)/include/ \
	-D LOCALEDIR=\"$(localedir)\" \
	--include config.h

AM_VALAFLAGS += \
	--vapidir $(top_srcdir)/vapi/ \
	--pkg config


plugin_LTLIBRARIES += \
	eventc.la

eventc_la_VALASOURCES = \
	src/ui.vala \
	src/utils.vala \
	src/eventc.vala

eventc_la_SOURCES = \
	$(eventc_la_VALASOURCES) \
	src/plugin.c

eventc_la_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	$(PURPLE_VALAFLAGS) \
	$(LIBEVENTC_VALAFLAGS) \
	$(GIO_VALAFLAGS) \
	$(GLIB_VALAFLAGS)

eventc_la_CFLAGS = \
	$(AM_CFLAGS) \
	$(PURPLE_CFLAGS) \
	$(LIBEVENTC_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GLIB_CFLAGS)

eventc_la_LDFLAGS = \
	$(AM_LDFLAGS) \
	-avoid-version -module \
	-export-symbols $(srcdir)/src/purple-eventc.sym

eventc_la_LIBADD = \
	$(PURPLE_LIBS) \
	$(LIBEVENTC_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS)

CLEANFILES += \
	$(eventc_la_VALASOURCES:.vala=.c)


install-exec-hook: la-files-removal

la-files-removal:
	cd $(DESTDIR)/$(plugindir) && \
		rm $(plugin_LTLIBRARIES)
