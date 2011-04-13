class Manager

  def parse

  end


  def generate
    template = File.read(File.expand_path('../views/report.haml'))
    haml_engine = Haml::Engine.new(template)
    output = haml_engine.render
  end


end
