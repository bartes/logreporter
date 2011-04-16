class StartedLine

  include DataMapper::Resource
  #only for rails 3.x
  property :id,          Serial
  belongs_to :request
  belongs_to :source
  property :lineno,      Integer
  property :method,      String
  property :timestamp,   Integer
  property :ip,          IPAddress
  property :path,       URI
end
