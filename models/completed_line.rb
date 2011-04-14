class CompletedLine
  include DataMapper::Resource

  property :id,          Serial
  belongs_to :request
  belongs_to :source
  property :lineno,      Integer
  property :duration,    Float
  property :view,        Float
  property :db,          Float
  property :status,      Integer
  property :url,         String



  def self.longest(column, source, limit = 20)
    repository(:default).adapter.select("SELECT COUNT(completed_lines.request_id) AS #{column}_hits, MIN(completed_lines.#{column}) AS min_#{column}, MAX(completed_lines.#{column}) AS max_#{column},  AVG(completed_lines.#{column}) AS average_#{column}, SUM(completed_lines.#{column}) AS total_#{column}, processing_lines.controller, processing_lines.action, processing_lines.format, processing_lines.method FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id WHERE completed_lines.source_id = #{source.id} GROUP BY processing_lines.controller, processing_lines.action, processing_lines.format, processing_lines.method ORDER BY completed_lines.#{column} DESC LIMIT #{limit}")
  end

  def self.total_for(column, source)
    sum(column, :source_id => source.id)
  end

  def self.average_for(column, source)
    avg(column, :source_id => source.id)
  end

  def self.blockers(source, limit = 20)
    repository(:default).adapter.select("SELECT NULL AS total_hits, NULL AS percentage, COUNT(completed_lines.request_id) AS duration_hits, processing_lines.controller, processing_lines.action, processing_lines.format, processing_lines.method FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id WHERE completed_lines.source_id = #{source.id} AND completed_lines.duration > 1 GROUP BY processing_lines.controller, processing_lines.action, processing_lines.format, processing_lines.method ORDER BY duration_hits DESC LIMIT #{limit}")
  end

  def self.statuses( source, limit = 20)
    repositor
  end
end

