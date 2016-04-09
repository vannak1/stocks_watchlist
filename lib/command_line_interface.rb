require_relative "../lib/scraper.rb"
require_relative "../lib/stock.rb"
require 'colorize'

class CommandLineInterface
  def run
    welcome_message
    trending_stocks
    get_stocks
    get_stock_details
    display_stocks
    stock_ticker_detail
  end

  def welcome_message
    puts "*********************************************************".colorize(:purple)
    puts "*          Welcome to stocks_watchlist                  *".colorize(:purple)
    puts "*********************************************************".colorize(:purple)
    puts " "
    puts "                    Loading...                           "
    puts " "
  end
  
  def trending_stocks
    stocks_arr = Scraper.scrape_trending_stock
    display_trending_stocks(stocks_arr)   
  end

  def display_trending_stocks(stocks_arr)
    puts ""
    puts "These stocks are trending on Twitter.".colorize(:blue)
    puts "#{stocks_arr[0]} | #{stocks_arr[1]} | #{stocks_arr[2]} | #{stocks_arr[3]} | #{stocks_arr[4]} | #{stocks_arr[5]}"
    puts "-----------------------------------------------------------"
  end

  def get_stocks
    stocks_arr = Scraper.scrape_filtered_stock
    Stock.create_from_collection(stocks_arr)
  end

  def get_stock_details
    Stock.all.each do |stock|
      attributes = Scraper.scrape_stock_details(stock.ticker)
      stock.add_stock_attributes(attributes)
    end
  end

  def stock_details_adder(ticker) #rename
    stock = Stock.new(ticker: ticker)
    attributes = Scraper.scrape_stock_details(ticker)
    stock.add_stock_attributes(attributes)
  end

  def stock_ticker_detail
    puts " "
    puts "Would you like more details on a stock?"
    print "Enter Y or N: "
    answer = gets.chomp
    
    if answer == 'Y' or answer == 'y'
      puts "Enter any ticker: (Does not have to be from the list.)"
      ticker = gets.chomp
      display_details(stock_details_adder(ticker))
      puts " "
      
      stock_ticker_detail
    else
      puts "Have a posperous day!".colorize(:green)
    end
  end

  def display_stocks
    puts ""
    puts "These stocks have seen increased activity.".colorize(:blue)
    puts "          Stock          |  Ticker  |  Price  |   % Change  "
    puts "------------------------------------------------------------"
    sorted_stock = Stock.all.sort_by{|k,v| v}
    sorted_stock.each_with_index do |stock,index|
      if index < 9
        puts " #{index+1}.#{truncate_name(stock.name)}      #{stock.ticker}      #{stock.price}" + "#{stock.change}".colorize(:green)  
      end
    end
    puts ""
  end
  
  def truncate_name(name)
    if name.length <= 20
      length = 20 - name.length
      truncated_name = name + " " * length
    else
      truncated_name = name[0..16]
      truncated_name << "..."
    end
    truncated_name
  end 

  def display_details(stock)
    table = stock.td_data

    puts " "
    puts "#{stock.name}".colorize(:blue)
    puts "               "
    puts "#{stock.summary[0..-10]}"
    puts " "
    puts "#{table[:market_cap]}"
    puts "#{table[:open]}" 
    puts "#{table[:range]}"   
    puts "#{table[:eps]}"
  end
end
