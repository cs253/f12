#!/usr/bin/env ruby

require 'test/unit'
require './HttpRequest'

class HttpRequestTests < Test::Unit::TestCase
    #map input => [path, args]
    @@cases = { 
        'foo.com/path?arg1=val1'=> # test 1 path/arg
            ['/path',
            {'arg1' => 'val1'} ],
        'http://bar.com'=> # test no path/args
            ['/',
            {} ],
        'gaz.com/path/sub?arg1=val1&arg2=val2' => # multi path/args
            ['/path/sub',
            {'arg1' => 'val1', 'arg2' => 'val2'} ]
    }

    #make a test for each case
    @@cases.each do |input, expected|
        test_name = ("test_" + input).to_sym

        send :define_method, test_name do
            result = HttpRequest.new(input)

            assert_equal(expected[0], result.path)
            assert_equal(expected[1], result.args)
        end
    end
end
