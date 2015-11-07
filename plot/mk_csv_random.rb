#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'

PREFIX = File.expand_path(File.dirname(__FILE__)) + "/.."
LOG_DIR = PREFIX + "/test/log/"
DATA_DIR = PREFIX + "/plot/data/"

["low", "hi"].each do |part|
  data = JSON.parse(File.read(LOG_DIR + "/random_#{part}.json"),
                    {:symbolize_names => true})
         .select{|x| x[:real_time].is_a? Numeric}

  bins = data.collect{|x| x[:bin]}.uniq
  algos = data.collect{|x| x[:algo]}.uniq
  maxs = data.collect{|x| x[:max]}.uniq

  bins.each do |bin|
    algos.each do |algo|
      maxs.each do |max|
        next if ((max and algo == "pyramidal") or (!max and algo == "balanced"))
        File.open(DATA_DIR + "/time_#{part}_#{bin}_#{algo}_#{max}.csv", "w+") do |outfile|
          d = data.select{|x| x[:bin] == bin}
                .select{|x| x[:algo] == algo}
                .select{|x| x[:max] == max}
                .collect{|x| [x[:size], x[:real_time]].join(" ")}
                .join("\n")
          outfile.write(d)
        end
      end
    end
  end
end

