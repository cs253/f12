#!/usr/bin/env ruby

require 'test/unit'

require 'json'
require 'uri'

require './HttpRequest'


class SampleRequest < Struct.new("SampleRequest", :comment, :method, :content_type, :path, :query, :body)
    @@content_encoders = {
        'application/json' => lambda{|x| x.to_json}
    }

    def to_http
        lines = []

        enc_q = '?' + URI.encode_www_form(self.query)
        if self.method == 'POST'
            encoded_body = @@content_encoders[self.content_type].call(self.body)
        end

        lines << "#{self.method} #{URI.encode(self.path) + enc_q} HTTP/1.0"
        lines << "Content-Type: #{self.content_type}"
        lines << "Content-Length: #{encoded_body ? encoded_body.size : 0}"
        lines << ""
        if self.method == 'POST'
            lines << "#{encoded_body}"
            lines << ""
        end

        lines.join("\n")
    end

    ##eg:
    #POST /path/script.cgi HTTP/1.0
    #From: frog@jmarshall.com
    #User-Agent: HTTPTool/1.0
    #Content-Type: application/x-www-form-urlencoded
    #Content-Length: 32

    #home=Cosby&favorite+flavor=flies
end


class HttpRequestTests < Test::Unit::TestCase
    @@cases = [
        SampleRequest.new('get with args',
                          'GET', 'application/json',
                          '/path', {'key' => 'val'},
                          nil),
        SampleRequest.new('post json with args',
                          'POST', 'application/json',
                          '/path', {'key' => 'val'},
                          {'data' => 'this is the body'}),
    ]
    p @@cases[0]

    #
    #map input => [headers, path, args]
    #@@cases = { 
    #    'http://foo.com/path?arg1=val1'=> # test 1 path/arg
    #        ['/path',
    #        {'arg1' => 'val1'} ],
    #    'http://bar.com'=> # test no path/args
    #        ['/',
    #        {} ],
    #    'http://gaz.com/path/sub?arg1=val1&arg2=val2' => # multi path/args
    #        ['/path/sub',
    #        {'arg1' => 'val1', 'arg2' => 'val2'} ],
    #    'http://www.bar.com?foo%20bar=bar%20foo' => # key/val pair with spaces
    #        ['/',
    #        {'foo bar' => 'bar foo'}],
    #    'http://www.bar.com/top//sub?key=val' =>
    #        ['/top//sub',
    #        {'key' => 'val'}],
    #    'http://www.bar.com/path?foo%09bar=bar%09foo' =>
    #        ['/path',
    #        {"foo bar" => "bar\tfoo"}],
    #}

    #create tests for each case
    @@cases.each do |sample|
        comment = sample.comment
        http = sample.to_http

        basic_test_name = ("test_basic_" + comment).to_sym
        #meta_test_name = ("test_meta_" + comment).to_sym

        send :define_method, basic_test_name do
            result = HttpRequest.new(http)

            assert_equal(sample.path, result.path, http)
            assert_equal(sample.query, result.query, http)
        end

        #send :define_method, meta_test_name do
        #    result = HttpRequest.new(input)

        #    expected[1].each{|arg, val|
        #        method_name = arg.split().join('_')
        #        assert_equal(
        #            val,
        #            result.send(method_name)
        #        )
        #    }
        #end
    end
end
