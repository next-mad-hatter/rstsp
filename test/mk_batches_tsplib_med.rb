#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

MAX_DIM = 250
MAX_PROBS_PER_DATASET = 27

files = {}
["tsplib", "dimacs","vlsi"].each do |dataset|
  files[dataset] = Dir[ File.expand_path(File.dirname(__FILE__)) + "/data/#{dataset}/*.tsp" ]
                   .map{|x|
                     open(x){|f| f.find{|l| l =~ /DIMENSION[\s:]+(\d+)/}}
                     dim = if $1 then $1.to_i else nil end
                     supp = (dim and dim <= MAX_DIM)
                     if supp
                       open(x){|f| f.find{|l| l =~ /EDGE_WEIGHT_TYPE[\s:]+(\S+)/}}
                       supp &&= ["EXPLICIT","EUC_2D","CEIL_2D"].include? $1
                     end
                     if supp
                       open(x){|f| f.find{|l| l =~ /EDGE_WEIGHT_FORMAT[\s:]+(\S+)/}}
                       supp &&= [nil,"FULL_MATRIX","LOWER_DIAG_ROW","UPPER_DIAG_ROW","FUNCTION"].include? $1
                     end
                     [ dim.to_i, File.basename(x), supp ]
                   }.select{|x| x[2]}.sort.take(MAX_PROBS_PER_DATASET)
end

res = []
files.each_key do |dataset|
  files[dataset].each do |size, tsp, supp|
    ([[:pyramidal,nil],[:balanced,2],[:balanced,3]]).each do |algo, max|
      res << {
        :name => tsp,
        :bin => :mlton,
        :algo => algo,
        :iters => 0,
        :stale => nil,
        :max_rot => "all",
        :adapt => nil,
        :flips => nil,
        :max => max,
        :data => "#{dataset}/#{tsp}",
        :size => size,
        :timeout => 1800.0
      }
    end
  end
end
puts JSON.pretty_generate(res)
