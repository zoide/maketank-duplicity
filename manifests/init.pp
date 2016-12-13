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
class duplicity (
  $ensure  = 'present',
  $confdir = false) inherits duplicity::params {
  $dir_ensure = $ensure ? {
    'present' => 'directory',
    default   => 'absent',
  }
  $cf_r = $confdir ? {
    false   => $duplicity::params::confdir,
    default => $confdir
  }

  file { "${cf_r}":
    ensure  => $dir_ensure,
    recurse => true,
    force   => true,
    mode    => '0700',
    require => Package['duply'],
  }

  file { $duplicity::params::prepost_runner:
    ensure => $ensure,
    source => 'puppet:///modules/duplicity/prepost_runner.sh',
    mode   => '0700',
    owner  => 'root',
    group  => 'root';
  }

  package { ['duply', 'duplicity', 'lftp', 'ncftp']: ensure => $ensure }

  # Trusting certificates
  common::line { 'lftp-trust-certs':
    file    => '/etc/lftp.conf',
    line    => 'set ssl:verify-certificate false',
    require => Package['lftp'],
  }

  file { '/usr/local/sbin/backup-runner.sh':
    ensure  => $ensure,
    content => template('duplicity/backup-runner.sh.erb'),
    mode    => '0700',
  }

  file { '/etc/logrotate.d/duplicity':
    ensure => $ensure,
    source => 'puppet:///modules/duplicity/duplicity.logrotate',
  }

}
