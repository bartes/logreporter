class Request
  include DataMapper::Resource

  property :id,          Serial
  property :first_lineno,Integer
  property :last_lineno,  Integer
end
