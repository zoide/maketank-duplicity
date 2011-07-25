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
class duplicity ( $ensure = "present",
    $backup_name="${fqdn}",
    $source = "",
    $target = "",
    $gpg_password = "",
    $target_user = "",
    $target_pasword = "",
    $gpg_options = "--compress-algo=bzip2 --bzip2-compress-level=9",
    $max_full_backups = "1",
    $max_full_backup_age = "2M",
    $max_age = "1M",
    $temp_dir = "/tmp",
    $volsize = "50" ) {
    package {
        ["duply", "duplicity"] :
            ensure => $ensure
    }
    
    $dir_ensure = $ensure ? {
                "present" => "directory",
                default => "absent",
            }
    
    file {
        "/etc/duply" :
            ensure => $dir_ensure, 
            recurse => true,
            force => true,
            mode => "0700",
            require => Package["duply"],
    }

    file {"/etc/duply/${backup_name}":
        require => File["/etc/duply"],
        ensure => $dir_ensure, 
            recurse => true,
            force => true,
            mode => "0700",
    }
    
    file{"/etc/duply/${backup_name}/conf":
        content => template("duplicity/conf.erb"),
        ensure => $ensure,
        require => File["/etc/dupl/${backup_name}"],
    }
}
