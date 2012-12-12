require 'open3'
class HttpServer
    attr_accessor :host
    attr_accessor :port
    attr_accessor :cgi_bin_path
    cgi_bin_path="cgi_bin"
    def process( request )
        # invoke the script in cgi_bin_path
        # pass in the parameters as a hashtable
        # return the results of the script
        stdin,stdout,stderr,wait_thr=Open3.popen3("ruby #{cgi_bin_path}/#{request.path} #{request.args}")
        stdin.close
        wait_thr.join
        response=stdout.read
        error=stderr.read
        stdout.close
        stderr.close
        if error!=""
            @log.error(error)
            return error
        else
            return response
        end
        # passing parameters as a hastable makes 
        # no sense, but it is what the specs say 
        #to do.
    end

    def start
        # does this actualy serve a purpouse?
        # the specs never say that anything 
        # should be done with the tcp server
        # only that TCPServ should call HTTPServ
        # and then have the results returned.
        tcp = TcpServer.new( self )
        tcp.start
    end
    def initialize
        # is it really this simple?
        # it seems like it shouldnt be but is.
        yield self
        @log=Logger.new()
    end
end

class Logger
    def warn(str)
    end
    def info(str)
    end
    def error(str)
        print "we have an error\n"
    end
end
class TcpServer
    def initialize (httpserv)
    end
    def start
    end
end

class Request
    attr_accessor :path
    attr_accessor :args
end

server = HttpServer.new { |s|
  s.host = "localhost"
  s.port = 8000
  s.cgi_bin_path = "cgi_bin"
}

req=Request.new()
req.path="test.rb"
req.args=Hash.new()

server.start
print server.process(req)

