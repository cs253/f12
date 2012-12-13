
require 'json'
#require 'nokogiri'
require 'stringio'
require 'uri'
require 'webrick'
require 'webrick/httputils'
require 'webrick/httprequest'
require 'webrick/https'
require 'xmlsimple'

class HttpRequest
    attr_reader :type
    attr_reader :path
    attr_reader :header
    attr_reader :query
    attr_reader :body

    def initialize(request_str)
        # spoof a socket read on the request string
        request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
        socket_spoof = StringIO.open(request_str)
        request.parse(socket_spoof)
        # grab HTTP request parameters
        @type = request.request_method
        @path = request.path
        @header = request.header
        @query = request.query
        @body = request.body.nil? ? {} : parse_body(request.body)
    end

    def method_missing(method, *args, &block)
        name = method.to_s
        # handle regular name and safe name
        parameter = name =~ /^arg_/ ? name[4..name.size] : name
        case @type
        when "GET"
            return @query[parameter]
        when "POST"
            return @body[parameter]
        else
            super(method, *args, &block)
        end
    end

    private

    def parse_body(content)
        body = {}
        # GETs will have no body, hopefully
        return body if @type == "GET"
        case @header['content-type']
        when 'application/json'
            body = JSON.parse(content)
        when 'application/xml', 'text/xml'
            body = XmlSimple.xml_in(content, { 'KeyAttr' => 'name' })
        end
        return body
    end
end
