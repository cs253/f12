#Logger Design

## Class Design Pattern 

    module LogLevel
      WARN = 1
      INFO = 2
      DEBUG = 4
      etc...
    end
    
    (Singleton) 
    class Logger
    
    attr_accessor :path_to_logs, :debug_level, :log_level, :buffer
    
    # Logger API
    new | instance - returns a singleton instance of the logger
    log(level, string) - will queue message into buffer, print to STD_OUT if level > debug_level
    flush - write buffer to file
    config - configure the location of the log files (has defaults relative to project)
    
    # Member Functions
    initialize (config, http)- has defaults, tries config params, can also be set
   