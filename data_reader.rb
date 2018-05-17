require 'yaml'
require 'pathname'

require_relative 'error'

class DataReader
  attr_reader :data, :filename
  
  def initialize(filename)
    @filename = filename
    @data = nil
  end
  
  def read_file
    raise Error, 'Can\'t find file with data' unless Pathname.new(@filename).exist?
    @data = YAML::load_file(@filename)
  end
end
