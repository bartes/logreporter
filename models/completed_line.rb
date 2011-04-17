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



  def self.longest(column, sorting, source, limit = 20)
    repository(:default).adapter.select("SELECT COUNT(completed_lines.request_id) AS #{column}_hits,
                                        MIN(completed_lines.#{column}) AS min_#{column},
                                        MAX(completed_lines.#{column}) AS max_#{column},
                                        AVG(completed_lines.#{column}) AS average_#{column},
                                        SUM(completed_lines.#{column}) AS sum_#{column},
                                        processing_lines.controller, processing_lines.action, processing_lines.format
                                        FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id
                                        WHERE (completed_lines.#{column} IS NOT NULL) AND completed_lines.source_id = #{source.id}
                                        GROUP BY processing_lines.controller, processing_lines.action, processing_lines.format
                                        ORDER BY #{sorting}_#{column} DESC LIMIT #{limit}").map{|i| Hasher.do(i)}
  end

  def self.total_for(column, source)
    sum(column, :conditions => ["source_id = ? AND #{column} IS NOT NULL", source.id])
  end

  def self.average_for(column, source)
    avg(column, :conditions =>  ["source_id = ? AND #{column} IS NOT NULL", source.id])
  end

  def self.blockers(source, limit = 20)
    repository(:default).adapter.select("SELECT
                                        COUNT(completed_lines.request_id) AS duration_hits,
                                        processing_lines.controller, processing_lines.action, processing_lines.format
                                        FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id
                                        WHERE completed_lines.source_id = #{source.id} AND completed_lines.duration > 1
                                        GROUP BY processing_lines.controller, processing_lines.action, processing_lines.format
                                        ORDER BY duration_hits DESC LIMIT #{limit}").map{|i| Hasher.do(i)}
  end

  def self.blocker_requests(source, limit = 20)
    result = repository(:default).adapter.select("SELECT url, request_id, duration FROM completed_lines WHERE source_id = #{source.id} ORDER BY duration DESC LIMIT #{limit}").map{|i| Hasher.do(i)}
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

  def self.top_actions(source, options, limit = 20)
     repository(:default).adapter.select("SELECT AVG(completed_lines.duration) AS average_duration,
                                          AVG(completed_lines.view) AS average_view,
                                          AVG(completed_lines.db) AS average_db
                                          FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id
                                          WHERE completed_lines.source_id = #{source.id} AND
                                          processing_lines.controller = '#{options[:controller]}' AND
                                          processing_lines.action = '#{options[:action]}' AND
                                          processing_lines.format = '#{options[:format]}'").map{|i| Hasher.do(i)}
  end

  def self.top_actions_distribution_rails2(source, options, limit = 20)
     (0..23).map do |hour|
        repository(:default).adapter.select("SELECT AVG(completed_lines.duration) As average_duration,
                                          SUM(completed_lines.request_id) AS total_hits
                                          FROM completed_lines INNER JOIN
                                          processing_lines ON completed_lines.request_id = processing_lines.request_id
                                          WHERE completed_lines.source_id = #{source.id} AND
                                          processing_lines.controller = '#{options[:controller]}' AND
                                          processing_lines.action = '#{options[:action]}' AND
                                          processing_lines.format = '#{options[:format]}' AND
                                          processing_lines.timestamp >= '#{source.date}#{hour.to_s.rjust(2,'0')}0000' AND
                                          processing_lines.timestamp <  '#{source.date}#{hour.to_s.rjust(2,'0')}5959'
                                         ").map{|i| Hasher.do(i)}
     end
  end
  def self.top_actions_distribution(source, options, limit = 20)
     query = "SELECT AVG(completed_lines.duration) AS average_duration, SUM(completed_lines.request_id) AS total_hits
                                          FROM completed_lines INNER JOIN
                                          processing_lines ON completed_lines.request_id = processing_lines.request_id
                                          INNER JOIN started_lines ON completed_lines.request_id = started_lines.request_id
                                          WHERE completed_lines.source_id = #{source.id}"
     query << " AND processing_lines.controller = '#{options[:controller]}'" if options[:controller]
     query << " AND processing_lines.action = '#{options[:action]}'" if options[:action]
     query << " AND processing_lines.format = '#{options[:format]}'" if options[:format]

     (0..23).map do |hour|
        repository(:default).adapter.select(query + " AND started_lines.timestamp >= '#{source.date}#{hour.to_s.rjust(2,'0')}0000' AND
                                          started_lines.timestamp <  '#{source.date}#{hour.to_s.rjust(2,'0')}5959'").map{|i| Hasher.do(i)}
     end
  end

end

