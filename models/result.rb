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
    r.data = obj.data.marshal_dump
    r.year = obj.day_date.year
    r.month = obj.day_date.month
    r.day = obj.day_date.day
    r.save
  end

  def self.grouped_results
    Result.all(:order => [:day]).group_by{|r| [r.year, r.month]}
  end

  def self.latest_date
    r = Result.all(:order => [:year,:month,:day]).last
    Time.new(r.year,r.month,r.day,0,0,0)
  end

end
