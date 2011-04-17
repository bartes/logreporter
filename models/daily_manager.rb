require "haml"
require "ostruct"

class DailyManager
  attr_accessor :day_date, :data, :source

  TOP = [
    {:controller => "PlacesController", :action => "show", :format => "HTML"},
    {:controller => "CitiesController", :action => "show", :format => "HTML"},
    {:controller => "CategoriesController", :action => "show", :format => "HTML"},
    {:controller => "ReviewsController", :action => "show", :format => "HTML"},
    {:controller => "HomeController", :action => "index", :format => "HTML"},
    {:controller => "Api1::PlacesController", :action => "search", :format => nil},
    {:controller => "PlacesController", :action => "search", :format => "HTML"},
  ]
  TOP_WITH_ALL = TOP + [{:controller => nil, :action => nil, :format => nil}]
  def initialize(date)
    set_date(date)
    self.data = OpenStruct.new
    self.source = Source.get_source(day_date)
  end

  def preload
    self.data = source.result.parsed_data
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

  def save_to_file(result)
    File.open("outputs/#{Source.parse_time(day_date)}.html", 'w') {|f| f.write(result) }
  end

  def store
    Result.store(self)
  end

  def parse
    data.no_of_requests = ProcessingLine.count_for(source)
    data.date = day_date
    data.most_requested = ProcessingLine.most_requested(source)
    [:duration, :view, :db].each do |i|
       data.send :"#{i}_total=", CompletedLine.total_for(i, source)
       data.send :"#{i}_average=", CompletedLine.average_for(i, source)
       data.send :"#{i}_longest_by_avg=", CompletedLine.longest(i, :average, source)
       data.send :"#{i}_longest_by_sum=", CompletedLine.longest(i, :sum, source)
    end
    data.blockers = CompletedLine.blockers(source).map{|i|
      i[:total_hits] = ProcessingLine.count_for_action(i, source)
      i[:percentage] = (i[:duration_hits] * 100 / i[:total_hits]).round
      i
    }
    data.blocker_requests = CompletedLine.blocker_requests(source)
    data.top_actions = self.class::TOP.inject([]) do |sum, options|
      sum << {:action => options, :results => CompletedLine.top_actions(source, options)}
      sum
    end
    data.top_actions_distribution = self.class::TOP_WITH_ALL.inject([]) do |sum, options|
      sum << {:action => options, :results => CompletedLine.top_actions_distribution(source, options)}
      sum
    end
  end

  def generate
    template = File.read(File.expand_path('views/report.haml'))
    haml_engine = Haml::Engine.new(template)
    haml_engine.render(data)
  end

  def set_date(date = nil)
    if date && date.is_a?(Time)
      self.day_date = date
    else
      splited_date = date.split('-')
      year = splited_date[0]
      month = splited_date[1]
      day = splited_date[2]
      self.day_date =  Time.new(year,month,day, 0, 0 ,0 )
    end
  end

end
