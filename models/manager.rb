require "haml"
require "ostruct"
require 'archive/tar/minitar'

class Manager

  attr_accessor :data, :date, :all, :only_new

  def initialize(opt)
    self.date = opt[:date]
    self.all = opt[:all].to_s=='true' ? true : false
    self.only_new = opt[:only_new].to_s=='true' ? true : false
    puts self.inspect
    self.data = OpenStruct.new
  end

  def run!(with_preload = false)
    generate_daily_items(with_preload)
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

  def generate_daily_items(with_preload = false)
    return DailyManager.new(date).run!(with_preload) if date
    if only_new
      days = Source.days_without_report
    elsif all
      days = Source.days
    end
    (days || []).each do |day|
      y = day[0..3]
      m = day[4..5]
      d = day[6..7]
      DailyManager.new(Time.new(y,m,d,0,0,0)).run!(with_preload)
    end
  end

  include Archive::Tar
  def generate_tar_file
    File.open(File.expand_path("tar/logreporter-summary.tar"), 'wb') { |tar| Minitar.pack('outputs', tar) }
  end
end
