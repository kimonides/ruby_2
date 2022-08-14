class Account
    def initialize(name, currency, balance, nature, transactions)
      @name = name
      @currency = currency
      @balance = balance
      @nature = nature
      @transactions = transactions
    end

    def to_json(options = {})
      JSON.pretty_generate({:name => @name, :balance => @balance, :currency => @currency, :nature => @nature, :transactions => @transactions}, options)
    end
end