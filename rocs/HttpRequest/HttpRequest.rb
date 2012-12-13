
require 'json'
require 'nokogiri'
require 'stringio'
require 'uri'
require 'webrick'
require 'webrick/httputils'
require 'webrick/httprequest'
require 'webrick/https'

class HttpRequest
    attr_reader :type
    attr_reader :path
    attr_reader :header
    attr_reader :query
    attr_reader :body

    def initialize(request)
        # spoof a socket read on the request string
        req_spoof = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
        StringIO.open(request) { |socket| req_spoof.parse(socket) }
        # grab HTTP request parameters
        @type = req_spoof.request_method
        @path = req_spoof.path
        @header = req_spoof.header
        @query = req_spoof.query.nil? or req_spoof.query.empty? ? {} : parse_args(req_spoof.query)
        @body = req_spoof.body.nil? ? {} : parse_body(req_spoof.body)
    end

    def method_missing(method, *args, &block)
        name = method.to_s
        # handle regular name and safe name
        parameter_type = name =~ /^arg_/ ? :query : (name =~ /^body_/ ? :body : nil)
        case parameter_type
        when :query
            parameter = name[0..3]
            return @query[parameter]
        when :body
            parameter = name[0..4]
            return @body[parameter]
        else
            super
        end
    end

    private

    def parse_args(query_str)
        args = {}
        # split on mappings
        query_str.split(/&/).each do |param|
            # extract mapping from substring
            if param.index('=').nil? then
                raise ArgumentError, "mapping is missing = operator: \"#{param}\""
            end
            key, value = *param.split(/\=/)
            if key == '' or value == '' then
                raise ArgumentError, "query string contained invalid mapping: \"#{key}=#{value}\""
            end
            key.gsub!(/\s+/, " ")
            args[key] = value
        end
        return args
    end

    def parse_body(content)
        body = {}
        # GETs will have no body, hopefully
        return body if @type == "GET"
        case @header['content-type']
        when 'application/json'
            body = JSON.parse(content)
        when 'application/xml', 'text/xml'
            body = Hash.from_xml(Nokogiri::XML.parse(content))
        end
        return body
    end
end
