#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

unless ARGV.length == 1
  puts "Usage: #{File.basename($0)} size"
  exit 1
end

size = ARGV[0].to_i

puts "TYPE : TSP"
puts "DIMENSION : #{size}"
puts "EDGE_WEIGHT_TYPE : EUC_2D"
puts "EDGE_WEIGHT_FORMAT : FUNCTION"
puts "NODE_COORD_SECTION"
mat = []
1.upto(size) do |x|
  puts "#{x} #{10 * rand} #{10 * rand}"
end
puts "EOF"
