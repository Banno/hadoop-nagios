#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'net/http'
require 'trollop'


def load_hadoop_json(nameNodeAddress, nameNodePort)
	base_url = "http://"+nameNodeAddress+":"+nameNodePort+"/jmx"
	resp = Net::HTTP.get_response(URI.parse(base_url))
	data = resp.body

	result = JSON.parse(data)

	return result
end


def check_memory
	max_mem = $hadoop_json["beans"][2]["HeapMemoryUsage"]["max"]
	used_mem = $hadoop_json["beans"][2]["HeapMemoryUsage"]["used"]
	return (100*(used_mem.to_f/max_mem)).round(2)
end

opts = Trollop::options do
	opt :address, "Hadoop IP or address", :default => "127.0.0.1", :short => '-a'
	opt :port, "Hadoop webserver port w/ JMX enabled", :default => "50070", :short => '-p'
	opt :warning, "Percentage to warn on", :default => "85", :short => '-w'
	opt :critical, "Percentage to crit on", :default => "95", :short => '-c'
	opt :memory, "Whether or not to display percentage of used heap memory", :short => '-m'
end

$hadoop_json = load_hadoop_json(opts[:address],opts[:port])
if opts[:memory]
	memory_used = check_memory
	if (memory_used >= opts[:critical].to_f)
			puts memory_used.to_s + "% of total heap used. CRITICAL! | percent_memory=" + memory_used.to_s
		exit 2
	elsif (memory_used >= opts[:warning].to_f)
		puts memory_used.to_s + "% of total heap used. Warning! | percent_memory=" + memory_used.to_s
		exit 1
	else
		puts memory_used.to_s + "% of total heap used. Everything looks good! | percent_memory=" + memory_used.to_s
		exit 0
	end
end




