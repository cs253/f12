#
# tcpserver.rb -- TcpServer Class
#
# Author: Pengcheng Li <pli@cs.rochester.edu>
#

require 'socket'
#require 'config'
require 'logger'

module MicroServer

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
  debug
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
      @config = config
      @http = http
      @status = :Stop
      @config[:Logger] ||= Log::new
      @logger = @config[:Logger]

      #create IPv4 socket only
      @sock = TCPServer.new(@config[:Ip], @config[:Port])
      @config[:Port] = @sock.addr[1] if @config[:Port] == 0

    end

    def start
      raise "#{self.class} already started." if @status != :Stop

      @logger.info "#{self.class}#start : pid=#{$$} ip=#{@config[:Ip]} port=#{@config[:Port]}"
      @status = :Running
      while @status == :Running
        begin
          if clients = IO.select([@sock], nil, nil, @config[:Timeout])
            clients.each{ |client|
              if client_sock = accept_client(sock)
                begin
                  begin
                    addr = client_sock.peeraddr
                    @logger.debug "accept: #{addr[3]}:#{addr[1]}"
                  rescue SocketError
                    @logger.debug "accept: <address unknown>"
                 #  raise
                  end

                  request = HttpRequest.parse(client_sock)
                  @http.process(request)
                rescue Errno::ENOTCONN
                  @logger.debug "Errno::ENOTCONN raised"
                rescue Exception => ex
                  @logger.error ex
                ensure
                  if addr
                    @logger.debug "close: #{addr[3]}:#{addr[1]}"
                  else
                    @logger.debug "close: <address unknown>"
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
      if @logger.debug?
        addr = sock.addr
        @logger.debug("close TCPSocket(#{addr[2]}, #{addr[1]})")
      end
      sock.close
    end

    def shutdown
      stop
      if @logger.debug?
        addr = sock.addr
        @logger.debug("shutdown TCPSocket(#{addr[2]}, #{addr[1]})")
      end
      begin
        sock.shutdown
      rescue Errno::ENOTCONN
        # when `Errno::ENOTCONN: Socket is not connected' on some platforms,
        # call #close instead of #shutdown.
        sock.close
        if @logger.debug?
          addr = sock.addr
          @logger.debug("actually close TCPSocket(#{addr[2]}, #{addr[1]})")
        end
      end
    end

    private

    def accept_client(svr)
      sock = nil
      begin
        sock = svr.accept
        sock.sync = true
        set_non_blocking(sock)
        set_close_on_exec(sock)
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
end #end module

config = {}
config[:Logger] = logger.new
config[:Ip] = "127.0.0.1"
config[:Port] = "8080"
config[:Timeout] = 2.0

tcp = TcpServer.new(nil, config)
tcp.start
