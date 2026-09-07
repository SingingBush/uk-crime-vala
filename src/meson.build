deps = [
    dependency('gtk4'), # gtk4-devel
    dependency('gee-0.8'), # libgee-devel
    dependency('libsoup-3.0'), # libsoup3-devel
    dependency('json-glib-1.0'),
    dependency('shumate-1.0') # Maps
]

core_sources = files(
    'model.vala',
    'api-client.vala'
)
sources = core_sources + files(
    'main-window.vala',
    'app.vala'
)

# executable(
#     output_name,   
#     #resources,
#     sources,
#     dependencies: deps,
#     win_subsystem: 'windows',
#     install: true,
# )
