require 'watir'
require 'nokogiri'
require 'json'

class Account
    def initialize(name, currency, balance, nature, transactions)
      @name = name
      @currency = currency
      @balance = balance
      @nature = nature
      @transactions = transactions
    end


    def to_json(options = {})
      # {:name => @name, :balance => @balance, :currency => @currency, :nature => @nature, :transactions => @transactions}.to_json
      JSON.pretty_generate({:name => @name, :balance => @balance, :currency => @currency, :nature => @nature, :transactions => @transactions})
    end
end

class Transaction
    def initialize(date, description, amount, currency, account_name)
      @date = date
      @description = description
      @amount = amount
      @currency = currency
      @account_name = account_name
    end

    def to_json(options = {})
      # {:date => @date, :description => @description, :amount => @amount, :currency => @currency, :account_name => @account_name}.to_json
      JSON.pretty_generate({:date => @date, :description => @description, :amount => @amount, :currency => @currency, :account_name => @account_name})
    end
end


account_array = []
transaction_array = []

browser = Watir::Browser.new

browser.goto("https://demo.bendigobank.com.au/banking/sign_in")

browser.driver.manage.window.maximize

browser.button(:xpath => "//*[@id=\"login-form\"]/nav/button[1]").click

browser.ol(:xpath => "/html/body/main/div/section/div[1]/div[1]/div/div[1]/div[2]/ol/li[1]/ol").lis.each do | link |
    link.click

    browser.a(:xpath => "/html/body/main/div/section/div[2]/div/div/div/div/div/div/nav/a[3]").click
    sleep(1)

    page = Nokogiri::HTML(browser.html)

    # Account Name
    account_name = page.css("div[data-semantic='customer-name']").children()[1].text
    # ------------
    currencyBalancePair = page.css("span[data-semantic='header-available-balance-amount']").text
    # Account Currency
    account_currency = currencyBalancePair[0]
    # Account Balance
    account_balance = currencyBalancePair[1..-1]
    # Account Nature
    account_nature =  page.css("div[data-semantic='product-name']").children()[1].text

    browser.a(:xpath => "/html/body/main/div/section/div[2]/div/div/div/div/div/div/nav/a[1]").click
    page = Nokogiri::HTML(browser.html)
    
    account_transactions = []
    
    activity_groups = page.css("li[data-semantic='activity-group']")

    activity_groups.each do |activity_group|
      activity_items = activity_group.css("li[data-semantic='activity-item']")
      
      activity_items.each do |activity_item|
        transaction_description = activity_item.at_css("h2[data-semantic='transaction-title']").children[0].text
        transaction_date = activity_group.at_css("h3").text
        currencyAmountPair = activity_item.at_css("span[data-semantic='amount']").text
        transaction_currency = currencyAmountPair[0]
        transaction_amount = currencyAmountPair[1..-1]
        transaction_account_name = account_name
        
        transaction = Transaction.new(transaction_date, transaction_description, transaction_amount, transaction_currency, transaction_account_name)
        account_transactions.push(transaction)
        transaction_array.push(transaction)
      end
    end

    account = Account.new(account_name, account_currency, account_balance, account_nature, account_transactions)

    account_array.push(account)

    # puts JSON.pretty_generate(account)
end

File.open("output/accounts.json","w") do |f|
  f.write(JSON.pretty_generate({:accounts => account_array}))
end

File.open("output/transactions.json","w") do |f|
  f.write(JSON.pretty_generate({:transactions => transaction_array}))
end


# puts JSON.pretty_generate(account_array)
# puts JSON.pretty_generate(transaction_array)
# JSON.pretty_generate(transaction_array)






