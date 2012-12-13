#!/usr/bin/ruby
# Design:
# (1) Accept STDIN as hash in JSon format
# (2) Convert the JSon format hash to a ruby hash
# (3) Create html using CGI to display the information in the hash
# (4) Return an html as string through STDOUT

require 'rubygems'
require 'json'
require 'xmlsimple'
# require 'cgi'

# cgi = CGI.new('html3')
input = File.read('test/tricky.xml')#STDIN.gets
content_type = input.split[input.split.index("Content-Type:") + 1]

content_headers = input.split("\n\n")[0]

if content_type == "text/xml"
  ruby_hash = XmlSimple.xml_in(input).sort
elsif content_type == "application/json"
  ruby_hash = JSON.parse(input.split("\n\n")[1]).sort
else raise "Input not in application/json or text/xml format."
end

class Object
  def to_html
    self.to_s.to_html
  end
end

class Hash
  def to_html
    self.inject("") { |r,e| 
      r += "<h3>#{e[0]}:</h3>" + "<ul>" + e[1].to_html + "</ul>"
    }
  end
end

class Array
  def to_html
    self.inject("") { |r,e|
      r += "<li>" + e.to_html + "</li>"
    }
  end
end

class String
  def to_html
    "<li>" + self + "</li>"
  end
end


STDOUT.puts( content_headers.split("\n").inject(""){|r,e| r += "<p>#{e}</p>"} + ruby_hash.to_html )

# cgi.out {
#   cgi.html {
#     cgi.body {
#         content_headers.split("\n").inject(""){|r,e| r += "<p>#{e}</p>"} + ruby_hash.to_html
#     }
#   }
# }

# 3 line echo server
#server = TCPServer.new('127.0.0.1', '8080')
#socket = server.accept

#while true
  #Json hash looks like { "key" : "val" }
#  json_hash = socket.readline
#  ruby_hash = { json_hash.split("\"")[1] => json_hash.split("\"")[3] }

  #Use CGI to create an HTML file and
  #socket.puts html_file
#end
