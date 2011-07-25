# $Id$
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
class duplicity ($ensure="present", $confdir="/etc/duply") {

$dir_ensure = $ensure ? {
                "present" => "directory",
                default => "absent",
            }
    
    file {
        "${duplicity::confdir}" :
            ensure => $dir_ensure, 
            recurse => true,
            force => true,
            mode => "0700",
            require => Package["duply"],
    }

    package {
        ["duply", "duplicity"] :
            ensure => $ensure
    }

    file{"/usr/local/sbin/backup-runner.sh":
        ensure => $ensure,
        source => "puppet:///modules/duplicity/backup-runner.sh",
        mode => "0700",        
        }    
    
define backup ( $ensure = "present",
    $backup_name="${fqdn}",
    $source="/",
    $target="",
    $gpg_password="",
    $target_user="",
    $target_password="",
    $gpg_options="--compress-algo=bzip2 --bzip2-compress-level=9",
    $max_full_backups="1",
    $max_full_backup_age="2M",
    $max_age="1M",
    $temp_dir="/tmp",
    $volsize="50",
    $hour="*/10",
    $minute="10",
    $confdir="${duplicity::confdir}" ) {
        
    if !defined(Class["duplicity"]) {
        class{"duplicity": ensure => $ensure }
    }
    
    $dir_ensure = $ensure ? {
                "present" => "directory",
                default => "absent",
            }
    file {"${duplicity::confdir}/${backup_name}":
        require => File["${duplicity::confdir}"],
        ensure => $dir_ensure, 
            recurse => true,
            force => true,
            mode => "0700",
    }
    
    file{"${duplicity::confdir}/${backup_name}/conf":
        content => template("duplicity/conf.erb"),
        ensure => $ensure,
        require => File["${duplicity::confdir}/${backup_name}"],
    }
    cron{"duply-run-${backup_name}":
        command => "/usr/local/sbin/backup-runner.sh ${backup_name} pre_incr_post",
        user => root,
        hour => "${hour}",
        minute => "${minute}",
        ensure => $ensure,
        require => File["/usr/local/sbin/backup-runner.sh"],
    }
    ganglia::gmetric::cron{"backupstats_${backup_name}.rb":
        runwhen => "30",
        source_name => "backupstats.rb",
        source => "duplicity/ganglia",
        ensure => $ensure,    
    }
}

define pre($content, 
        $backup_name="${fqdn}",
        $confdir="${duplicity::confdir}",
        $ensure="present"
        ){
     file{"${duplicity::confdir}/${backup_name}/pre":
        ensure => "${ensure}",
        content => "${content}",
        mode => 0700,
    }       
            }
            
define post($content, 
        $backup_name="${fqdn}",
        $confdir="${duplicity::confdir}",
        $ensure="present"
        ){
     file{"${duplicity::confdir}/${backup_name}/post":
        ensure => "${ensure}",
        content => "${content}",
        mode => 0700,
    }       
}
            
define exclude($content, 
        $backup_name="${fqdn}",
        $confdir="${duplicity::confdir}",
        $ensure="present"
        ){
    
    file{"${duplicity::confdir}/${backup_name}/exclude":
        ensure => "${ensure}",
        content => "${content}",
        mode => 0600,
    }
}
}