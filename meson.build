project(
  'bullet',
  'vala',
  'c',
  version: run_command('cat', meson.project_source_root() / 'version').stdout().strip(),
  meson_version: '>= 0.62.0',
  default_options: [
    'warning_level=2',
    'werror=false',
    'c_std=gnu11',
  ],
)

version_split = meson.project_version().split('.')
major_version = version_split[0]
api_version = major_version + '.' + version_split[1]
gir = 'Bullet-' + api_version + '.gir'
typelib = 'Bullet-' + api_version + '.typelib'

config = configure_file(
  input: 'src/config.vala.in',
  output: 'config.vala',
  configuration: {
    'API_VERSION': api_version,
    'VERSION': meson.project_version(),
    'MAJOR_VERSION': major_version,
    'MINOR_VERSION': version_split[1],
    'MICRO_VERSION': version_split[2],
  },
)

sources = [config, 'src/hotkeys.vala', 'src/structs.vala']
deps = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('x11'),
]

lib = library(
  meson.project_name(),
  sources,
  dependencies: deps,
  vala_header: meson.project_name() + '.h',
  vala_vapi: meson.project_name() + '-' + api_version + '.vapi',
  vala_gir: gir,
  version: meson.project_version(),
  soversion: 0,
  install: true,
  install_dir: [
    get_option('libdir'),
    get_option('includedir') / meson.project_name(),
    get_option('datadir') / 'vala' / 'vapi',
    get_option('datadir') / 'gir-1.0',
  ],
)

import('pkgconfig').generate(
  lib,
  name: meson.project_name(),
  filebase: meson.project_name() + '-' + api_version,
  version: meson.project_version(),
  requires: deps,
  install_dir: get_option('libdir') / 'pkgconfig',
)

custom_target(
  typelib,
  command: [
    find_program('g-ir-compiler'),
    '--output', '@OUTPUT@',
    '--shared-library', get_option('prefix') / get_option('libdir') / '@PLAINNAME@',
    meson.current_build_dir() / gir,
  ],
  input: lib,
  output: typelib,
  depends: lib,
  install: true,
  install_dir: get_option('libdir') / 'girepository-1.0',
)
