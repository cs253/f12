#!/usr/bin/env ruby

require 'test/unit'
require './HttpRequest'

class HttpRequestTests < Test::Unit::TestCase
    #map input => [path, args]
    @@cases = { 
        'http://foo.com/path?arg1=val1'=> # test 1 path/arg
            ['/path',
            {'arg1' => 'val1'} ],
        'http://bar.com'=> # test no path/args
            ['/',
            {} ],
        'http://gaz.com/path/sub?arg1=val1&arg2=val2' => # multi path/args
            ['/path/sub',
            {'arg1' => 'val1', 'arg2' => 'val2'} ],
        'http://www.bar.com?foo%20bar=bar%20foo' => # key/val pair with spaces
            ['/',
            {'foo bar' => 'bar foo'}],
        'http://www.bar.com/top//sub?key=val' =>
            ['/top//sub',
            {'key' => 'val'}],
        'http://www.bar.com/path/foo%09bar=bar%09foo' =>
            ['/path',
            {"foo\tbar" => "bar\tfoo"}],
    }

    #create tests for each case
    @@cases.each do |input, expected|
        basic_test_name = ("test_basic_" + input).to_sym
        meta_test_name = ("test_meta_" + input).to_sym

        send :define_method, basic_test_name do
            result = HttpRequest.new(input)

            assert_equal(expected[0], result.path)
            assert_equal(expected[1], result.args)

        end

        send :define_method, meta_test_name do
            result = HttpRequest.new(input)

            expected[1].each{|arg, val|
                method_name = arg.split().join('_')
                assert_equal(
                    val,
                    result.send(method_name)
                )
            }
        end
    end
end
