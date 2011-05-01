class SqlBuilder

  attr_accessor :select, :where, :group, :order, :limit, :table, :join

  def initialize(table, options = {})
    self.table = table
    self.select = get_select(options[:select])
    self.where = get_where(options[:where])
    self.group = get_group(options[:group])
    self.order = options[:order]
    self.limit = options[:limit]
    self.join = options[:join]
  end


  def to_sql
    result = ["SELECT #{select || '*'} FROM #{table}"]
    unless join.nil?
      join.each{ |key, value|
        result << "INNER JOIN #{key} ON #{table}.#{value.keys.first} = #{key}.#{value.values.first}"
      }
    end
    result << "WHERE #{where}" unless where.nil?
    result << "GROUP BY #{group}" unless group.nil?
    result << "ORDER BY #{order}" unless order.nil?
    result << "LIMIT #{limit.to_i}" unless limit.nil?
    result.join(" ")
  end

  def get_select(select)
    case select
    when String
      select
    when Array
      select.join(", ")
    end
  end


  def get_group(group)
    case group
    when String
      group
    when Array
      group.join(", ")
    end
  end

  def get_where(where)
    case where
    when String
      where
    when Hash
      where.map{ |key, value|
        case key
          when DataMapper::Query::Operator
            if value.nil? and key.operator == :not
             "#{tabled_col(key.target)} IS NOT NULL"
            else
             "#{tabled_col(key.target)} #{self.class.operators(key.operator)} '#{value}'"
            end
          when Symbol, String
            if value.nil?
              "#{tabled_col(key)} IS NULL"
            else
              "#{tabled_col(key)} = '#{value}'"
            end
        end
      }.compact.join(" AND ")
    end
  end

  def update(options = {})
    self.limit = options[:limit] if options.has_key?(:limit)
    self.where << " AND " + get_where(options[:where]) if options.has_key?(:where)
  end

  def self.operators(operator)
     case operator
     when :gt then ">"
     when :gte then ">="
     when :lt then "<"
     when :lte then "<="
     when :like then "LIKE"
     when :not then "<>"
     end
  end

  def tabled_col(col)
    col.to_s.include?(".") ? col : "#{table}.#{col}"
  end
end
