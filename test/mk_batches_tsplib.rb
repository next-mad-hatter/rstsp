#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

res = []

files = Dir[ File.expand_path(File.dirname(__FILE__)) + "/data/tsplib/*.tsp" ]
        .map{|x| File.basename x}

files.each do |tsp|
  ([[:pyramidal,nil]] + [:balanced].product((2..3).to_a)).each do |algo_max|
    algo, max = *algo_max
    if (
      (max and algo == :pyramidal) or
      (!max and algo == :balanced))
      next
    end
    res << {
      :name => tsp,
      :bin => :mlton,
      :algo => algo,
      :max => max,
      :data => "tsplib/#{tsp}",
      :timeout => 10.0
    }
  end
end
puts JSON.pretty_generate(res)
