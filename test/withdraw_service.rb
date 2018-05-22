require 'minitest/autorun'
require 'yaml'
require_relative '../withdraw_service.rb'

describe WithdrawService do
  available_money = YAML.load_file('test/fixtures/available_money.yml')
  account_data = YAML.load_file('test/fixtures/account_data.yml')
  data = YAML.load_file('test/fixtures/data.yml')
  account_id = 3321
  file = 'double'

  before do
    writer = MiniTest::Mock.new
    writer.expect :write, true
    @interface = WithdrawService.new(available_money,
                                     account_data,
                                     data,
                                     account_id,
                                     file)
  end

  describe 'when enought money in atm' do
    it 'must proceed' do
      @interface.send(:amount_to_withdraw_and_validate, 330).must_equal 81
    end
  end
end
