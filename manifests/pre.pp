define duplicity::pre (
  $content,
  $priority    = '10',
  $backup_name = $::fqdn,
  $confdir     = false,
  $ensure      = "present") {
  require 'duplicity::params'
  $cf_r = $confdir ? {
    false   => $duplicity::params::confdir,
    default => $confdir
  }

  # create the appropriate link
  if !defined(File["${cf_r}/${backup_name}/pre"]) {
    file { "${cf_r}/${backup_name}/pre": ensure => 
      $duplicity::params::prepost_runner, }
  }

  file { "${cf_r}/${backup_name}/${duplicity::params::pred}/${priority}${name}.sh"
  :
    ensure  => $ensure,
    content => $content,
    mode    => 0700,
  }
}