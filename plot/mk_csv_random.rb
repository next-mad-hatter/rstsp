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

["steady", "low", "med", "hi"].each do |batch|
  data = JSON.parse(File.read(LOG_DIR + "/random_#{batch}.json"),
                    {:symbolize_names => true})
         .select{|x| x[:real_time].is_a? Numeric}

  bins = data.collect{|x| x[:bin]}.uniq
  algos = data.collect{|x| x[:algo]}.uniq
  maxs = data.collect{|x| x[:max]}.uniq
  iters = data.collect{|x| x[:iters]}.uniq
  stale = data.collect{|x| x[:stale]}.uniq

  log_fields = {:time => :real_time, :val => :val}
  bins.each do |bin|
    algos.each do |algo|
      maxs.each do |max|
        next if ((max and algo == "pyramidal") or (!max and algo == "balanced"))
        iters.each do |iters|
          stale.each do |stale|
            d = data.select{|x| x[:bin] == bin}
                    .select{|x| x[:algo] == algo}
                    .select{|x| x[:max] == max}
                    .select{|x| x[:iters] == iters}
                    .select{|x| x[:stale] == stale}
            [:time, :val].each do |plot|
              csv = d.collect{|x| [x[:size], x[log_fields[plot]]].join(" ")}.join("\n")
              next if csv.empty?
              filename = [bin, plot, batch, algo, "m#{max||0}", "i#{iters||1}", "j#{stale||"def"}"].join("_")
              File.open(DATA_DIR + "/#{filename}.csv", "w+"){ |f| f.write(csv)}
            end
          end
        end
      end
    end
  end
end

