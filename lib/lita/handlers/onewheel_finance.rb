require_relative 'irc_colors'
require_relative 'alphavantage_quote'
require_relative 'worldtradedata_quote'
require_relative 'yahoo_quote'
require 'rest-client'

module Lita
  module Handlers
    class OnewheelFinance < Handler
      config :apikey, required: true
      config :mode, default: 'irc'
      config :handler, default: 'alphavantage'
      route(/^qu*o*t*e*\s+(.+)/i, :handle_quote, command: true)
      # route /q2\s+(.+)/i, :handle_alphavantage, command: true

      def handle_quote(response)
        response.matches[0][0].split.each { |sym| handle_symbol(sym, response) }
      end

      def handle_symbol(symbol, response)
        stock = if config.handler == 'worldtradedata'
          handle_world_trade_data(symbol)
        elsif config.handler == 'alphavantage'
          handle_alphavantage(symbol)
        elsif config.handler == 'yahoo'
          handle_yahoo(symbol)
        else
          Lita.logger.error "Unknown/missing config.handler #{config.handler}.  Try 'worldtradedata' or 'alphavantage'"
          return
        end

        reply(stock, response)
      end

      def reply(stock, response)
        # Continue!
        if stock.error
          if stock.message
            str = stock.message
          else
            str = "`#{stock.symbol}` not found on any stock exchange."
          end
        else
          dollar_sign = '$'
          if stock.is_index?
            dollar_sign = ''
          end

          # IRC mode
          if config.mode == 'irc'
            str = " #{stock.symbol}: #{dollar_sign}#{"%.2f" % stock.price} "
            if stock.change >= 0
              # if irc
              str += "#{IrcColors::green} #{dollar_sign}#{"%.2f" % stock.change}#{IrcColors::reset}, #{IrcColors::green}#{stock.change_percent}%#{IrcColors::reset} "
              if stock.name
                str += "#{IrcColors::grey}(#{stock.name})#{IrcColors::reset}"
              end
            else
              str += "#{IrcColors::red} #{dollar_sign}#{"%.2f" % stock.change}#{IrcColors::reset}, #{IrcColors::red}#{stock.change_percent}%#{IrcColors::reset} "
              if stock.name
                str += "#{IrcColors::grey}(#{stock.name})#{IrcColors::reset}"
              end
            end
          else
            str = "#{stock.exchange} - #{stock.symbol}: #{dollar_sign}#{"%.2f" % stock.price} "
            if stock.change >= 0
              # if irc
              str += " :arrow_up:#{dollar_sign}#{"%.2f" % stock.change}, :heavy_plus_sign:#{stock.change_percent}% "
              if stock.name
                str += "(#{stock.name})"
              end
            else
              str += " :chart_with_downwards_trend:#{dollar_sign}#{"%.2f" % stock.change}, :heavy_minus_sign:#{stock.change_percent}% "
              if stock.name
                str += "(#{stock.name})"
              end
            end
          end
        end

        response.reply str
      end

      def handle_world_trade_data(symbol)
        stock = WorldTradeDataQuote.new symbol, config.apikey
        if stock.error
          stock.symbol = symbol
        end
        stock
      end

      # deprecated for now
      def handle_alphavantage(symbol)
       stock = AlphaVantageQuote.new symbol, config.apikey
      end

      # welp
      def handle_yahoo(symbol)
       stock = YahooQuote.new symbol, config.apikey
      end

      Lita.register_handler(self)
    end
  end
end
