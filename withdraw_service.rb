require_relative 'data_writer'
require_relative 'hash'

class WithdrawService
  def self.available_money_sum(available_money)
    sum = 0
    available_money.each_key do |key|
      sum += available_money[key] * key if available_money[key].positive?
    end
    sum
  end

  def initialize(data, account_id, file)
    @data = data
    @available_money = data['banknotes']
    @account_data = data['accounts'][account_id]
    @available_sum = WithdrawService.available_money_sum(@available_money)
    @account_id = account_id
    @file = file
  end

  def perform
    puts 'Enter Amount You Wish to Withdraw:'
    money_to_withdraw = $stdin.gets.chomp
    main_validator(money_to_withdraw)
  end

  private

  def main_validator(money_to_withdraw)
    money_to_withdraw = money_to_withdraw.to_i
    status = amount_validate(money_to_withdraw)
    if status == false
      puts 'ERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT:'
      perform_again
    elsif @available_sum < money_to_withdraw
      puts "ERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴#{@available_sum}. PLEASE ENTER A DIFFERENT AMOUNT:"
      perform_again
    else
      amount_to_withdraw_and_validate(money_to_withdraw)
    end
  end

  def amount_validate(money_to_withdraw)
    return false unless @account_data['balance'] >= money_to_withdraw
  end

  def perform_again
    money_to_withdraw = $stdin.gets.chomp
    main_validator(money_to_withdraw)
  end

  def another_sum_advice(smaller_sum, bigger_sum)
    if bigger_sum > 0
      puts "Sorry we have available ₴#{bigger_sum}. Please enter a different amount:"
      perform_again
    elsif smaller_sum > 0
      puts "Sorry we don't have enought money you can get only ₴#{smaller_sum}. Please enter a different amount:"
      perform_again
    else
      puts 'Something went wrong!'
    end
  end

  def amount_to_withdraw_and_validate(money_to_withdraw)
    processing_result = money_selection(@available_money.dup, money_to_withdraw, @account_data['balance'])
    if processing_result[:can_give] != 0 || processing_result[:minimum_to_try] != 0
      another_sum_advice(processing_result[:can_give], processing_result[:minimum_to_try])
    else
      process_money_give(processing_result[:to_give])
    end
  end

  def process_money_give(to_give)
    money_sum = WithdrawService.available_money_sum(to_give)
    puts "Take your money: #{money_sum}"
    banknote_word = ->(quantity) { quantity > 1 ? 'banknotes' : 'banknote' }
    to_give.each { |banknote, quantity| puts "#{quantity} #{banknote_word.call(quantity)} of ₴#{banknote}" }
    @data['accounts'][@account_id]['balance'] = @data['accounts'][@account_id]['balance'] - money_sum
    @data['banknotes'] = @data['banknotes'] - to_give
    DataWriter.new(@data, @file).write
    Interface.new(@data, @file, @account_id).authorized_dialog
  end

  def money_selection(money_data, to_withdraw, balance)
    all_money = money_data
    money_for_withdraw = {}
    give = 0
    to_give = to_withdraw
    money_data.each_key do |key|
      money_data[key].times do |iteration|
        next unless money_data[key].positive? && to_give >= key
        give += key
        money_for_withdraw[key] ? money_for_withdraw[key] += 1 : money_for_withdraw[key] = 1
        money_data[key] -= 1
        to_give -= key
      end
    end
    if WithdrawService.available_money_sum(money_for_withdraw) < to_withdraw
      can_give = WithdrawService.available_money_sum(money_for_withdraw)
      minimum_to_try = bigger_sum_advice(all_money, balance)
      result = { to_give: 0, can_give: WithdrawService.available_money_sum(money_for_withdraw), minimum_to_try: minimum_to_try }
    else
      result = { to_give: money_for_withdraw, can_give: 0, minimum_to_try: 0 }
    end
    result
  end

  def bigger_sum_advice(all_money, balance)
    available_banknotes = []
    all_money.keys.each { |banknote| available_banknotes.push(banknote) if all_money[banknote] > 0 && all_money[banknote] <= balance }
    available_banknotes.first || 0
  end
end
