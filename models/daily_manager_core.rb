require "haml"
require "ostruct"

class DailyManagerCore
  attr_accessor :date, :data, :source

  def initialize(date)
    self.date = self.class.get_date(date)
    self.data = OpenStruct.new
    self.source = Source.get_source(self.date)
  end

  def run!(with_preload = false)
    puts "Preload : #{with_preload}"
    if with_preload && source.result
      preload
    else
      parse
      store
    end
    save_to_file(generate)
    true
  end

  def preload
    self.data = source.result.parsed_data(name)
  end

  def save_to_file(result)
    File.open("outputs/#{Source.parse_time(date)}_#{name}.html", 'w') {|f| f.write(result) }
  end

  def store
    Result.store(self, name)
  end

  def parse
    data.no_of_requests ||= ProcessingLine.count_for(source, self.class::OPTIONS)
    data.most_requested ||= ProcessingLine.most_requested(source, self.class::OPTIONS)
    [:duration, :view, :db].each do |i|
       data.send :"#{i}_total=", CompletedLine.total_for(i, source, self.class::OPTIONS) if data.send(:"#{i}_total").nil?
       data.send :"#{i}_average=", CompletedLine.average_for(i, source, self.class::OPTIONS) if data.send(:"#{i}_average").nil?
       data.send :"#{i}_longest_by_avg=", CompletedLine.longest(i, :average, source, self.class::OPTIONS) if data.send(:"#{i}_longest_by_avg").nil?
       data.send :"#{i}_longest_by_sum=", CompletedLine.longest(i, :sum, source, self.class::OPTIONS) if data.send(:"#{i}_longest_by_suml").nil?
    end
    data.blockers ||= CompletedLine.blockers(source, self.class::OPTIONS).map{|i|
      i['total_hits'] = ProcessingLine.count_for_action(i, source)
      i['percentage'] = (i['duration_hits'] * 100 / i['total_hits']).round
      i
    }
    data.blocker_requests ||= CompletedLine.blocker_requests(source)
    data.top_actions ||= self.class::TOP.inject([]) do |sum, options|
      sum << {'action' => Hasher.stringify_keys(options), 'results' => CompletedLine.top_actions(source, options, self.class::OPTIONS)}
      sum
    end
    data.top_actions_distribution ||= self.class::TOP_WITH_ALL.inject([]) do |sum, options|
      sum << {'action' => Hasher.stringify_keys(options), 'results' => CompletedLine.top_actions_distribution(source, options, self.class::OPTIONS)}
      sum
    end
    data.date = date
    true
  end

  def generate
    template = File.read(File.expand_path("views/report_#{name}.haml"))
    haml_engine = Haml::Engine.new(template)
    haml_engine.render(data)
  end

  def self.get_date(date = nil)
    if date && date.is_a?(Time)
      date
    else
      splited_date = date.split('-')
      year = splited_date[0]
      month = splited_date[1]
      day = splited_date[2]
      Time.new(year,month,day, 0, 0 ,0 )
    end
  end

end
