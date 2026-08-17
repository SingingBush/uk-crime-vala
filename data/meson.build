
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

# Install our icons in all the required sizes
icon_sizes = ['128']
foreach i : icon_sizes
    install_data(
        'icon_' + i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: id + '.svg'
    )
    # install_data(
    #     'icon_' + i + '.svg',
    #     install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
    #     rename: id + '.svg'
    # )
endforeach