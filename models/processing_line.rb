class ProcessingLine
  include DataMapper::Resource

  property :id,          Serial
  belongs_to :request
  belongs_to :source
  property :lineno,      Integer
  property :controller,  String
  property :action,      String
  property :format,      String
  property :method,      String
  property :timestamp,   Integer, :key => true
  property :ip,          String


  def self.count_for_source(source)
    count(:source_id => source.id)
  end

  def self.most_requested(source, limit = 20)
    repository(:default).adapter.select("SELECT controller, action, format, method, COUNT(request_id) AS request_id_count FROM processing_lines WHERE source_id = #{source.id} GROUP BY controller, action, format, method ORDER BY request_id_count DESC LIMIT #{limit}")
  end

end


