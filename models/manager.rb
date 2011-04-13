class Manager

  def parse

  end


  def generate
    template = File.read(File.expand_path('../views/report.haml'))
    haml_engine = Haml::Engine.new(template)
    output = haml_engine.render(:total_lines => 0, :per_hour => 0)
  end


end
