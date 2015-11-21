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

$bounds = {}

File.open(File.expand_path(File.dirname(__FILE__)) + "/../test/data/tsplib/SOLUTIONS.txt").each_line do |line|
  next unless line.strip =~ /(\S+)[\s:]+(\d+)$/
  $bounds[$1] = $2.to_i
end

File.read(File.expand_path(File.dirname(__FILE__)) + "/../test/data/dimacs/BOUNDS.txt" ).each_line do |line|
  xs = line.split
  key = xs[0]
  val = xs.select{|x| x =~ /^\d+(.\d+)*$/}
  next unless val.length > 0
  $bounds[xs[0]] = val[-1].to_i
end

File.read(File.expand_path(File.dirname(__FILE__)) + "/../test/data/vlsi/SUMMARY.txt").each_line do |line|
  xs = line.split
  next unless xs.length > 2 and xs[3] =~ /^[\d,]+\d$/
  $bounds[xs[0]] = xs[3].gsub(/,/,'').to_i
end

def inst_name(filename)
  filename.split(".")[0..-2].join(".")
end

def inst_val(tsp,val)
  if $bounds[tsp] and val then val.to_f / $bounds[tsp] else nil end
end

["tsplib"].each do |batch|
  begin
    data = JSON.parse(File.read(LOG_DIR + "/#{batch}.json"), {:symbolize_names => true})
           .select{|x| not x[:err] =~ /Input Error/}
  rescue
    next
  end

  instances = data.collect{|x| x[:name]}.sort.uniq

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
            #[:val, :time].each do |plot|
            [:val].each do |plot|
              csv = instances.collect{|tsp|
                e = d.find{|x| x[:name] == tsp}
                #puts e.delete_if{|k| [:err,:out,:cmd].include? k}.inspect
                f = if e then
                      if plot == :val then inst_val(inst_name(tsp), e[:val]) else e[log_fields[plot]] end
                    else
                      nil
                    end
                [inst_name(tsp), f || "t"]
              }
              next if csv.collect{|x| x[1]}.uniq == ["t"]
              csv_str = csv.collect{|x| x.join " "}.join("\n")
              filename = [batch, plot, algo, "m#{max||0}", "i#{iters||1}", "j#{stale||"def"}", "r#{rot||0}"].join("_")
              File.open(DATA_DIR + "/#{filename}.csv", "w+"){ |f| f.write(csv_str)}
            end
          end
        end
      end
    end
  end
end
