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
        if self.body
            enc_body = @@content_encoders[self.content_type].call(self.body)
        end

        lines << "#{self.method} #{URI.encode(self.path) + enc_q} HTTP/1.0"
        lines << "Content-Type: #{self.content_type}"
        lines << "Content-Length: #{enc_body ? enc_body.size : 0}"
        lines << ""
        if enc_body
            lines << "#{enc_body}"
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
        SampleRequest.new('get with complex args',
                          'GET', 'application/json',
                          '/path', {'key key' => 'val val', 'bar' => 'gaz'},
                          nil),
        SampleRequest.new('get no args',
                          'GET', 'application/json',
                          '/path/sub', {},
                          nil),
        SampleRequest.new('post json with args',
                          'POST', 'application/json',
                          '/path', {},
                          {'data' => 'this is the body'}),
    ]

    #create tests for each case
    @@cases.each do |sample|
        comment = sample.comment
        http = sample.to_http

        basic_test_name = ("test_basic_" + comment).to_sym
        meta_test_name = ("test_meta_" + comment).to_sym

        send :define_method, basic_test_name do
            result = HttpRequest.new(http)

            assert_equal(sample.path, result.path, http)
            assert_equal(sample.query, result.query, http)
        end

        send :define_method, meta_test_name do
            result = HttpRequest.new(http)

            sample.query.each{|arg, val|
                method_name = arg
                #method_name = arg.split().join('_')
                assert_equal(
                    val,
                    result.send(method_name)
                )
            }
        end
    end
end
