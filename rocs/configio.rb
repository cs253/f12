require 'yaml'
require 'singleton'

class ConfigIO
    include Singleton

    attr_reader :config

    def [](key)
        @config[key]
    end

    def []=(key, value)
        @config[key] = value
    end

    def initialize
        @default = {log_file: "server.log"}
        #TODO someone needs to fill in the default config
        @config = Hash.new
    end

    def unify_default
        @default.each{ |k,v|
            @config[k] = v if not @config.key? k
            @config[k] = v if @config[k] = nil
        }
        @config
    end

    def write
        File.open("config.yml", "w") { |f| f.write(@config.to_yaml)}
    end

    def read(file)
        raw_config = YAML.load_file(file)
        raw_config.each{ |k, v|
           @config[k] = v
        }
        unify_default
    end
end
