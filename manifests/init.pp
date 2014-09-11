# == Class: aptly
#
# aptly is a swiss army knife for Debian repository management
#
# === Parameters
#
# [*package_ensure*]
#   Ensure parameter to pass to the package resource.
#   Default: present
#
# [*config*]
#   Hash of configuration options for `/etc/aptly.conf`.
#   See http://www.aptly.info/#configuration
#   Default: {}
#
# [*repo*]
#   Whether to configure an apt::source for `repo.aptly.info`.
#   You might want to disable this if/when you've mirrored that yourself.
#   Default: true
#
# [*key_server*]
#   Key server to use when `$repo` is true. Uses the default of
#   `apt::source` if not specified.
#   Default: undef
#
# [*user*]
#   The user to use when performing an aptly command
#   Default: 'root'
#
class aptly (
  $package_ensure = present,
  $config_file    = '/etc/aptly.conf',
  $config         = {},
  $repo           = true,
  $key_server     = undef,
  $user           = 'root',
) {

  validate_hash($config)
  validate_bool($repo)
  validate_string($key_server)
  validate_string($user)

  if $repo {
    apt::source { 'aptly':
      location    => 'http://repo.aptly.info',
      release     => 'squeeze',
      repos       => 'main',
      key_server  => $key_server,
      key         => '2A194991',
      include_src => false,
    }

    Apt::Source['aptly'] -> Package['aptly']
  }

  package { 'aptly':
    ensure  => $package_ensure,
  }

  file { $config_file:
    ensure  => file,
    content => inline_template("<%= @config.to_pson %>\n"),
  }

  $aptly_cmd = "/usr/bin/aptly -config ${config_file}"
}
