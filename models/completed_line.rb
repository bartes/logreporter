class CompletedLine
  include DataMapper::Resource

  property :id,          Serial
  property :request_id,  Integer
  property :source_id,   Integer
  property :lineno,      Integer
  property :duration,    Float
  property :view,        Float
  property :db,          Float
  property :status,      Integer
  property :url,         String
end
