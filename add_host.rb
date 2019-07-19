#!/usr/bin/ruby -w
 
require "net/http"
require "json"
require "uri"
require "socket"
require "timeout"
 
class HostConfiguration
	@@uri = URI("http://localhost:9999")
	@@uri.path = "/widgets"
 
	def port_open?(host, port)
		TCPSocket.new(host, port).close
		true
	rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
		false
	end
	
	def wait_for_port(host, port)
		Timeout.timeout(15) do
		loop do
			sleep(1)
			puts "Waiting for #{host}:#{port}..."
			break if port_open?(host, port)
		end
		end
	end
	
	def open_application
		ENV["Y2TEST"] = "1"
		ENV["YUI_HTTP_PORT"] = "9999"
	
		@app_pid = spawn("xterm -e '/usr/sbin/yast2 host'", pgroup: true)
		puts "pid: #{@app_pid}"
	
		wait_for_port("localhost", 9999)
	end
 
	def read_module_heading
			@@uri.query = URI.encode_www_form({type: "YWizard"})
			res = Net::HTTP.get_response(@@uri)
			label = JSON.parse(res.body)[0]['debug_label']
	end

	def click_button_add
			@@uri.query = URI.encode_www_form({id: "add", action: "press"})
			req = Net::HTTP::Post.new("#{@@uri.path}?#{@@uri.query}", 'Content-Type' => 'application/json')
			http = Net::HTTP::new(@@uri.host, @@uri.port)
			res = http.request(req)
	end

	def check_add_dialog_loaded
		@@uri.query = URI.encode_www_form({type: "YDialog"})
		res = Net::HTTP.get_response(@@uri)
	end

	def fill_hostname_form
		@@uri.query = URI.encode_www_form({id: "host", action: "enter_text", value: "198.1.1.1"})
		req = Net::HTTP::Post.new("#{@@uri.path}?#{@@uri.query}", 'Content-Type' => 'application/json')
		http = Net::HTTP::new(@@uri.host, @@uri.port)
		res = http.request(req)

		@@uri.query = URI.encode_www_form({id: "name", action: "enter_text", value: "awesome.hostname"})
		req = Net::HTTP::Post.new("#{@@uri.path}?#{@@uri.query}", 'Content-Type' => 'application/json')
		http = Net::HTTP::new(@@uri.host, @@uri.port)
		res = http.request(req)

		@@uri.query = URI.encode_www_form({id: "aliases", action: "enter_text", value: "cool.hostname"})
		req = Net::HTTP::Post.new("#{@@uri.path}?#{@@uri.query}", 'Content-Type' => 'application/json')
		http = Net::HTTP::new(@@uri.host, @@uri.port)
		res = http.request(req)
	end

	def confirm_dialog
		@@uri.query = URI.encode_www_form({id: "ok", action: "press"})
		req = Net::HTTP::Post.new("#{@@uri.path}?#{@@uri.query}", 'Content-Type' => 'application/json')
		http = Net::HTTP::new(@@uri.host, @@uri.port)
		res = http.request(req)
	end

	def wait
		sleep(2)
	end
	#
	## Select 1st row on the table
	#puts "Select 1st row on the table..."
	#uri.query = URI.encode_www_form({id: "table", action: "select_table", value: "::1"})
	#req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
	#http = Net::HTTP::new(uri.host, uri.port)
	#res = http.request(req)
	#
	def check_new_row_added
		@@uri.query = URI.encode_www_form({"type" => "YTable"})
		res = Net::HTTP.get_response(@@uri)
		rows = JSON.parse(res.body)[0]["items"]
		found = false
		rows.each do |row|
			if row["labels"][0] == "198.1.1.1"
				found = true
				break
			end
		end
		result = found
	end

	def confirm_changes
		@@uri.query = URI.encode_www_form({id: "next", action: "press"})
		req = Net::HTTP::Post.new("#{@@uri.path}?#{@@uri.query}", 'Content-Type' => 'application/json')
		http = Net::HTTP::new(@@uri.host, @@uri.port)
		res = http.request(req)
	end

	def check_configuration_file
		system("grep '^198.1.1.1.*awesome.hostname.*cool.hostname$' /etc/hosts")
	end
 
end

