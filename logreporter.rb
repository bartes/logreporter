require 'rubygems'
require 'datamapper'
require 'fileutils'
#require 'chilkat'
FileUtils.mkdir_p 'outputs'
FileUtils.mkdir_p 'tar'
# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)
DataMapper::Property::String.length(255)
DataMapper::Property.required(false)
DataMapper::Property.auto_validation(false)

# A Sqlite3 connection to a persistent database
DataMapper.setup(:default, "sqlite://#{File.expand_path("logs.db")}")
DataMapper.setup(:external, "sqlite://#{File.expand_path("results.db")}")

require File.expand_path("models/hasher", File.dirname(__FILE__))
require File.expand_path("models/sql_builder", File.dirname(__FILE__))
require File.expand_path("models/processing_line", File.dirname(__FILE__))
require File.expand_path("models/completed_line", File.dirname(__FILE__))
require File.expand_path("models/started_line", File.dirname(__FILE__))
require File.expand_path("models/request", File.dirname(__FILE__))
require File.expand_path("models/source", File.dirname(__FILE__))
require File.expand_path("models/daily_manager_core", File.dirname(__FILE__))
require File.expand_path("models/daily_manager_api", File.dirname(__FILE__))
require File.expand_path("models/daily_manager_site", File.dirname(__FILE__))
require File.expand_path("models/daily_manager", File.dirname(__FILE__))
require File.expand_path("models/manager", File.dirname(__FILE__))
require File.expand_path("models/result", File.dirname(__FILE__))
require File.expand_path("models/release", File.dirname(__FILE__))

Result.auto_upgrade!
Release.auto_upgrade!
DataMapper.finalize
