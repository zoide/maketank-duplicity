# Class: duplicity
#
# This module manages duplicity
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class duplicity ($ensure = "present", $confdir = $duplicity::params::confdir) 
inherits duplicity::params {
  $dir_ensure = $ensure ? {
    "present" => "directory",
    default   => "absent",
  }

  file { "${duplicity::confdir}":
    ensure  => $dir_ensure,
    recurse => true,
    force   => true,
    mode    => "0700",
    require => Package["duply"],
  }

  package { ["duply", "duplicity", "lftp"]: ensure => $ensure }

  file { "/usr/local/sbin/backup-runner.sh":
    ensure  => $ensure,
    content => template("duplicity/backup-runner.sh.erb"),
    mode    => "0700",
  }

  file { "/etc/logrotate.d/duplicity":
    ensure => $ensure,
    source => "puppet:///modules/duplicity/duplicity.logrotate",
  }

}