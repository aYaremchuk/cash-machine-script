require_relative 'data_reader'
require_relative 'interface'

class Atm
  trap('SIGINT') { exit! }
  begin
    @filename = ARGV[0]
    @data = DataReader.new(@filename).read_file
    Interface.new(@data, @filename).dialog
  rescue Error => error
    puts error
  end
end
