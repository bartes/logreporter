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
    repository(:default).adapter.select("SELECT AVG(completed_lines.#{column}) AS average_#{column}, SUM(completed_lines.#{column}) AS total_#{column}, processing_lines.controller, processing_lines.action, processing_lines.format FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id WHERE completed_lines.source_id = #{source.id} GROUP BY processing_lines.controller, processing_lines.action, processing_lines.format ORDER BY completed_lines.#{column} DESC LIMIT #{limit}")
  end

  def self.total_for(column, source)
    sum(column, :source_id => source.id)
  end

  def self.average_for(column, source)
    avg(column, :source_id => source.id)
  end
end

