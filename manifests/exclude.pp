define exclude (
  $content,
  $backup_name = "",
  $confdir     = "${duplicity::params::confdir}",
  $ensure      = "present") {
  require 'duplicity::params'
  $bname_real = $backup_name ? {
    ""      => $name,
    default => $backup_name,
  }

  file { "duplicity::${bname_real}::exclude":
    path    => "${confdir}/${bname_real}/exclude",
    ensure  => "${ensure}",
    content => "${content}",
    mode    => 0600,
  }
}
