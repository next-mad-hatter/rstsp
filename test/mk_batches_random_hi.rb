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
  (1200..1600).step(100) do |size|
    ([[:pyramidal,nil]] + [:balanced].product((2..4).to_a)).each do |algo_max|
      algo, max = *algo_max
      next if ((max and algo == :pyramidal) or (!max and algo == :balanced))
      res << {
        :name => [bin, size, algo, max || "null"].join("_"),
        :bin => bin,
        :algo => algo,
        :max => max,
        :size => size,
        :data => "random/random.#{size}",
        :timeout => 60.0
      }
    end
  end
end
puts JSON.pretty_generate(res)
