#
# $File$
# $Author$
# $Date$
# $Revision$
#

types = File.open("types_1").readlines.map(&:split).map{|t| t.map(&:to_i)}

(3..1000).each do |size|

  hs = []
  f = Math.log(size,2).ceil
  #base = 2 ** f
  #base = f
  base = size
  (1..size).each do |sz|
    types.each do |t|
      # subtract
      h = t.to_enum.with_index(0).map{|x,i| if i>0 and i%2==0 then x-t[i-2] else x end}
      # polynomial map
      v = (h.each_index.inject(0){|s,i| s+(h[i]+1)*base**(h.length-i-1)} + sz*base**h.length) % (2**31 - 1)
      #puts(([size,sz,f,":"]+h.map{|x| x+1}+[":",v]).join(" "))
      hs << v
    end
  end

  #puts hs.inspect
  l = hs.uniq.length
  unless l == size*types.length
    puts "****"
    puts [size, ":",
          size*types.length, l,
          (l.to_f/(size*types.length)*100).floor.to_s+"%"
         ].join(" ")
  end

end
