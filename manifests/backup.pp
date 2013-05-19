define duplicity::backup (
  $ensure              = "present",
  $backup_name         = $::fqdn,
  $source              = "/",
  $target              = "",
  $gpg_password        = "",
  $target_user         = "",
  $target_password     = "",
  $gpg_options         = "--compress-algo=bzip2",
  $max_full_backups    = "1",
  $max_full_backup_age = "2M",
  $max_age             = "1M",
  $temp_dir            = "/tmp",
  $volsize             = "50",
  $hour                = "*/10",
  $minute              = "10",
  $cron                = true,
  $ganglia             = true,
  $confdir             = false) {
  require 'duplicity::params'
  $cf_r = $confdir ? {
    false   => $duplicity::params::confdir,
    default => $confdir
  }

  if !defined(Class["duplicity"]) {
    class { "duplicity": ensure => $ensure }
  }
  $dir_ensure = $ensure ? {
    "present" => "directory",
    default   => "absent",
  }

  file {
    "${cf_r}/${backup_name}":
      require => File["${cf_r}"],
      ensure  => $dir_ensure,
      recurse => true,
      force   => true,
      mode    => "0700";

    "${cf_r}/${backup_name}/conf":
      content => template("duplicity/conf.erb"),
      ensure  => $ensure,
      require => File["${cf_r}/${backup_name}"];

    [
      "${cf_r}/${backup_name}/${duplicity::params::pred}",
      "${cf_r}/${backup_name}/${duplicity::params::postd}"]:
      ensure  => $dir_ensure,
      require => File["${cf_r}/${backup_name}"],
  }

  cron { "duply-run-${backup_name}":
    command => "/usr/local/bin/randomsleep.sh 3600 && /usr/local/sbin/backup-runner.sh ${backup_name} pre_incr_post",
    user    => root,
    hour    => "${hour}",
    minute  => "${minute}",
    ensure  => $cron ? {
      false   => "absent",
      default => $ensure,
    },
    require => File["/usr/local/sbin/backup-runner.sh"],
  }

  if defined(Class['ganglia::monitor']) {
    ganglia::gmetric::cron { "backupstats_${backup_name}.rb":
      runwhen     => "30",
      source_name => "backupstats.rb",
      source      => "duplicity/ganglia",
      ensure      => $ganglia ? {
        false   => "absent",
        default => $ensure,
      },
    }
  }

  if defined(Class['icinga::monitored::common']) {
    # # Icinga
    icinga::nrpe_service { "${fqdn}_backup_${backup_name}":
      service_description => "backup ${backup_name}",
      command_name        => "check_backup_${backup_name}",
      command_line        => "/usr/lib/nagios/plugins/check_file_age -f /var/log/backup/.success-${backup_name} -w 72000 -c 172800",
      servicegroups       => "Backup",
      ensure              => $ensure,
    }
  }
}
