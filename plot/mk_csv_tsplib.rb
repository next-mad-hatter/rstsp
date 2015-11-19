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

SOLUTIONS = File.read( File.expand_path(File.dirname(__FILE__)) + "/../test/data/tsplib/SOLUTIONS.txt" ) +
            File.read( File.expand_path(File.dirname(__FILE__)) + "/../test/data/dimacs/BOUNDS.txt" )

def prb_name(filename)
  filename.split(".")[0..-2].join(".")
end

def prb_val(tsp,val)
  tsp = prb_name(tsp)
  SOLUTIONS =~ /#{tsp}\s*:\s*(\d+)/
  val.to_f / $1.to_i
end

["tsplib"].each do |batch|
  begin
    data = JSON.parse(File.read(LOG_DIR + "/#{batch}.json"),
                      {:symbolize_names => true})
           .select{|x| x[:real_time].is_a? Numeric}
  rescue
    next
  end

  algos = data.collect{|x| x[:algo]}.uniq
  maxs = data.collect{|x| x[:max]}.uniq
  all_iters = data.collect{|x| x[:iters]}.uniq
  stales = data.collect{|x| x[:stale]}.uniq
  rots = data.collect{|x| x[:rot]}.uniq

  log_fields = {:time => :real_time}
  algos.each do |algo|
    maxs.each do |max|
      next if ((max and algo == "pyramidal") or (!max and algo == "balanced"))
      all_iters.each do |iters|
        stales.each do |stale|
          rots.each do |rot|
            d = data.select{|x| x[:bin] == "mlton"}
                    .select{|x| x[:algo] == algo}
                    .select{|x| x[:max] == max}
                    .select{|x| x[:iters] == iters}
                    .select{|x| x[:stale] == stale}
                    .select{|x| x[:rot] == rot}
                    .select{|x| x[:val]}
            [:val, :time].each do |plot|
              csv =
                d.collect{|x|
                  [
                    prb_name(x[:name]),
                    if plot == :val then prb_val(x[:name],x[:val]) else x[log_fields[plot]] end
                  ]
                  .join(" ")}
                .join("\n")
              next if csv.empty?
              filename = [batch, plot, algo, "m#{max||0}", "i#{iters||1}", "j#{stale||"def"}", "r#{rot||0}"].join("_")
              File.open(DATA_DIR + "/#{filename}.csv", "w+"){ |f| f.write(csv)}
            end
          end
        end
      end
    end
  end
end
