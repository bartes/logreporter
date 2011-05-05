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

  def add_release
    raise "no date specified" if date.nil?
    Release.add_if_missing(DailyManagerCore.get_date(date))
    run!(true)
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
    data.releases = Release.all(:order => [:year.asc, :month.asc, :day.asc])
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

  def self.clear_invalid_requests
    repository(:default).adapter.execute("DELETE FROM requests WHERE id IN
                                          (SELECT r.id FROM requests r LEFT JOIN processing_lines p ON r.id = p.request_id WHERE p.source_id IS NULL);")
  end

  def generate_tar_file
    File.open(File.expand_path("tar/logreporter-summary.tar"), 'wb') { |tar| Archive::Tar::Minitar.pack('outputs', tar) }
    `gzip -f tar/logreporter-summary.tar`
  end
end
