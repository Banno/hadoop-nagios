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
	opt :memory, "Whether or not to display percentage of used heap memory", :short => '-m'
end

$hadoop_json = load_hadoop_json(opts[:address],opts[:port])
if opts[:memory]
		puts check_memory
end




