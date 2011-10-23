# -*- coding: utf-8 -*-

require 'win32ole'

#########################
# configuration start
# drive-letter	UNC	user-name	password
preset = <<'EOC'.split("\n")
x:	\\host1\dir1	user1	password1
y:	\\host2\dir2	user2	password2
z:	\\host3\dir3	user3	password3
EOC
# configuration end
#########################

index = 0
preset.each do |conf|
  index += 1
  puts "%4d\t%s" % [index, conf]
end

index_from = 1
index_to = preset.length

print "Enter index (%d-%d): " % [index_from, index_to]
index = Integer(readline.chop)
if index < index_from or index > index_to
  raise ArgumentError.new('Index out of range: (%d)' % index)
end

conf_str = preset[index - 1]
conf = conf_str.split(/[ \t]+/)
drive = conf[0]
unc = conf[1]
user = conf[2] || ""
pass = conf[3] || ""

puts "Mapping %s to %s with user '%s'" % [drive, unc, user]
print "Is this ok? (y/n): "
yn = readline.chop
if yn == "y"
  wsh_network = WIN32OLE.new('WScript.Network')
  wsh_network.MapNetworkDrive(drive, unc, false, user, pass)
end
