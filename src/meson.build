deps = [
    dependency('gtk4'), # gtk4-devel
    dependency('libsoup-3.0'), # libsoup3-devel
    dependency('json-glib-1.0')
    # dependency('shumate-1.0') # Maps
]

sources = files(
    'app.vala',
    'model.vala',
    'api-client.vala'
)

executable(
    output_name,   
    #resources,
    sources,
    dependencies: deps,
    win_subsystem: 'windows',
    install: true,
)
