#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

res = []
timeout = 60
[:mlton, :poly].each do |bin|
  (1..50).each do |size|
    ([[:pyramidal,nil]] + [:balanced].product((1..5).to_a)).each do |algo_max|
      algo, max = *algo_max
      res << {
        :name => [bin, size, algo, max || "null"].join("_"),
        :bin => bin,
        :algo => algo,
        :max => max,
        :data => "random/random.#{size}",
        :timeout => 0.3
      }
    end
  end
end
puts JSON.pretty_generate(res)
