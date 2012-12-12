
require 'uri'

class HttpRequest
    attr_reader :path
    attr_reader :args

    def initialize(request_text)
        #TODO
        uri = URI(request_text)
        @path = uri.path
        @args = parse_args(uri.query)
    end

    private

    def parse_args(request_text)
        args = {}
        request_text.split(/&/).each do |param|
            if param.index('=').nil? then
                raise ArgumentError, "mapping is missing = operator: \"#{param}\""
            end
            key, value = *param.split(/\=/)
            if key == '' or value == '' then
                raise ArgumentError, "query string contained invalid mapping: \"#{key}=#{value}\""
            end
            args[key] = value
            method_name, safe_name = key.to_sym, "arg_#{key}".to_sym
            self.define_singleton_method(safe_name) { return @args[key] }
            if not self.class.method_defined? method_name then
                self.define_singleton_method(method_name) { return @args[key] }
            end
        end
        return args
    end
end
