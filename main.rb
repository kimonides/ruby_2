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
    # puts link
    link.click
    # puts browser.a(:xpath => "//*[@id=\"entrypoint\"]/div/section/div[2]/div/div/div/div/div/div/nav/a[3]").href

    browser.a(:xpath => "/html/body/main/div/section/div[2]/div/div/div/div/div/div/nav/a[3]").click
    # resource = URI.open(browser.url+"?tab=details")
    # puts browser.html


    puts browser.div(:xpath => "//*[@id=\"entrypoint\"]/div/section/div[2]/div/div/div/div/div/div/div/article[1]/nav/div[3]").spans[1].text

    # <div class="emotion-18whkqz" data-semantic="customer-name"><span data-semantic="label" class="emotion-r03cqh">Customer Name</span><span data-semantic="detail" x-ms-format-detection="none" class="emotion-tkrxtb">Ms Stella Ryan</span></div>
    # sleep(60)
    page = Nokogiri::HTML(browser.html)

    test = page.css("div").select{|div| div['data-semantic'] == "customer-name"}
    # puts test[0].children()[1].text
    # sleep(100)

    #entrypoint > div > section > div.emotion-1yoy5x1 > div > div > div > div > div > div > div > article:nth-child(1) > nav > div:nth-child(3)

    # puts page.xpath("/html/body/main/div/section/div[2]/div/div/div/div/div/div/div/article[1]")
    # puts page.xpath("//*[@id=\"entrypoint\"]/div/section/div[2]/div/div/div/div/div/div/div/article[1]/nav/div[3]/span[2]").text


end

sleep(60)

