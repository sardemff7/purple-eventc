project('purple-eventc', 'c', 'vala',
    version: '0.1',
    meson_version: '>=0.58.0',
    license: [ 'GPL3+' ],
    default_options: [
        'c_std=gnu11',
        'warning_level=2',
    ],
)

glib_min_major='2'
glib_min_minor='28'
glib_min_version='.'.join([glib_min_major, glib_min_minor])
purple_min_version='2.6.0'
purple_events_min_version='0.99.1'
eventd_min_version='0.23.90'
package_developer='sardemff7'

glib = dependency('glib-2.0', version: '>= @0@'.format(glib_min_version))
gobject = dependency('gobject-2.0')
purple = dependency('purple', version: '>= @0@'.format(purple_min_version))
purple_events = dependency('purple-events', version: '>= @0@'.format(purple_events_min_version))
libeventd = dependency('libeventd', version: '>= @0@'.format(eventd_min_version))
libeventc = dependency('libeventc', version: '>= @0@'.format(eventd_min_version))

add_project_arguments(
    '-fvisibility=hidden',
    '-Wno-unused-parameter',
    '-fcommon',
    language: 'c'
)

header_conf = configuration_data()
header_conf.set_quoted('PACKAGE_NAME', meson.project_name())
header_conf.set_quoted('PACKAGE_VERSION', meson.project_version())
header_conf.set_quoted('MODULES_VERSION', meson.project_version())
header_conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
header_conf.set_quoted('PURPLE_EVENTS_PLUGIN_ID', 'core-@0@-@1@'.format(package_developer, meson.project_name()))
header_conf.set_quoted('PURPLE_DATADIR', purple.get_variable('datadir'))
header_conf.set('PURPLE_EVENTS_EXPORT', '__attribute__((visibility("default")))')

config_h = configure_file(output: 'config.h', configuration: header_conf)

plugindir = purple.get_variable('plugindir')

shared_module('eventc', config_h, files(
        'src/callbacks.vala',
        'src/eventc.vala',
        'src/ui.vala',
        'src/utils.vala',
        'vapi/config.vapi',
        'vapi/purple-custom.vapi',
        'src/plugin.c',
    ),
    c_args: [ '--include', 'config.h' ],
    name_prefix: '',
    dependencies: [ purple, purple_events, libeventd, libeventc, gobject, glib ],
    install: true,
    install_dir: plugindir,
)

subdir('po')
