#!/usr/bin/ruby
#
# $File$
# $Author$
# $Date$
# $Revision$
#

require 'json'
require 'powerbar'
require 'open3'
require 'timeout'
require 'bigdecimal'

class FormatError < Exception
end

class Batch

  def self.command(opts)
    cmd = ""
    cmd << File.expand_path(File.dirname(__FILE__)) + "/../src/rstsp/build/"
    cmd << case opts[:bin]
      when "mlton"
        "rstsp.mlton"
      when "poly"
        "rstsp.poly"
      else
        raise FormatError
      end
    cmd << " -v" if opts[:verbose]
    cmd << case opts[:algo]
      when "pyramidal"
        " -t p"
      when "balanced"
        " -t b"
      else
        raise FormatError
      end
    cmd << case opts[:max]
      when nil
        ""
      else
        if opts[:max].class == Fixnum then " -m #{opts[:max]}"
                                      else raise FormatError end
      end
    cmd << case opts[:iters]
      when nil
        ""
      else
        if opts[:iters].class == Fixnum then " -i #{opts[:iters]}"
                                        else raise FormatError end
      end
    cmd << case opts[:stale]
      when nil
        ""
      else
        if opts[:stale].class == Fixnum then " -j #{opts[:stale]}"
                                        else raise FormatError end
      end
    cmd << case opts[:rot]
      when nil
        ""
      when "all"
        " -r all"
      else
        if opts[:rot].class == Fixnum then " -r #{opts[:rot]}"
                                      else raise FormatError end
      end
    cmd << " " + File.expand_path(File.dirname(__FILE__)) + "/data/"
    cmd << case opts[:data]
      when nil
        raise FormatError
      else
        opts[:data]
      end
    raise FormatError if opts[:timeout] and !(opts[:timeout].is_a? Numeric)
    cmd
  end

  def self.run_batch(batch, printer)
    begin
      cmd = self.command(batch)
      res = {:out => "", :err => ""}
      t0 = Time.now
      Open3.popen3(cmd) do |i,o,e,t|
        begin
          Timeout.timeout(batch[:timeout]) do
            i.close
            res[:err] << e.read
            res[:out] << o.read
            #res[:out] =~ /Real time:\s+(\d+)\s+ms/
            #res[:time] = $1
            res[:real_time] = Time.now - t0
            mtch = res[:out].match(/Tour Length:\s*(\d+(.\d+)*)/)
            res[:val] =
              if mtch then
                (BigDecimal.new(mtch[1]).frac == 0) and mtch[1].to_i or mtch[1].to_f
              else nil end
          end
        rescue Timeout::Error
          Process.kill("KILL", t.pid)
          res[:real_time] = nil
        end
        res[:thread] = t.value
      end
      return [(!(res[:out] =~ /Valid:\s*no/i) and res[:val] and res[:thread] and res[:thread].success?),
              batch.merge({:cmd => cmd}).merge(res)]
    rescue JSON::ParserError, FormatError
      printer.call "Bad batch" # + opt[:name].inspect
      return [false, nil]
    end
  end

end


if __FILE__ == $0 # or true # for ruby-prof

  unless ARGV.length > 1
    puts "Usage: #{File.basename($0)} out_file in_file(s)\n"
    exit 1
  end
  output = ARGV.shift

  batches = []
  ARGV.each do |f|
    begin
      batches += JSON.parse(File.read(f), {:symbolize_names => true})
    rescue JSONParseError => _
      puts "Bad json file: #{f}."
      exit 1
    rescue SystemCallError => e
      puts "Error: " + e.to_s
      exit 1
    end
  end
  total = batches.length

  begin
    progress = PowerBar.new
    progress.settings.tty.finite.template.barchar = '*'
    progress.settings.tty.finite.template.padchar = '.'
    count = fails = 0
    results = []
    progress.show(:msg =>if count == total then " Done" else " Test #{count+1}/#{total}" end,
                  :done => count, :total => total)
    batches.each do |batch|
      status, res = Batch.run_batch(batch, Proc.new{|x| progress.print(x+"\n")})
      #outfile.write(JSON.pretty_generate(res)+"\n") if res
      #outfile.flush
      results << res
      fails += 1 unless status
      count += 1
      progress.show(:msg =>if count == total then " Done" else " Test #{count+1}/#{total}" end,
                    :done => count, :total => total)
    end
    progress.close true
    puts " Tests completed: #{count}; succeded: #{count-fails}, failed: #{fails}."
    File.open(output, "w+") do |outfile|
      outfile.write(JSON.pretty_generate(results))
    end
  rescue SystemCallError => e
    puts "Error: " + e.to_s
    exit 1
  end

end
