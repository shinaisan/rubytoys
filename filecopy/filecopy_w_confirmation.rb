# -*- coding: utf-8 -*-
# Let users choose a file and copy it to a directory specified via the variable "dest_path" below.
# Existing files will be overwritten.
require 'fileutils'

#########################
# configuration start   #
glob_pattern = '*.rb'   # pattern for source files
dest_path = 't:/tmp'    # destination directory or file to overwrite
# configuration end     #
#########################

file_list = Dir.glob(glob_pattern)

index = 0
file_list.each do |file|
  index += 1
  puts "%4d\t%s" % [index, file]
end

index_from = 1
index_to = file_list.length

begin
  print 'Enter index (%d-%d): ' % [index_from, index_to]
  index = Integer(readline.chop)
  if index < index_from or index > index_to
    raise ArgumentError.new('Index out of range: (%d)' % index)
  end
rescue ArgumentError => e
  puts e
  retry
end

src_file = file_list[index - 1]

puts "Copying <%s> to <%s> ..." % [src_file, dest_path]
print "Is this ok? (y/n): "
yn = readline.chop
if yn == "y"
  FileUtils.copy(src_file, dest_path)
end
