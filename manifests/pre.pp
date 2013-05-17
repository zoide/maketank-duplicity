define duplicity::pre (
  $content,
  $backup_name = $::fqdn,
  $confdir     = "${duplicity::params::confdir}",
  $ensure      = "present") {
  require 'duplicity::params'

  file { "${confdir}/${backup_name}/pre":
    ensure  => "${ensure}",
    content => "${content}",
    mode    => 0700,
  }
}
