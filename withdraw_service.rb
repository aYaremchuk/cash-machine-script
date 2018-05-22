require_relative 'data_writer'

class WithdrawService
  def initialize(available_money, account_data, data, account_id, file)
    @available_money = available_money
    @account_data = account_data
    @available_sum = available_money_sum
    @data = data
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

  def available_money_sum
    sum = 0
    @available_money.each_key do |key|
      sum += @available_money[key] * key if @available_money[key].positive?
    end
    @available_sum = sum
  end

  def amount_validate(money_to_withdraw)
    return false unless @account_data['balance'] >= money_to_withdraw
  end

  def perform_again
    money_to_withdraw = $stdin.gets.chomp
    main_validator(money_to_withdraw)
  end

  def amount_to_withdraw_and_validate(money_to_withdraw)
    money_for_withdraw = {}
    money_data = @available_money

    give = 0
    to_give = money_to_withdraw
    money_data.each_key do |key|
      money_data[key].times do |_i|
        next unless money_data[key].positive? && to_give >= money_data[key]
        give += key
        money_for_withdraw[key] ? money_for_withdraw[key] += 1 : money_for_withdraw[key] = 1
        money_data[key] -= 1
        to_give -= key
      end
    end

    @available_money = money_data
    @account_data['balance'] -= money_to_withdraw
    @available_sum = available_money_sum
    p "Your New Balance is ₴#{@account_data['balance']}"
    @data['banknotes'] = @available_money
    @data['accounts'][@account_id] = @account_data
    DataWriter.new(@data, @file).write
    @account_data['balance']
  end
end
