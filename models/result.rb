class Result
  include DataMapper::Resource

  def self.default_repository_name
    :external
  end

  property :id,        Serial
  belongs_to :source,   :unique => true
  property :data,      Json

  def self.store(obj)
    r = first(:source_id => obj.source.id) || Result.new( :source => obj.source)
    r.data = obj.data.marshal_dump.to_json
    r.save
  end
end
