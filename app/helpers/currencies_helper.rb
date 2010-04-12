module CurrenciesHelper
  def currency_example(currency)
    prefix = currency.prefix
    symbol = currency.symbol
    (example = ['45.99', symbol]) && prefix && example.reverse!
    example.join('')
  end
end
