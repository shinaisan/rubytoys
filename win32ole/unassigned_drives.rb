require 'win32ole'

fso = WIN32OLE.new('Scripting.FileSystemObject');

puts "List of unassigned drives:"
("a".."z").select {|d| !fso.DriveExists(d)}.each do |ud|
  puts ud + ":"
end
