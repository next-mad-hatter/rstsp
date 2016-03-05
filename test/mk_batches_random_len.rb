#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

res = []

set = []
(3..45).step(1) do |i| set << [:mlton,i] end
set.each do |bin,size|
  ([[1,0]] + [[200,0]] + [[200,"all"]]).each do |iters,max_rot|
    ([[:pyramidal,nil]] + [:balanced].product((3..3).to_a)).each do |algo_max|
      algo, max = *algo_max
      if (
        (max and algo == :pyramidal) or
        (!max and algo == :balanced))
        next
      end
      res << {
        :name => [bin, size, algo, max || "null"].join("_"),
        :bin => bin,
        :algo => algo,
        :max => max,
        :iters => iters,
        :stale => nil,
        :max_rot => max_rot,
        :size => size,
        :data => "random/random.#{size}",
        :verbose => true,
        :timeout => 45.0
      }
    end
  end
end
puts JSON.pretty_generate(res)
