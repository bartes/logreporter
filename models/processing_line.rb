class ProcessingLine
  include DataMapper::Resource

  property :id,          Serial
  belongs_to :request
  belongs_to :source
  property :lineno,      Integer
  property :controller,  String
  property :action,      String
  property :format,      String
  #only for Rails 2
  property :method,      String
  property :timestamp,   Integer, :key => true
  property :ip,          IPAddress


  def self.count_for(source, opts = {})
    sqler = SqlBuilder.new(:processing_lines,
                         :select => "COUNT(*)",
                         :where =>  {:source_id => source.id})

    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).first
  end

  def self.most_requested(source, opts = {})
    sqler = SqlBuilder.new(:processing_lines,
                         :select => [:controller, :action, :format, "COUNT(request_id) AS request_id_count"],
                         :where =>  {:source_id => source.id},
                         :order => "request_id_count DESC",
                         :group => [:controller, :action, :format],
                         :limit => 20
                        )
    sqler.update(opts)
    repository(:default).adapter.select(sqler.to_sql).map{|i| Hasher.do(i)}
  end

  def self.count_for_action(struct, source)
    count(:source_id => source.id, :controller => struct['controller'], :action => struct['action'], :format => struct['format'])
  end

end


