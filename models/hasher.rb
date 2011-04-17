class Hasher

  def self.do(struct)
    struct.members.inject({}){ |sum, i|
      sum[i.to_s] = struct[i]
      sum
    }
  end
end
