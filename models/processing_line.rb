class ProcessingLine
  include DataMapper::Resource

  property :id,          Serial
  belongs_to :request
  belongs_to :source
  property :lineno,      Integer
  property :controller,  String
  property :action,      String
  property :format,      String
  property :method,      String
  property :timestamp,   Integer, :key => true
  property :ip,          String


  def self.count_for_date(time)
    time = parse_time(time)
    source = Source.by_date(time)
    raise "No source found for that date" unless source
    count(:source_id => Source.by_date(time).id)
  end

  def self.parse_time(time)
    time.strftime("%Y%m%d")
  end

end


