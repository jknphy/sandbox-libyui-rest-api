#!/usr/bin/ruby -w
 
require "net/http"
require "json"
require "uri"
 
uri = URI("http://localhost:9999")
uri.path = "/widgets"
 
# Check module loaded
puts "Read dialog heading..."
puts "\tExpected: Host Configuration"
uri.query = URI.encode_www_form({type: "YWizard"})
res = Net::HTTP.get_response(uri)
label = JSON.parse(res.body)[0]['debug_label']
puts "\tGot:      #{label}"
 
# Add new host configuration
puts "Click on button Add..."
uri.query = URI.encode_www_form({id: "add", action: "press"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
# Check dialog loaded
puts "Check dialog is present..."
uri.query = URI.encode_www_form({type: "YDialog"})
res = Net::HTTP.get_response(uri)
 
# Type data: IP Address, Hostname and Host aliases
puts "Type IP Address..."
uri.query = URI.encode_www_form({id: "host", action: "enter_text", value: "198.1.1.1"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
puts "Type Hostname..."
uri.query = URI.encode_www_form({id: "name", action: "enter_text", value: "awesome.hostname"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
puts "Type Host Aliases..."
uri.query = URI.encode_www_form({id: "aliases", action: "enter_text", value: "cool.hostname"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
# Confirm dialog
puts "Click on button OK..."
uri.query = URI.encode_www_form({id: "ok", action: "press"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
puts "Waiting for refreshment of components"
sleep(2)
 
# Select 1st row on the table
puts "Select 1st row on the table..."
uri.query = URI.encode_www_form({id: "table", action: "select_table", value: "::1"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
# Check that new host configuration was added
puts "Check new row was added"
puts "\tExpected: 198.1.1.1"
uri.query = URI.encode_www_form({"type" => "YTable"})
res = Net::HTTP.get_response(uri)
rows = JSON.parse(res.body)[0]["items"]
found = false
rows.each do |row|
	if row["labels"][0] == "198.1.1.1"
		found = true
		break
	end
end
result = found ? "\tGot:      198.1.1.1" : "\tGot: Not found"
puts result
 
# Confirm changes in YaST module
puts "Click on button OK..."
uri.query = URI.encode_www_form({id: "next", action: "press"})
req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
http = Net::HTTP::new(uri.host, uri.port)
res = http.request(req)
 
puts "Waiting for writing configuration"
sleep(2)
 
puts "Checking /etc/hosts file"
result = system("grep '^198.1.1.1.*awesome.hostname.*cool.hostname$' /etc/hosts")
puts result ? "File was updated succesfully" : "hostname not found"

