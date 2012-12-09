class HttpRequest
    attr_reader :path
    attr_reader :args

    #eg 'example.com/somewhere?foo=foo1&bar=bar2'
    # path: 'somewhere'
    # args: {:foo => 'bar', :bar => 'bar2'}
    def initialize(request_text)
        #TODO
    end


    private

    def parse_path(request_text)
        #TODO
    end

    def parse_args(request_text)
        #TODO
    end
end
