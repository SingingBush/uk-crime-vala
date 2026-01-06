project(
    'UK Crime (Vala & GTK4)',
    ['c', 'vala'],
    version: '0.1',
    license : 'GPL3',
    meson_version: '>= 1.0',
    default_options: ['c_std=c99', 'build.c_std=c99']
)

# gnome = import('gnome')

id = 'com.singingbush.ukcrime'
output_name = 'ukcrime-gtk4'
version = meson.project_version()

#glib = dependency('glib-2.0', version: '>=2.40')
#gobject = dependency('gobject-2.0', version: '>=2.40')

subdir('src')
subdir('tests')

# Include the translations module
#i18n = import('i18n')

# gnome.post_install(
#   glib_compile_schemas: true,
#   gtk_update_icon_cache: true,
#   update_desktop_database: true,
# )
