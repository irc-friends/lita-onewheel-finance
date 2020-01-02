require 'rest-client'

class IrcColors
  prefix = "\x03"
  @white  = "#{prefix}00"
  @black  = "#{prefix}01"
  @blue   = "#{prefix}02"
  @green  = "#{prefix}03"
  @red    = "#{prefix}04"
  @brown  = "#{prefix}05"
  @purple = "#{prefix}06"
  @orange = "#{prefix}07"
  @yellow = "#{prefix}08"
  @lime   = "#{prefix}09"
  @teal   = "#{prefix}10"
  @aqua   = "#{prefix}11"
  @royal  = "#{prefix}12"
  @pink   = "#{prefix}13"
  @grey   = "#{prefix}14"
  @silver = "#{prefix}15"
  @reset  = prefix

  class << self
    attr_reader :white, :black, :blue, :green, :red, :brown, :purple, :orange, :yellow, :lime, :teal, :aqua, :royal, :pink, :grey, :silver, :reset
  end

  def initialize
  end
end

class AlphaVantageQuote
  attr_reader :symbol, :open, :high, :low, :price, :volume, :trading_day, :prev_close, :change, :change_percent

  def initialize(json_blob)
    Lita.logger.debug "parsing: #{json_blob}"
    hash = JSON.parse(json_blob)
    quote = hash["Global Quote"]

    quote.keys.each do |key|
      case key
      when "01. symbol"
        @symbol = quote[key]
      when "02. open"
        @open = self.fix_number quote[key]
      when "03. high"
        @high = self.fix_number quote[key]
      when "04. low"
        @low = self.fix_number quote[key]
      when "05. price"
        @price = self.fix_number quote[key]
      when "06. volume"
        @volume = quote[key]
      when "07. latest trading day"
        @trading_day = quote[key]
      when "08. previous close"
        @prev_close = self.fix_number quote[key]
      when "09. change"
        @change = self.fix_number quote[key]
      when "10. change percent"
        @change_percent = self.fix_number quote[key]
      end
    end
  end

  def fix_number(price_str)
    price_str.to_f.round(2)
  end
end

class WorldTradeDataQuote
  attr_reader :open, :high, :low, :price, :volume, :trading_day, :prev_close, :change, :change_percent, :exchange, :error, :name
  attr_accessor :symbol

  def initialize(json_blob)
    Lita.logger.debug "parsing: #{json_blob}"
    hash = JSON.parse(json_blob)

    if hash['Message'].to_s.include? 'Error'
      @error = true
      return
    else
      @error = false
    end

    quote = hash['data'][0]

    quote.keys.each do |key|
      case key
      when "symbol"
        @symbol = quote[key]
      when "price_open"
        @open = self.fix_number quote[key]
      when "day_high"
        @high = self.fix_number quote[key]
      when "day_low"
        @low = self.fix_number quote[key]
      when "price"
        @price = self.fix_number quote[key]
      when "volume"
        @volume = quote[key].to_i
      when "last_trade_time"
        @trading_day = quote[key]
      when "08. previous close"
        @prev_close = self.fix_number quote[key]
      when "day_change"
        @change = self.fix_number quote[key]
      when "change_pct"
        @change_percent = self.fix_number quote[key]
      when 'stock_exchange_short'
        @exchange = quote[key].sub /NYSEARCA/, 'NYSE'
      when 'name'
        @name = quote[key]
      end
    end
  end

  def fix_number(price_str)
    price_str.to_f.round(2)
  end
end

module Lita
  module Handlers
    class OnewheelFinance < Handler
      config :apikey, required: true
      route /quote\s+(.+)/i, :handle_quote, command: true

      def handle_quote(response)
        stock = handle_world_trade_data response.matches[0][0]

        if stock.error
          str = "`#{stock.symbol}` not found on any stock exchange."
        else
          str = "#{IrcColors::grey}#{stock.exchange} - #{IrcColors::reset}#{stock.symbol}: #{IrcColors::blue}$#{stock.price}#{IrcColors::reset} "
          if stock.change >= 0
            # if irc
            str += "#{IrcColors::green} ⬆$#{stock.change}#{IrcColors::reset}, #{IrcColors::green}#{stock.change_percent}%#{IrcColors::reset} "
            str += "#{IrcColors::grey}(#{stock.name})#{IrcColors::reset}"
          else
            str += "#{IrcColors::red} ↯$#{stock.change}#{IrcColors::reset}, #{IrcColors::red}#{stock.change_percent}%#{IrcColors::reset} "
            str += "(#{stock.name})"
          end
        end

        response.reply str
      end

      def handle_world_trade_data(symbol)
        url = "https://api.worldtradingdata.com/api/v1/stock"
        params = {symbol: symbol, api_token: config.apikey}

        Lita.logger.debug "#{url} #{params.inspect}"

        resp = RestClient.get url, {params: params}
        Lita.logger.debug "response: #{resp}"

        stock = WorldTradeDataQuote.new resp
        if stock.error
          stock.symbol = symbol
        end
        stock
      end

      # deprecated for now
      def handle_alphavantage
        url = "https://www.alphavantage.co/query"
        params = {function: 'GLOBAL_QUOTE', symbol: response.matches[0][0], apikey: config.apikey}
        Lita.logger.debug "#{url} #{params.inspect}"
        resp = RestClient.get url, {params: params}
        stock = GlobalQuote.new resp
      end

      Lita.register_handler(self)
    end
  end
end
