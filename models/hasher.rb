class Hasher

  def self.do(struct)
    struct.members.inject({}){ |sum, i|
      sum[i.to_s] = struct[i]
      sum
    }
  end

  def self.stringify_keys(hash)
    hash.inject({}) do |options, (key, value)|
      options[key.to_s] = value
      options
    end
  end

end
