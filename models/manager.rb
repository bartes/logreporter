require "haml"
require "ostruct"

class Manager
  attr_accessor :day_date, :data, :source

  def initialize(date)
    set_date(date)
    self.data = OpenStruct.new
    self.source = Source.get_source(day_date)
  end

  def run!
    parse
    save_to_file(generate)
    store
    true
  end

  def save_to_file(result)
    File.open('outputs/output.html', 'w') {|f| f.write(result) }
  end

  def store
    Result.store(self)
  end

  def parse
    data.no_of_requests = ProcessingLine.count_for(source)
    data.most_requested = ProcessingLine.most_requested(source)
    [:duration, :view, :db].each do |i|
       data.send :"#{i}_total=", CompletedLine.total_for(i, source)
       data.send :"#{i}_average=", CompletedLine.average_for(i, source)
       data.send :"#{i}_longest_by_avg=", CompletedLine.longest(i, :average, source)
       data.send :"#{i}_longest_by_sum=", CompletedLine.longest(i, :sum, source)
    end
    data.blockers = CompletedLine.blockers(source).map{|i|
      i[:total_hits] = ProcessingLine.count_for_action(i, source)
      i[:percentage] = (i.duration_hits * 100 / i.total_hits).round
      i
    }
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
