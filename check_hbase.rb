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
	result = `hbase hbck`
rescue Errno::ENOENT 
	puts "hbase command not found, is it in your path?"
	exit 3
end

result.each_line do |line|
  if line.include?("Version:")
    parsed_results[:version]=line
  end
  if line.include?("Status:")
    parsed_results[:status]=line
  end
  if line.include?("Number of live region servers")
    parsed_results[:live_servers] = line.scan(/\d+/)
  end
  if line.include?("Number of dead region servers")
    parsed_results[:dead_servers] = line.scan(/\d+/)
  end
end

ratio = (parsed_results[:dead_servers][0].to_f / (parsed_results[:live_servers][0].to_f + parsed_results[:dead_servers][0] ))

if options[:verbose]
  puts parsed_results[:version]
  puts "Number of live region servers: #{parsed_results[:live_servers].to_s}"
  puts "Number of dead region servers: #{parsed_results[:dead_servers].to_s}"
  puts "Ratio of live to dead: #{ratio.to_s}"
end

if (ratio > options[:critical_float] || parsed_results[:status].contains("INCONSISTENT"))
  puts "Critical number of servers dead: #{parsed_results[:dead_servers]}"
  exit 2
elsif (ratio > options[:warning_float])
  puts "Warning number of servers dead #{parsed_results[:dead_servers]}"
  exit 1
else
  puts "Okay amount of live servers"
  exit 0
end

