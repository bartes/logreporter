require "haml"
require "ostruct"

class Manager

  attr_accessor :data

  def initialize
    self.data = OpenStruct.new
  end

  def run!
    parse
    save_to_file(generate)
    puts generate
    true
  end

  def save_to_file(result)
    File.open('outputs/index.html', 'w') {|f| f.write(result) }
  end

  def parse
    data.daily_items = Result.grouped_results
  end

  def generate
    template = File.read(File.expand_path('views/index.haml'))
    haml_engine = Haml::Engine.new(template)
    haml_engine.render(data)
  end
end
