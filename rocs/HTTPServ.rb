class HttpServer
    #to be removed or changed once we have a config file reader
    cgi_bin_path="cgi_bin/"
    def process( request )
        # invoke the script in cgi_bin_path
        # pass in the parameters as a hashtable
        # return the results of the script
        return %x(#{request.path} #{request.args})
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
    def new
        # is it really this simple?
        # it seems like it shouldnt be but is.
        yield self
    end
end

server = HttpServer.new { |s|
  s.host = "localhost"
  s.port = 8000
  s.cgi_bin_path = "galaxy/faraway"
}

server.start
