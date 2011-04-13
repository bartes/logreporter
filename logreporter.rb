require 'rubygems'
require 'datamapper'
# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# A Sqlite3 connection to a persistent database
DataMapper.setup(:default, 'sqlite://sayso-osx.db')
require File.expand_path("models/processing_line", File.dirname(__FILE__))
require File.expand_path("models/completed_line", File.dirname(__FILE__))
require File.expand_path("models/request", File.dirname(__FILE__))
require File.expand_path("models/source", File.dirname(__FILE__))
DataMapper.finalize
