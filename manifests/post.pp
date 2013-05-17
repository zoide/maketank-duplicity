define post (
  $content,
  $backup_name = $::fqdn,
  $confdir     = $duplicity::params::confdir,
  $ensure      = 'present') {
  require 'duplicity::params'

  file { "${confdir}/${backup_name}/post":
    ensure  => $ensure,
    content => $content,
    mode    => '0700',
  }
}
