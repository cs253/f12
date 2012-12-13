
require 'uri'

class HttpRequest
    attr_reader :path
    attr_reader :args

    def initialize(request_text)
        # parse URI and its query string
        uri = URI.decode_www_form(request_text)
        @path = uri.path[/\/.*/] || "/"
        @args = uri.query.nil? ? {} : parse_args(uri.query)
    end

    def method_missing(method, *args, &block)
        name = method.to_s
        # handle regular name and safe name
        param = name =~ /^arg_/ ? name[4...name.size] : name
        if @args.key? param then
            return @args[param]
        else
            super
        end
    end

    private

    def parse_args(request_text)
        args = {}
        # split on mappings
        request_text.split(/&/).each do |param|
            # extract mapping from substring
            if param.index('=').nil? then
                raise ArgumentError, "mapping is missing = operator: \"#{param}\""
            end
            key, value = *param.split(/\=/)
            if key == '' or value == '' then
                raise ArgumentError, "query string contained invalid mapping: \"#{key}=#{value}\""
            end
            args[key] = value
        end
        return args
    end
end
