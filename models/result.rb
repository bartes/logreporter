class Result
  include DataMapper::Resource

  def self.default_repository_name
    :external
  end

  property :id,        Serial
  belongs_to :source,   :unique => true
  property :data,      Json
end
