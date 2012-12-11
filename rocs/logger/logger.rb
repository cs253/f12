class Logger
	def initialize
		@logFile = "changeme.log"
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

l = Logger.instance
l.info "The logger is starting up."
sleep 1
l.warn "The logger is getting tired."
sleep 1
l.error "The logger has fallen asleep."
sleep 1
l.info "The logger has woken again."
