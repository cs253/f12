# tcpserver.rb -- TcpServer Class
# Author: Pengcheng Li <pli@cs.rochester.edu> 

require 'socket'
#require 'config'
require './logger/logger.rb'

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

  class TcpServer
    attr_reader :status, :config, :logger, :listeners
    attr_accessor :http, :sock

    def initialize(http, config=Config::General)
      @config = config.config
      @http = http
      @status = :Stop
      @config[:Logger] ||= Logger.instance
      @logger = @config[:Logger]

      #create IPv4 socket only
      @sock = TCPServer.new(@config["Ip"], @config["Port"])
#      @sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
#      sockaddr = Socket.pack_sockaddr_in( @config[:Port], @config[:Ip] )
#      @sock.bind( sockaddr )
#      @sock.listen(50)
      @config["Port"] = @sock.addr[1] if @config["Port"] == 0

    end

    def write_data(sock, data)
       sock << data
    end

    def start
      raise "#{self.class} already started." if @status != :Stop
      
      @logger.info "#{self.class}#start : pid=#{$$} ip=#{@config["Ip"]} port=#{@config["Port"]}"
      @status = :Running
      while @status == :Running
        begin
          puts "listening"
              puts "have client"
              client_sock = @sock.accept
              if client_sock
                puts "#{client_sock}"
                puts "some client is coming"

                  request = client_sock.gets
                  puts "#{request}"
                  response = request
                  response = @http.process(request)
                  @logger.info(response.to_s)
                  write_data(client_sock, response)

                  client_sock.close
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
       # sock.sync = true
       # set_non_blocking(sock)
       # set_close_on_exec(sock)
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

# config = {}
# config[:Logger] = Logger.instance
# config[:Ip] = "127.0.0.1"
# config[:Port] = 2200
# config[:Timeout] = 2.0

# tcp = TcpServer.new(nil, config)
# tcp.start
