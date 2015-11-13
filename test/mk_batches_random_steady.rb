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
(3..100).step(1) do |i| set << [:mlton,i] end
(3..100).step(1) do |i| set << [:poly,i] end
set.each do |bin,size|
  ([[:pyramidal,nil]] + [:balanced].product((2..3).to_a)).each do |algo_max|
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
      :size => size,
      :data => "random/random.#{size}",
      :timeout => 30.0
    }
  end
end
puts JSON.pretty_generate(res)
