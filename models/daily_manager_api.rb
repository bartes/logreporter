class DailyManagerApi < DailyManagerCore

  OPTIONS = {:where => {:"processing_lines.controller".like => "Api1%"}}

  TOP = [
    {:controller => "Api1::PlacesController", :action => "show", :chart => true},
    {:controller => "Api1::CategoriesController", :action => "show", :chart => true},
    {:controller => "Api1::ReviewsController", :action => "show", :chart => true},
    {:controller => "Api1::PlacesController", :action => "search", :chart => true},
  ]
  TOP_WITH_ALL = TOP + [{:chart => true}]

  def name
    :api
  end

end
