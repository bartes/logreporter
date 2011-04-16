class Source
  include DataMapper::Resource

  property :id,          Serial
  property :filename,    FilePath
  property :mtime,       DateTime
  property :filesize,    Integer
  has 1,   :result, :repository => repository(:external)

  def self.by_date date
    all.detect{|s| s.filename.to_s.include?(date)}
  end

  def self.get_source(time)
    source ||= by_date(parse_time(time))
    raise "No source found for that date" unless source
    source
  end

  def self.parse_time(time)
    time.strftime("%Y%m%d")
  end

  def date
    filename.to_s.split('-').last
  end

  def self.days_without_report
    all.inject([]) do |sum, s|
      sum << s.date unless s.result
      sum
    end
  end

  def self.days
    all.map{|s| s.date}
  end
end

