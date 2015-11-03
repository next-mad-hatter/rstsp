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

mat = []
0.upto(size-1) do |x|
  0.upto(x) do |y|
    #puts "#{flat_coor(x,y)} #{x} #{y}"
    mat[flat_coor(x,y)] = if x == y then 0 else rand(2..100) end
  end
end

0.upto(size-1) do |x|
  0.upto(size-1) do |y|
    print mat[flat_coor(x,y)]
    print " " unless y == size-1
  end
  puts
end
