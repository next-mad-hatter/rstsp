#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

res = []
#[:mlton].each do |bin|
[:mlton, :poly].each do |bin|
  (3000..5000).step(500) do |size|
    ([[:pyramidal,nil]] + [:balanced].product((3..4).to_a)).each do |algo_max|
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
        :timeout => 90.0
      }
    end
  end
end
puts JSON.pretty_generate(res)
