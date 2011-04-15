require "haml"
require "ostruct"
require 'archive/tar/minitar'

class Manager

  attr_accessor :data, :date, :all, :new

  def initialize(opt)
    self.date = opt[:date]
    self.all = opt[:all]=='1' ? true : false
    self.new = opt[:only_new]=='1' ? true : false
    puts self.inspect
    self.data = OpenStruct.new
  end

  def run!
    generate_daily_items
    parse
    save_to_file(generate)
    generate_tar_file
    true
  end

  def save_to_file(result)
    File.open('outputs/index.html', 'w') {|f| f.write(result) }
  end

  def parse
    data.items = Result.grouped_results
  end

  def generate
    template = File.read(File.expand_path('views/index.haml'))
    haml_engine = Haml::Engine.new(template)
    haml_engine.render(data)
  end

  def generate_daily_items
    return DailyManager.new(date).run! if date
    t=Time.now
    yesterday = Time.new(t.year,t.month,t.day,0,0,0) - 60*60*24
    if new
      cdate = Result.latest_date + 60*60*24
      while cdate <= yesterday
        DailyManager.new(cdate).run!
        cdate += 60*60*24
      end
    end
    if all
      days = Source.days_without_report
      days.each do |day|
        y = day[0..3]
        m = day[4..5]
        d = day[6..7]
        DailyManager.new(Time.new(y,m,d,0,0,0)).run!
      end
    end
  end

  include Archive::Tar
  def generate_tar_file
    t=Time.now
    File.open(File.expand_path("tar/logreporter-summary.tar"), 'wb') { |tar| Minitar.pack('outputs', tar) }
  end
end
