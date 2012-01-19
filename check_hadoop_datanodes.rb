#!/usr/bin/env ruby

require 'optparse'

options = {}

optparse = OptionParser.new do |opts|

opts.banner = "Usage: #{$PROGRAM_NAME} -w <dead server % warning> -c <dead server % critical>"

  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information') do
    options[:verbose] = true
  end

  opts.on('-w', '--warning <percent of servers dead>', 'Percentage of dead servers to warn upon') do |w|
    options[:warning] = w
    options[:warning_float] = w.to_i/100.0
  end

  opts.on('-c', '--critical <percentage of servers dead', 'Percentage of dead servers to critical upon') do |c|
    options[:critical] = c
    options[:critical_float] = c.to_i/100.0
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end


begin
  optparse.parse!
  mandatory = [:warning,:critical]
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

parsed_results = {}

begin 
  result = `hadoop dfsadmin -report`
rescue Errorno::ENOENT
  puts "hadoop command not found, is it in your path?"
  exit 3
end

result.each_line do |line|
  if line.include?("Datanodes available:")
    parsed_results[:datanode_data]=line
    parsed_results[:datanode_avail]=/\d+/.match(parsed_results[:datanode_data])[0].to_i
    parsed_results[:datanode_total]=/\d+ total/.match(parsed_results[:datanode_data])[0].to_s
    parsed_results[:datanode_total]=/\d+/.match(parsed_results[:datanode_total])[0].to_i
    parsed_results[:datanode_dead]=/\d+ dead/.match(parsed_results[:datanode_data])[0].to_s
    parsed_results[:datanode_dead]=/\d+/.match(parsed_results[:datanode_dead])[0].to_i
    parsed_results[:datanode_ratio]=(100*(parsed_results[:datanode_dead].to_f/parsed_results[:datanode_total]))
  end
end

if options[:verbose]
  puts "Total datanodes: #{parsed_results[:datanode_total]}"
  puts "Alive datanodes: #{parsed_results[:datanode_avail]}"
  puts "Dead  datanodes: #{parsed_results[:datanode_dead]}"
  puts "Dead datanode %: #{parsed_results[:datanode_ratio]}"
end

if (parsed_results[:datanode_ratio] > options[:critical].to_i)
  puts "Critical number of servers dead: #{parsed_results[:datanode_dead]}"
  exit 2
elsif (parsed_results[:datanode_ratio] > options[:warning].to_i)
  puts "Warning number of servers dead: #{parsed_results[:datanode_dead]}"
  exit 1
else
  puts "Okay amount of live servers: #{parsed_results[:datanode_avail]}"
  exit 0
end
