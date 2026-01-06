unit_test_files = [
    'api-client'
]

foreach name : unit_test_files
    test(name, executable(name, name + 'Test.vala', core_sources, dependencies: deps))
endforeach