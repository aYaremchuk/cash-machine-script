class DataWriter
  def initialize(data, file)
    @data = data
    @file = file
  end

  def write
    File.open(@file, 'w') { |f| f.write @data.to_yaml }
  end
end
