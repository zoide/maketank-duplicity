#!/usr/bin/env ruby
me=File.basename($0)
jobname = me.gsub(/backupstats_(.*).rb$/, '\1')
file="/var/log/backup/backup-#{jobname}.log"

exit 0 if !File.exists?(file)

debug=false
gmetric="/usr/bin/gmetric --dmax=999999 --tmax=3600 -t float"
%x{grep -A 15 -e 'Backup Statistics' #{file}}.chomp.each {|line|
    next if line =~ /(Backup Statistics|StartTime|EndTime)/
    (key, value, misc) = line.split(" ")
    units="number"
    units="kilobytes" if key =~ /Size$/
    units="seconds" if key =~ /Time$/
    puts "#{gmetric} --units=#{units} --name=\"backup #{jobname} #{key}\" --value=#{value.to_f}" if debug
    %x{#{gmetric} --units=#{units} --name="backup #{jobname} #{key}" --value=#{value.to_f}}
}