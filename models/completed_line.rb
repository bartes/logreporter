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



  def self.longest(source, limit = 20)
    repository(:default).adapter.select("SELECT AVG(completed_lines.duration) AS average_duration, processing_lines.controller, processing_lines.action, processing_lines.format FROM completed_lines INNER JOIN processing_lines ON completed_lines.request_id = processing_lines.request_id WHERE completed_lines.source_id = #{source.id} GROUP BY processing_lines.controller, processing_lines.action, processing_lines.format ORDER BY completed_lines.duration DESC LIMIT #{limit}")
  end
end

