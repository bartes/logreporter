require 'rubygems'
require 'data_mapper'
# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# A Sqlite3 connection to a persistent database
DataMapper.setup(:default, 'sqlite://sayso-osx.db')
DataMapper.finalize
