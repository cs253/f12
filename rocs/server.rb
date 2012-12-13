
require 'socket'

class TCPserver

include Socket::Constants
attr_accessor :socket,:server_status,:client_status,:data
class<<self

   def initilize(*config)                            #will change the parameters
	                                             #after mixing with config
      @server_status=false
      @client_status=false
      @data = ""
   end

   def start_server(host,port)
      @socket = Socket.new( Socket::AF_INET, Socket::SOCK_STREAM, 0 )
      sockaddr = Socket.pack_sockaddr_in( port,host )
      @socket.bind( sockaddr )
      @socket.listen(50)
      @server_status=true
   end

   def msg_receive

      if @server_status == true
	  time = 5                                      #@config[:time]
	  while time>0
               break if IO.select([@socket],nil,nil,1)
	       time = 0 if @server_status == false
	       time -= 0.5
	  end
	  raise "Socket will be closed" if time <=0

          client, client_addrinfo = @socket.accept
          
          puts "accept client #{client},#{client_addrinfo}"
	  Thread.new do
		  time_client = 3
		  loop do
		      while time_client>0
  			  @data = client.recvfrom(1024)[0]
			  break if   @data!=""                 #IO.select([client],nil,nil,1) don't know why client keep recieving ""
			  p time_client -=1
			  sleep 1
	              end
		      if time_client<=0
		       client.close
		       Thread.kill
		      end
	          #if @data != ""
	          #call logger & Http request
                  puts "data recieved :#{@data}"
	          end
          end
      else raise "No active server found"
      end
end

def close_server

      @socket.close
      @server_status=false

end

end

#def httprequest
#    request=Httprequest.new(@data)
#    return request
#
#end
#def logger
#   log = Logger.new
#   log.save(client,addr,meg)    Not sure how logger works like
#end



end

TCPserver.start_server('localhost',2200)
loop do
TCPserver.msg_receive
end
TCPserver.close_server
