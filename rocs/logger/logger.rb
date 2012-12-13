# Singleton logger.
# Written by Julian Lunger for CSC 253 -- rocs project.

=begin
	How to use:
	require "./logger.rb"
	l = Logger.instance
	l.info "The logger is starting up."
	l.warn "The logger is getting tired."
	l.error "The logger has fallen asleep."
	l.info "The logger has woken again."
=end

class Logger
	def initialize
		@logFile = "changeme.log"
		@configAlreadySet = false
	end

	def setConfig(config)
		if @configAlreadySet
			@@instance.warn "Config already set-- cannot be set a second time, ignoring."
			return
		end

		@logFile = config.config["config_file"]
		@configAlreadySet = true
	end
	
	def error(string)
		log("error", string)
	end

	def warn(string)
		log("warn", string)
	end

	def info(string)
		log("info", string)
	end

	def log(type, string)
		line = getPrefix(type) + string
		writeToFile(line)
	end
		
	def getPrefix(type)
		time = Time.new.strftime("%m/%d/%y %H:%M:%S")
		return "#{type}:#{time}> "
	end

	def writeToFile(string)
		File.open(@logFile, 'a') do |log|
			log.puts string
		end
	end

	@@instance = Logger.new

	def self.instance
		return @@instance
	end

	private_class_method :new
end
