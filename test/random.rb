#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

size = 200

def flat_coor(row, col)
  if row >= col then ((row*(row+1)).div 2) + col else flat_coor(col, row) end
end

unless ARGV.length == 3
  puts "Usage: #{File.basename($0)} size min_value max_value"
  exit 1
end

size = ARGV[0].to_i
min_v = ARGV[1].to_i
max_v = ARGV[2].to_i

mat = []
0.upto(size-1) do |x|
  0.upto(size-1) do |y|
    print ( mat[flat_coor(x,y)] ||=
           if x == y then 0 else rand (min_v..max_v) end )
    print " " unless y == size-1
  end
  puts
end
