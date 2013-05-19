# Some facts on duplicity
require 'facter/util/resolution'

dupl = Facter::Util::Resolution.exec('duplicity --version |cut -f2 -d" "')
if !dupl.nil?
  Facter.add("duplicity_version") do
    setcode do
      dupl
    end
  end
end

duply = Facter::Util::Resolution.exec('duply --version |head -1 |awk \'{print $3}\'')
if !duply.nil?
  Facter.add("duply_version") do
    setcode do
      duply
    end
  end
end