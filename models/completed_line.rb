class CompletedLine
  include DataMapper::Resource

  property :id,          Serial
  belongs_to :request
  belongs_to :source
  property :duration,    Float
  property :view,        Float
  property :db,          Float
  property :status,      Integer
  #only for Rails 2
  property :lineno,      Integer
  property :url,         URI

  def self.statuses(source, opts = {})
    sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => [
                           "COUNT(completed_lines.request_id) AS total_hits",
                           "AVG(completed_lines.duration) AS average_duration",
                           "completed_lines.status"],
                         :where =>  {:source_id => source.id},
                         :group => ["completed_lines.status"]
                        )
    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
  end

  def self.longest(column, sorting, source, opts = {})
    sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => [
                           "COUNT(completed_lines.request_id) AS #{column}_hits",
                           "MIN(completed_lines.#{column}) AS min_#{column}",
                           "MAX(completed_lines.#{column}) AS max_#{column}",
                           "AVG(completed_lines.#{column}) AS average_#{column}",
                           "SUM(completed_lines.#{column}) AS sum_#{column}",
                           "processing_lines.controller", "processing_lines.action", "processing_lines.format"],
                         :where =>  {:source_id => source.id, :"#{column}".not => nil},
                         :order => "#{sorting}_#{column} DESC",
                         :group => ["processing_lines.controller", "processing_lines.action", "processing_lines.format"],
                         :limit => 10
                        )
    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
  end

  def self.total_for(column, source, opts = {})
    sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => "COUNT(*)",
                         :where =>  {:source_id => source.id, :"#{column}".not => nil})

    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).first
  end

  def self.average_for(column, source, opts = {})
    sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => "AVG(#{column})",
                         :where =>  {:source_id => source.id, :"#{column}".not => nil})

    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).first
  end

  def self.blockers(source,  opts = {})
    sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => [
                           "COUNT(completed_lines.request_id) AS duration_hits",
                           "processing_lines.controller", "processing_lines.action", "processing_lines.format"],
                         :where =>  {:source_id => source.id, :duration.gt => 1},
                         :order => "duration_hits DESC",
                         :group => ["processing_lines.controller", "processing_lines.action", "processing_lines.format"],
                         :limit => 10
                        )
    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
  end

  def self.blocker_requests(source, opts = {})
    sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => [:url, :"completed_lines.request_id", :duration],
                         :where =>  {:source_id => source.id},
                         :order => "duration DESC",
                         :limit => 10
                        )
    sqler.update(opts)
    result = repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
    result.each do |r|
      if r['url'].nil?
        sl = StartedLine.first(:request_id => r['request_id'])
        r['url'] = sl.path
        r['timestamp'] = sl.timestamp
      else
        pl = ProcessingLine.first(:request_id => r['request_id'])
        r['timestamp'] = pl.timestamp
      end
    end
  end

  def self.top_actions_rails2(source, action_options, opts = {})
     sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => ["AVG(completed_lines.duration) AS average_duration", "COUNT(completed_lines.request_id) AS total_hits",
                                     "AVG(completed_lines.view) AS average_view", "AVG(completed_lines.db) AS average_db"],
                         :where =>  {:source_id => source.id},
                         :order => "duration DESC",
                        )

     sqler.update(opts)
     sqler.update(:where => {"processing_lines.action" => action_options[:action]}) if action_options.has_key?(:action)
     sqler.update(:where => {"processing_lines.controller" => action_options[:controller]}) if action_options.has_key?(:controller)
     sqler.update(:where => {"processing_lines.format" => action_options[:format].to_s.downcase}) if action_options.has_key?(:format)

     repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
  end

  def self.top_actions(source, action_options, opts = {})
     return top_actions_rails2(source, action_options, opts) unless first(:source_id => source.id).url.nil?
     sqler = SqlBuilder.new(:completed_lines,
                         :join => {:processing_lines => {:request_id => :request_id}},
                         :select => ["AVG(completed_lines.duration) AS average_duration", "COUNT(completed_lines.request_id) AS total_hits",
                                     "AVG(completed_lines.view) AS average_view", "AVG(completed_lines.db) AS average_db"],
                         :where =>  {:source_id => source.id},
                         :order => "duration DESC",
                        )

     sqler.update(opts)
     sqler.update(:where => {"processing_lines.action" => action_options[:action]}) if action_options.has_key?(:action)
     sqler.update(:where => {"processing_lines.controller" => action_options[:controller]}) if action_options.has_key?(:controller)
     sqler.update(:where => {"processing_lines.format" => action_options[:format]}) if action_options.has_key?(:format)

     repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
  end

  def self.top_actions_distribution_rails2(source, action_options, opts = {})
     (0..23).map do |hour|
       sqler = SqlBuilder.new(:completed_lines,
                          :join => {:processing_lines => {:request_id => :request_id}},
                          :select => ["AVG(completed_lines.duration) AS average_duration", "COUNT(completed_lines.request_id) AS total_hits"],
                          :where =>  {:source_id => source.id},
                          :order => "duration DESC",
                          )
       sqler.update(opts)
       sqler.update(:where => {"processing_lines.action" => action_options[:action]}) if action_options.has_key?(:action)
       sqler.update(:where => {"processing_lines.controller" => action_options[:controller]}) if action_options.has_key?(:controller)
       sqler.update(:where => {"processing_lines.format" => action_options[:format]}) if action_options.has_key?(:format)

       sqler.update(:where => {
         :"processing_lines.timestamp".gte => "#{source.date}#{hour.to_s.rjust(2,'0')}0000",
         :"processing_lines.timestamp".lt => "#{source.date}#{hour.to_s.rjust(2,'0')}5959"
       })
       repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
     end
  end

  def self.top_actions_distribution(source, action_options, opts = {})
     return top_actions_distribution_rails2(source, action_options, opts) unless first(:source_id => source.id).url.nil?

     (0..23).map do |hour|
        sqler = SqlBuilder.new(:completed_lines,
                            :join => {:processing_lines => {:request_id => :request_id}, :started_lines => {:request_id => :request_id}},
                            :select => ["AVG(completed_lines.duration) AS average_duration", "COUNT(completed_lines.request_id) AS total_hits"],
                            :where =>  {:source_id => source.id},
                            :order => "duration DESC",
                            )

        sqler.update(opts)
        sqler.update(:where => {"processing_lines.action" => action_options[:action]}) if action_options.has_key?(:action)
        sqler.update(:where => {"processing_lines.controller" => action_options[:controller]}) if action_options.has_key?(:controller)
        sqler.update(:where => {"processing_lines.format" => action_options[:format]}) if action_options.has_key?(:format)

        sqler.update(:where => {
          :"started_lines.timestamp".gte => "#{source.date}#{hour.to_s.rjust(2,'0')}0000",
          :"started_lines.timestamp".lt => "#{source.date}#{hour.to_s.rjust(2,'0')}5959"
        })
        repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
     end
  end

end

