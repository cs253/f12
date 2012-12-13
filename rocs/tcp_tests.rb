# Tests for TCPServer class
#
# Author: Willie Reed

require 'tcpserver'
require 'test/unit'
require 'HttpServer' # replace with real file name

class TCPTest < Test::Unit::TestCase

    def setup
        @server = TCPServer.new(HttpServer.new()) # replace with real HttpServer constructor
    end

    def test_new
        assert_not_nil @server
        assert_not_nil @server.http
    end

    def test_start
        assert @server.start == @server.start  # replace this with what the @server.start should return
    end

    def test_connect
        # connect to server...how do I find the location?
        # check to see the connection is made
    end

    def test_response
        # connect to server
        # send data to server
        # listen for respons
        # confirm I get one
        # make sure it's not nil
        # Can't really do more without testing the functionality of the other components
        #       This would make this not a good unit test
    end

end
