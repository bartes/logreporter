class Result
  include DataMapper::Resource

  def self.default_repository_name
    :external
  end

  property :id,        Serial
  belongs_to :source,   :unique => true
  property :data,      Json
  property :month,     Integer
  property :year,      Integer
  property :day,       Integer


  def self.store(obj)
    r = first(:source_id => obj.source.id) || Result.new( :source => obj.source)
    r.data = obj.data.marshal_dump.to_json
    r.year = obj.day_date.year
    r.month = obj.day_date.month
    r.day = obj.day_date.day
    r.save
  end

  def self.grouped_results
    repository(:external).adapter.select("SELECT * from results group by year, month, day")
  end

end
