#
# tcpserver.rb -- TcpServer Class
#
# Author: Pengcheng Li <pli@cs.rochester.edu> 
#

require 'socket'
#require 'config'
require './logger.rb'

#module MicroServer

# under the assumptions of the following interfaces
=begin
config = {} 
  :Logger => 
  :Ip
  :Port
  :MaxConns
  :Timeout
=end

=begin
logger
  info
  warn
  error
=end

=begin
HttpRequest 
  request = HttpRequest.parse(socket)
=end

=begin
HttpServer
  process(request)
=end

include Socket::Constants
  class TcpServer
    attr_reader :status, :config, :logger, :listeners
    attr_accessor :http, :sock

    def initialize(http, config=Config::General)
      @config = config
      @http = http
      @status = :Stop
      @config[:Logger] ||= Log::new
      @logger = @config[:Logger]

      #create IPv4 socket only
      @sock = TCPServer.new(@config[:Ip], @config[:Port])
#      @sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
#      sockaddr = Socket.pack_sockaddr_in( @config[:Port], @config[:Ip] )
#      @sock.bind( sockaddr )
#      @sock.listen(50)
      @config[:Port] = @sock.addr[1] if @config[:Port] == 0

    end

    def write_data(sock, data)
       sock << data
    end

    def start
      raise "#{self.class} already started." if @status != :Stop
      
      @logger.info "#{self.class}#start : pid=#{$$} ip=#{@config[:Ip]} port=#{@config[:Port]}"
      @status = :Running
      while @status == :Running
        begin
          @logger.warn "listening"
          if clients = IO.select([@sock], nil, nil, @config[:Timeout])
            clients.each{ |client|
              if client_sock = accept_client(@sock) 
               # client_sock = @sock.accept
                begin
                  begin
                    addr = client_sock.peeraddr
                    @logger.warn "accept: #{addr[3]}:#{addr[1]}"
                  rescue SocketError
                    @logger.warn "accept: <address unknown>"
                 #  raise
                  end

                  #request = HttpRequest.parse(client_sock)
                  #request = client_sock.recvfrom(1024)[0]
                  request = client_sock.gets
                  puts "#{request}"
                  response = request
                 # response = @http.process(request) 
                  write_data(client_sock, response)

                rescue Errno::ENOTCONN
                  @logger.warn "Errno::ENOTCONN raised"
                rescue Exception => ex
                  @logger.error ex
                ensure
                  if addr
                    @logger.warn "close: #{addr[3]}:#{addr[1]}"
                  else
                    @logger.warn "close: <address unknown>"
                  end
                  client_sock.close
                end
              end   
            }
          end

        rescue Errno::EBADF, IOError => ex
          # if the listening socket was closed in TcpServer#shutdown,
          # IO::select raise it.
        rescue Exception => ex
          msg = "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
          @logger.error msg
        end 
      end

      @logger.info "going to shutdown ..."
      @logger.info "#{self.class}#start done."
      @status = :Stop

    end

    def stop
      if @status == :Running
        @status = :Shutdown
      end
    end

    def close
      stop
      if @logger.warn?
        addr = sock.addr
        @logger.warn("close TCPSocket(#{addr[2]}, #{addr[1]})")
      end
      sock.close
    end

    def shutdown
      stop
      if @logger.warn?
        addr = sock.addr
        @logger.warn("shutdown TCPSocket(#{addr[2]}, #{addr[1]})")
      end
      begin
        sock.shutdown
      rescue Errno::ENOTCONN
        # when `Errno::ENOTCONN: Socket is not connected' on some platforms,
        # call #close instead of #shutdown.
        sock.close
        if @logger.warn?
          addr = sock.addr
          @logger.warn("actually close TCPSocket(#{addr[2]}, #{addr[1]})")
        end
      end
    end

    private

    def accept_client(svr)
      sock = nil
      begin
        sock = svr.accept
      #  sock.sync = true
      #  set_non_blocking(sock)
      #  set_close_on_exec(sock)
      rescue Errno::ECONNRESET, Errno::ECONNABORTED,
             Errno::EPROTO, Errno::EINVAL => ex
      rescue Exception => ex
        msg = "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
        @logger.error msg
      end
      return sock
    end

    def set_non_blocking(io)
      flag = File::NONBLOCK
      if defined?(Fcntl::F_GETFL)
        flag |= io.fcntl(Fcntl::F_GETFL)
      end
      io.fcntl(Fcntl::F_SETFL, flag)
    end
    
    def set_close_on_exec(io)
      if defined?(Fcntl::FD_CLOEXEC)
        io.fcntl(Fcntl::FD_CLOEXEC, 1)
      end
    end

  end #end TcpServer
#end #end module

config = {}
config[:Logger] = Logger.instance
config[:Ip] = "127.0.0.1"
config[:Port] = 8080
config[:Timeout] = 2.0

tcp = TcpServer.new(nil, config)
tcp.start
