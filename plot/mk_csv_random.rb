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

["len", "steady", "low", "med", "hi"].each do |batch|
  begin
    data = JSON.parse(File.read(LOG_DIR + "/random_#{batch}.json"), {:symbolize_names => true})
  rescue
    next
  end

  sizes = data.collect{|x| x[:size]}.uniq.sort_by(&:to_i)

  bins = data.collect{|x| x[:bin]}.uniq
  algos = data.collect{|x| x[:algo]}.uniq
  maxs = data.collect{|x| x[:max]}.uniq
  all_iters = data.collect{|x| x[:iters]}.uniq
  stales = data.collect{|x| x[:stale]}.uniq
  rots = data.collect{|x| x[:rot]}.uniq

  log_fields = {:time => :real_time, :val => :val}
  bins.each do |bin|
    algos.each do |algo|
      maxs.each do |max|
        next if ((max and algo == "pyramidal") or (!max and algo == "balanced"))
        all_iters.each do |iters|
          stales.each do |stale|
            rots.each do |rot|
              d = data.select{|x| x[:bin] == bin}
                      .select{|x| x[:algo] == algo}
                      .select{|x| x[:max] == max}
                      .select{|x| x[:iters] == iters}
                      .select{|x| x[:stale] == stale}
                      .select{|x| x[:rot] == rot}
              [:time, :val].each do |plot|
                csv = sizes.collect{|sz|
                  e = d.find{|x| x[:size] == sz}
                  f = if e then e[log_fields[plot]] else nil end
                  [sz, f || "t"]
                }
                next if csv.collect{|x| x[1]}.uniq == ["t"]
                csv_str = csv.collect{|x| x.join " "}.join("\n")
                filename = [bin, plot, batch, algo, "m#{max||0}", "i#{iters||1}", "j#{stale||"def"}", "r#{rot||0}"].join("_")
                File.open(DATA_DIR + "/#{filename}.csv", "w+"){ |f| f.write(csv_str)}
              end
            end
          end
        end
      end
    end
  end
end

