class Source
  include DataMapper::Resource

  property :id,          Serial
  property :filename,    FilePath
  property :mtime,       DateTime
  property :filesize,    Integer

  def self.by_date date
    Source.all.detect{|s| s.filename.to_s.include?(date)}
  end
end

