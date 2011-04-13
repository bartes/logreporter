class ProcessingLine
  include DataMapper::Resource

  property :id,          Serial
  property :request_id,  Integer
  property :source_id,   Integer
  property :lineno,      Integer
  property :controller,  String
  property :action,      String
  property :format,      String
  property :method,      String
  property :timestamp,   Integer
  property :ip,          String
end


