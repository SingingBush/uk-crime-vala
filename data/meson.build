
# Install our .desktop file so the Applications Menu will see it
install_data(
    'ukcrime.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications'),
    rename: id + '.desktop'
)

# Install our .appdata.xml file so AppCenter will see it
install_data(
    'ukcrime.appdata.xml',
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
    rename: id + '.appdata.xml'
)

# The GSchema XML needs installing for GLib settings to work
install_data(
    id + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)