require 'minitest/autorun'
require 'yaml'
require_relative '../withdraw_service.rb'

class WithdrawServiceTest < Minitest::Test
  def setup
    @money = { 500 => 0,
               200 => 0,
               100 => 2,
               50 => 1,
               20 => 2,
               10 => 4,
               5 => 1,
               2 => 0,
               1 => 2 }
    @data = YAML::load_file('test/fixtures/config_example.yml')
  end

  def test_with_give_330
    withdraw = WithdrawService.new(@data, '', '').send(:money_selection, @money, 330, 350)
    assert({ to_give: { 100 => 2, 50 => 1, 20 => 2, 10 => 4 }, can_give: 0, minimum_to_try: 0 }, withdraw)
  end

  def test_with_give_12
    withdraw = WithdrawService.new(@data, '', '').send(:money_selection, @money, 12, 17)
    assert({ to_give: { 10 => 1, 1 => 2 }, can_give: 0, minimum_to_try: 0 }, withdraw)
  end

  def test_with_give_5
    withdraw = WithdrawService.new(@data, '', '').send(:money_selection, @money, 5, 5)
    assert_equal({ to_give: { 5 => 1 }, can_give: 0, minimum_to_try: 0 }, withdraw)
  end

  def test_with_can_give
    withdraw = WithdrawService.new(@data, '', '').send(:money_selection, { 20 => 1, 10 => 2 }, 25, 25)
    assert_equal({ to_give: 0, can_give: 20, minimum_to_try: 0 }, withdraw)
  end

  def test_with_can_give
    withdraw = WithdrawService.new(@data, '', '').send(:money_selection, { 500 => 1, 1 => 13 }, 25, 25)
    assert_equal({ to_give: 0, can_give: 13, minimum_to_try: 0 }, withdraw)
  end

  def test_with_can_give
    withdraw = WithdrawService.new(@data, '', '').send(:money_selection, { 500 => 1, 1 => 0 }, 50, 750)
    assert_equal({ to_give: 0, can_give: 0, minimum_to_try: 500 }, withdraw)
  end
end
