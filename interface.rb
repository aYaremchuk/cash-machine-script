# frozen_string_literal: true

require 'io/console'
require 'byebug'

require_relative 'withdraw_service'

class Interface
  AVAILABLE_CHOICE_VARIANTS = { '1': 'display_balance',
                                '2': 'withdraw',
                                '3': 'logout' }.freeze

  def initialize(data, file, account_id = nil)
    @data = data
    @account_id = account_id
    @account_data = nil || @data['accounts'][account_id]
    @file = file
  end

  def dialog
    system_check
    check_account
  end

  def authorized_dialog
    puts
    puts 'Please Choose From the Following Options:'
    puts '1. Display Balance'
    puts '2. Withdraw'
    puts '3. Log Out'
    puts
    operation_choice
  end

  private

  def system_check
    if check_money_storage
      true
    else
      puts
      puts "This ATM doesn't work now. We don't have money"
      STDIN.getch
      exit
    end
  end

  def check_account
    puts
    puts 'Please Enter Your Account Number:'
    account_number = $stdin.gets.chomp
    @account_id = account_number.to_i
    if @data['accounts'][@account_id]
      check_password(@data['accounts'][@account_id])
    else
      puts "We don't have such account"
      dialog
    end
  end

  def check_password(account_data)
    puts 'Enter your password:'
    password = $stdin.gets.chomp
    if account_data['password'] == password
      @account_data = account_data
      puts "Hello, #{@account_data['name']}!"
      authorized_dialog
    else
      puts "ERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH"
      dialog
    end
  end

  def operation_choice
    choice = $stdin.gets.chomp

    prepared_choice_value = choice.to_s.to_sym
    if AVAILABLE_CHOICE_VARIANTS.keys.include?(prepared_choice_value)
      send(AVAILABLE_CHOICE_VARIANTS[prepared_choice_value])
    else
      puts 'no such variant'
      authorized_dialog
    end
  end

  def logout
    puts "#{@account_data['name']}, Thank You For Using Our ATM. Good-Bye!"
    @account_data = nil
    sleep 2
    print "\e[2J\e[f"
    dialog
  end

  def display_balance
    puts "Your Current Balance is ₴#{@account_data['balance']}"
    authorized_dialog
  end

  def withdraw
    if check_money_storage
      WithdrawService.new(@data, @account_id, @file).perform
    else
      puts 'No available money'
    end

    authorized_dialog
  end

  def check_money_storage
    WithdrawService.available_money_sum(@data['banknotes']).positive?
  end
end
