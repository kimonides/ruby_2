require 'watir'
require 'nokogiri'
require 'open-uri'

class Account
    def initialize(name, currency, balance, nature, transactions)
      @name = name
      @currency = currency
      @balance = balance
      @nature = nature
      @transactions = transactions
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
end

browser = Watir::Browser.new

browser.goto("https://demo.bendigobank.com.au/banking/sign_in")

browser.driver.manage.window.maximize

browser.button(:xpath => "//*[@id=\"login-form\"]/nav/button[1]").click

browser.ol(:xpath => "/html/body/main/div/section/div[1]/div[1]/div/div[1]/div[2]/ol/li[1]/ol").lis.each do | link |
    link.click

    browser.a(:xpath => "/html/body/main/div/section/div[2]/div/div/div/div/div/div/nav/a[3]").click
    sleep(1)

    page = Nokogiri::HTML(browser.html)

    x,y = [1,2]

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
    puts page.css("li[data-semantic='activity-item']").size


    # <li data-semantic="activity-item" data-semantic-activity-score="20220812.0001084668" data-semantic-activity-type="transaction" data-semantic-amount="12900" class="emotion-lfclgy"><article class="panel--badged" data-semantic-expanded="false" data-semantic="activity-item-article"><header class="panel__header" id="panel__header_1130"><a class="emotion-1gr6set" data-semantic="activity-anchor" href="/banking/accounts/cd92d7293c53c834e31c239228301aaa/transactions/cd92d7293c53c834e31c239228301aaa_1084668_2022-08-12T00:00:00+10:00"><div class="panel--badged__header__badge"><img alt="" class="avatar--logo emotion-0" src="https://production.upassets.net/merchant-data/uploads/merchant/logo/840/receipt_scale_1x_mcdonalds.png?v=1616029662"></div><div class="panel__header__label--inline"><h2 class="panel__header__label__primary" data-semantic="transaction-title"><span data-semantic="transaction-primary-title" title="McDonald's" class="emotion-lq7x0b">McDonald's</span><span data-semantic="transaction-secondary-title" title="Mcdonalds the Strand, Sydney / 2079" class="emotion-18s2xmn">Mcdonalds the Strand, Sydney / 2079</span></h2><div class="panel__header__label__secondary panel__header__label__secondary--offset"><span aria-label="Transaction amount: minus $129.00" class="transaction-amount-debit" data-semantic="transaction-amount"><span class="amount debit"><i aria-hidden="true" class="ico-money-debit_12px emotion-jgpxlh"><svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor" xmlns="http://www.w3.org/2000/svg" class="emotion-7mix5j"><path fill-rule="evenodd" clip-rule="evenodd" d="M2 6a.55.55 0 01.55-.55h6.9a.55.55 0 010 1.1h-6.9A.55.55 0 012 6z" fill="#000"></path></svg></i><span aria-label="$129.00" class="emotion-d3v9zr" data-semantic="amount">$129.00</span></span></span><span class="overflow-ellipsis amount running-balance" data-semantic="running-balance"><span class="emotion-19624tk" tabindex="-1">Balance after transaction:</span><span aria-label="Minus $495.04" class="emotion-d3v9zr"><span class="emotion-19624tk" tabindex="-1">Minus </span><span aria-hidden="true">− </span>$495.04</span></span></div><i aria-hidden="true" class="ico-chevron-detail panel__header__link-icon"><svg width="22" height="22" viewBox="0 0 22 22" fill="currentColor" xmlns="http://www.w3.org/2000/svg" class="emotion-1x48oym"><path fill-rule="evenodd" clip-rule="evenodd" d="M8.091 5.48a.75.75 0 011.06-.02l4.914 4.734a1.084 1.084 0 010 1.531l-.006.006-4.903 4.805a.75.75 0 11-1.05-1.072l4.594-4.502L8.111 6.54a.75.75 0 01-.02-1.06z" fill="#000"></path></svg></i></div></a></header></article></li>
    # grouped-list grouped-list--compact grouped-list--indent
    # <div class="emotion-12hdm2x" data-semantic="end-of-feed-message"><p>No more activity</p></div>

    sleep(100)

end
