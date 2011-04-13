class Source
  include DataMapper::Resource

  property :id,          Serial
  property :filename,    FilePath
  property :mtime,       DateTime
  property :filesize,    Integer
end

