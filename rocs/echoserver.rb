# Design:
# (1) Accept STDIN as hash in JSon format
# (2) Convert the JSon format hash to a ruby hash
# (3) Create html using CGI to display the information in the hash
# (4) Return an html as string through STDOUT

require 'rubygems'
require 'json'
require 'cgi'

cgi = CGI.new('html3')
json_hash = STDIN.gets
ruby_hash = JSON.parse(json_hash).sort

#Use CGI to create and HTML string and
cgi.out {
  cgi.html {
    cgi.body {
      ruby_hash.inject("") { |r,e|
        r += "<h3>#{e[0]}:</h3>" \
             + "<ol>" \
             + e[1].inject("") { |r,e| r += "<li>#{e}</li>" } \
             + "</ol>"
      }
    }
  }
}



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
