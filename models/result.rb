class Result
  include DataMapper::Resource

  def self.default_repository_name
    :external
  end

  property :id,        Serial
  belongs_to :source,   :unique => true
  property :data_api,  Json
  property :data_site,  Json
  property :month,     Integer
  property :year,      Integer
  property :day,       Integer


  def self.store(obj, kind)
    r = first(:source_id => obj.source.id) || Result.new( :source => obj.source)
    r.send(:"data_#{kind}=", obj.data.marshal_dump)
    r.year = obj.date.year
    r.month = obj.date.month
    r.day = obj.date.day
    r.save
  end

  def self.grouped_results
    Result.all(:order => [:year, :month, :day]).group_by{|r| [r.year, r.month]}
  end

  def self.latest_date
    r = Result.all(:order => [:year,:month,:day]).last
    Time.new(r.year,r.month,r.day,0,0,0)
  end

  def parsed_data(col)
    result = OpenStruct.new(send(:"data_#{col}"))
    result.date = Time.parse(result.date)
    result
  end
end
