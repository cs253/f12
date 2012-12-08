# Design:
# (1) Open socket and accept
# (2) Each input is a hash in JSon format
# (3) Convert the JSon format hash to a ruby hash
# (4) Create html using CGI to display the information in the hash
# (5) Return that html to the client, though I am not sure how to
#     do that with a TCPServer...

require 'socket'
require 'cgi'

# 3 line echo server
server = TCPServer.new('127.0.0.1', '8080')
socket = server.accept

while true
  #Json hash looks like { "key" : "val" }
  json_hash = socket.readline
  ruby_hash = { json_hash.split("\"")[1] => json_hash.split("\"")[3] }

  #Use CGI to create an HTML file and
  #socket.puts html_file
end
