require_relative 'server'
class RawEchoServer
  attr_accessor :host
  attr_accessor :port
  def process(request)
    request
  end
  def start
    tcp = TCPserver.new(self)
    tcp.start
  end
  def initialize
    @port = 8080
    yield self
  end
end

# Start a server if run as a script
if $0 = __FILE__
  RawEchoServer.new.start
end
