require File.expand_path("logreporter", File.dirname(__FILE__))
options = {:date => ENV["DATE"], :all => ENV["ALL"], :only_new => ENV["ONLY_NEW"]}
Manager.new(options).run!(true)

