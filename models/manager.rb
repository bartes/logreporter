require "haml"

class Manager
  attr_accessor :day_date, :data

  def initialize(date)
    set_date(date)
    self.data = {}
  end

  def run!
    parse
    generate
  end

  def parse
    source = Source.get_source(day_date)
    data[:no_of_requests] = ProcessingLine.count_for_source(source)
    data[:most_requested] = ProcessingLine.most_requested(source)
    data[:longest] = CompletedLine.longest(source)
    [:duration, :view, :db].each do |i|
       data[:"#{i}_total"] = CompletedLine.total_for(i, source)
       data[:"#{i}_average"] = CompletedLine.average_for(i, source)
    end
  end

  def generate
    template = File.read(File.expand_path('views/report.haml'))
    haml_engine = Haml::Engine.new(template)
    haml_engine.render(data)
  end

  def set_date(date = nil)
    self.day_date = if date
      splited_date = date.split('-')
      year = splited_date[0]
      month = splited_date[1]
      day = splited_date[2]
       Time.new(year,month,day)
    else
      yesterday = Time.now - (24 * 60 * 60)
      Time.new(yesterday.year, yesterday.month, yesterday.day)
    end
  end

end
