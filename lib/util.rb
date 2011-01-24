module Rubytime
  class Util
    class << self
      def format_currency(currency, value)
        prefix = currency.prefix
        symbol = currency.symbol
        (arr = [sprintf('%.2f', value), symbol]) && prefix && arr.reverse!
        arr.join('')
      end
    
      def format_currency_hr(hr)
        format_currency(hr.currency, hr.value)
      end
    
      def format_time_spent(minutes)
        "#{minutes.to_i / 60}:#{(minutes.to_i % 60).to_s.rjust(2, '0')}"
      end
    
      def format_time_spent_decimal(minutes)
        sprintf('%.2f', minutes / 60.0)
      end
    
      def format_date(date, separator = '-')
        date.strftime("%d#{separator}%m#{separator}%Y")
      end
    end
  end
end
