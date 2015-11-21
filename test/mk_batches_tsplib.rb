#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

files = {}
["tsplib", "dimacs"].each do |dataset|
  files[dataset] = Dir[ File.expand_path(File.dirname(__FILE__)) + "/data/#{dataset}/*.tsp" ]
                   .take(13).map{|x| File.basename x}
end

res = []
files.each_key do |dataset|
  files[dataset].each do |tsp|
    ([[1,0]] + [[10,0]] + [[10,10]]).each do |iters,rot|
      ([[:pyramidal,nil]] + [:balanced].product((2..3).to_a)).each do |algo,max|
        if (
          (max and algo == :pyramidal) or
          (!max and algo == :balanced))
          next
        end
        res << {
          :name => tsp,
          :bin => :mlton,
          :algo => algo,
          :iters => iters,
          :stale => if iters == 1 then nil else 2 end,
          :rot => rot,
          :max => max,
          :data => "#{dataset}/#{tsp}",
          :timeout => 45.0
        }
      end
    end
  end
end
puts JSON.pretty_generate(res)
