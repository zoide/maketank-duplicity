define duplicity::backup (
  $ensure              = "present",
  $backup_name         = $::fqdn,
  $source              = "/",
  $target              = "",
  $gpg_password        = "",
  $gpg_key             = 'disabled',
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
  $runcondition        = false,
  $randomsleep         = false,
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

  File {
    ensure => $ensure, }

  file {
    "${cf_r}/${backup_name}":
      require => File["${cf_r}"],
      ensure  => $dir_ensure,
      recurse => true,
      force   => true,
      mode    => "0700";

    "${cf_r}/${backup_name}/conf":
      require => File["${cf_r}/${backup_name}"],
      content => template("duplicity/conf.erb");

    "${cf_r}/${backup_name}/runner.params":
      require => File["${cf_r}/${backup_name}"],
      content => template("duplicity/runner_params.erb");

    [
      "${cf_r}/${backup_name}/${duplicity::params::pred}",
      "${cf_r}/${backup_name}/${duplicity::params::postd}"]:
      require => File["${cf_r}/${backup_name}"],
      ensure  => $dir_ensure;

    "${cf_r}/${backup_name}/pre":
      ensure  => $ensure,
      require => File["${cf_r}/${backup_name}"],
      content => "${duplicity::params::prepost_runner} ${cf_r}/${backup_name}/${duplicity::params::pred}",
      mode    => '0700',
      owner   => 'root',
      group   => 'root';

    "${cf_r}/${backup_name}/post":
      ensure  => $ensure,
      require => File["${cf_r}/${backup_name}"],
      content => "${duplicity::params::prepost_runner} ${cf_r}/${backup_name}/${duplicity::params::postd}",
      mode    => '0700',
      owner   => 'root',
      group   => 'root';
  }

  cron { "duply-run-${backup_name}":
    command => "/usr/local/sbin/backup-runner.sh ${backup_name} pre_incr_post",
    user    => 'root',
    hour    => $hour,
    minute  => $minute,
    ensure  => $cron ? {
      false   => 'absent',
      default => $ensure,
    },
  }

#  if defined(Class['ganglia::monitor']) {
#    ganglia::gmetric::cron { "backupstats_${backup_name}.rb":
#      runwhen     => "30",
#      source_name => "backupstats.rb",
#      source      => "duplicity/ganglia",
#      ensure      => $ganglia ? {
#        false   => "absent",
#        default => $ensure,
#      },
#    }
#  }

  if defined(Class['icinga::monitored::common']) {
    # # Icinga
    icinga::object::nrpe_service { "${::fqdn}_backup_${backup_name}":
      service_description => "backup ${backup_name}",
      command_name        => "check_backup_${backup_name}",
      command_line        => "/usr/lib/nagios/plugins/check_file_age -f /var/log/backup/.success-${backup_name} -w 39600 -c 54000",
      servicegroups       => "Backup",
      ensure              => $ensure,
    }
  }
}
