require 'watir'
require 'nokogiri'
require 'json'

require_relative 'account'
require_relative 'transaction'

account_array = []
transaction_array = []

browser = Watir::Browser.new

browser.goto("https://demo.bendigobank.com.au/banking/sign_in")

browser.driver.manage.window.maximize

browser.button(:xpath => "//*[@id=\"login-form\"]/nav/button[1]").click

browser.li(data_semantic: "account-group").ol.lis.each do | link |
    link.click

    browser.a(data_semantic: "segmented-control-item-details").click
    sleep(1)

    page = Nokogiri::HTML(browser.div(data_semantic: "account").html)

    # Account Name
    account_name = page.at_css("div[data-semantic='customer-name']").at_css("span[data-semantic='detail']").text
    # ------------
    currencyBalancePair = page.at_css("span[data-semantic='header-available-balance-amount']").text
    # Account Currency
    account_currency = currencyBalancePair[0]
    # Account Balance
    account_balance = currencyBalancePair[1..-1].tr(',','').to_f
    # Account Nature
    account_nature =  page.at_css("div[data-semantic='product-name']").at_css("span[data-semantic='detail']").text

    browser.a(data_semantic: "segmented-control-item-activity").click

    browser.scroll.to :bottom
    sleep(1)
    browser.scroll.to :bottom
    sleep(1)
    browser.scroll.to :bottom
    sleep(0.5)

    page = Nokogiri::HTML(browser.ol(class: 'grouped-list grouped-list--compact grouped-list--indent').html)
    
    # Account Transactions
    account_transactions = []
    
    activity_groups = page.css("li[data-semantic='activity-group']")

    activity_groups.each do |activity_group|

      if (Date.today - Date.parse(activity_group['data-semantic-group'])).to_i > 2*31
        break
      end

      activity_items = activity_group.css("li[data-semantic='activity-item']")
      
      activity_items.each do |activity_item|
        # Transaction Date
        transaction_date = activity_group.at_css("h3").text
        # Transaction Description
        transaction_description = activity_item.at_css("h2[data-semantic='transaction-title']").children[0].text
        # ------------------
        is_negative = activity_item.at_css("span[data-semantic='transaction-amount']").attribute("aria-label").value.include? "minus"
        #----------------------------
        currencyAmountPair = activity_item.at_css("span[data-semantic='amount']").text
        # Transaction Amount
        if is_negative
          transaction_amount = -1 * currencyAmountPair[1..-1].tr(',','').to_f
        else
          transaction_amount = currencyAmountPair[1..-1].tr(',','').to_f
        end
        # Transaction Currency
        transaction_currency = currencyAmountPair[0]
        # Transaction Account Name
        transaction_account_name = account_name
        
        transaction = Transaction.new(transaction_date, transaction_description, transaction_amount, transaction_currency, transaction_account_name)
        
        account_transactions.push(transaction)
        transaction_array.push(transaction)
      end
    end

    account = Account.new(account_name, account_currency, account_balance, account_nature, account_transactions)
    account_array.push(account)
end

File.open("output/accounts.json","w") do |f|
  f.write(JSON.pretty_generate({:accounts => account_array}))
end

File.open("output/transactions.json","w") do |f|
  f.write(JSON.pretty_generate({:transactions => transaction_array}))
end
