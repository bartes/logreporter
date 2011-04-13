class Manager

  @@day_date = nil

  def parse!

  end

  def generate
    template = File.read(File.expand_path('../views/report.haml'))
    haml_engine = Haml::Engine.new(template)
    output = haml_engine.render(:total_lines => 0, :per_hour => 0)
  end

  def self.set_date(date=nil)
    #date format: rrrr-mm-dd
    if date
      splited_date = date.split('-')
      year = splited_date[0]
      month = splited_date[1]
      day = splited_date[2]
      @@day_date = Time.new(year,month,day)
    else
      yesterday = Time.now - (24 * 60 * 60)
      @@day_date = Time.new(yesterday.year, yesterday.month, yesterday.day)
    end
  end

  def self.day_date
    @@day_date
  end

end
