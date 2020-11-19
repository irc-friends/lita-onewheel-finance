require 'erb'

class YahooQuote
  attr_reader :open, :high, :low, :price, :volume, :trading_day, :prev_close, :change, :change_percent, :exchange, :error, :name, :message, :is_index
  attr_accessor :symbol

  include ERB::Util

  def initialize(symbol, apikey)
    # Lita.logger.debug "parsing: #{json_blob}"
    # hash = JSON.parse(json_blob)
    @symbol = symbol
    @apikey = apikey
    @is_index = false

    if @symbol[0] == '^'
      @is_index = true
    end

    response = call_api
    hash = JSON.parse response

    quote = hash['chart']['result'][0]['meta']

    @symbol = quote['symbol']
    @open = self.fix_number quote['previousClose']
      # when "03. high"
      #   @high = self.fix_number quote[key]
      # when "04. low"
      #   @low = self.fix_number quote[key]
    @price = self.fix_number quote['regularMarketPrice']
      # when "06. volume"
      #   @volume = quote[key]
      # when "07. latest trading day"
      #   @trading_day = quote[key]
      # when "08. previous close"
    @prev_close = self.fix_number quote['previousClose']
    @change = self.fix_number @price - @prev_close
    @change_percent = self.fix_number ((@change / @prev_close) * 100)
  end

  def fix_number(price_str)
    price_str.to_f.round(2)
  end

  def is_index?
    @is_index
  end

  def call_api
    url = "https://query1.finance.yahoo.com/v8/finance/chart/#{url_encode(@symbol)}"
    Lita.logger.debug "#{url}"
    response = RestClient.get url

    # if @exchange
    #   params[:stock_exchange] = @exchange
    # end

    Lita.logger.debug "response: #{response}"
    response
  end
end
