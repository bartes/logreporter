class Release
  include DataMapper::Resource

  def self.default_repository_name
    :external
  end

  property :id,        Serial
  property :month,     Integer, :required => true
  property :year,      Integer, :required => true
  property :day,       Integer, :unique => [:year, :month], :required => true

  def date
    Time.new(year, month, day,0,0,0)
  end

  def js_date
    date.strftime("%Y %m %d")
  end

  def display_short
    date.strftime("%d.%m")
  end

  def display
    date.strftime("%D")
  end

  def self.add_if_missing(date)
    first_or_create(:year => date.year, :month => date.month, :day => date.day)
  end

end
