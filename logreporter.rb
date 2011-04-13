require 'rubygems'
require 'datamapper'
# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)
DataMapper::Property::String.length(255)
DataMapper::Property::Boolean.allow_nil(true)
DataMapper::Property.required(false)
DataMapper::Property.auto_validation(false)

# A Sqlite3 connection to a persistent database
DataMapper.setup(:default, "sqlite://#{File.expand_path("sayso-osx.db")}")
require File.expand_path("models/processing_line", File.dirname(__FILE__))
require File.expand_path("models/completed_line", File.dirname(__FILE__))
require File.expand_path("models/request", File.dirname(__FILE__))
require File.expand_path("models/source", File.dirname(__FILE__))
DataMapper.finalize
