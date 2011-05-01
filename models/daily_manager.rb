class DailyManager
  attr_accessor :api, :site

  def initialize(date)
    self.api = DailyManagerApi.new(date)
    self.site = DailyManagerSite.new(date)
  end

  def run!(with_preload = false)
    api.run!(with_preload)
    site.run!(with_preload)
    true
  end

end
