require 'test/unit'
require '../logger/logger.rb'

class LoggerTest < Test::Unit::TestCase
	
	def clean_file
		File.open('changeme.log','w'){|file| file.truncate(0)}
	end
	
	def test_log_info
		loggerInfo = Logger.instance
		loggerInfo.info "Testing log info\n"
		assert_equal("info:"+Time.new.strftime("%m/%d/%y %H:%M:%S")+"> Testing log info\n" , File.read("changeme.log"))
		clean_file
	end
	
	def test_log_warn
		loggerWarn = Logger.instance
		loggerWarn.warn "Testing log warn\n"
		assert_equal("warn:"+Time.new.strftime("%m/%d/%y %H:%M:%S")+"> Testing log warn\n" , File.read("changeme.log"))
		clean_file
	end
	
	def test_log_error
		loggerError = Logger.instance
		loggerError.error "Testing log error\n"
		assert_equal("error:"+Time.new.strftime("%m/%d/%y %H:%M:%S")+"> Testing log error\n" , File.read("changeme.log"))
		clean_file
	end
	
end
