class Hash
  def -(subtrahend_hash)
    subtrahend_hash.each_key { |key| self[key] = self[key] - subtrahend_hash[key] }
    self
  end
end
