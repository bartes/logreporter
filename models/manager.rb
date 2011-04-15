require "haml"
require "ostruct"
require 'archive/tar/minitar'

class Manager

  attr_accessor :data

  def initialize
    self.data = OpenStruct.new
  end

  def run!
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

  include Archive::Tar
  def generate_tar_file
    t=Time.now
    File.open(File.expand_path("tar/logreporter-summary.tar"), 'wb') { |tar| Minitar.pack('outputs', tar) }
  end
end
