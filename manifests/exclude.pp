define duplicity::exclude (
  $content,
  $backup_name = "",
  $confdir     = false,
  $ensure      = "present") {
  require 'duplicity::params'
  $bname_real = $backup_name ? {
    ""      => $name,
    default => $backup_name,
  }
  $cf_r = $confdir ? {
    false   => $duplicity::params::confdir,
    default => $confdir
  }

  file { "duplicity::${bname_real}::exclude":
    path    => "${cf_r}/${bname_real}/exclude",
    ensure  => "${ensure}",
    content => "${content}",
    mode    => 0600,
  }
}
