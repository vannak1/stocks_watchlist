require 'open-uri'
require 'Nokogiri'
require 'pry'

class Scraper

  def self.scrape_filtered_stock
    stock_page = Nokogiri::HTML(open('http://finviz.com/screener.ashx?v=111&s=ta_unusualvolume&f=sh_avgvol_o500,sh_relvol_o1.5,ta_perf_dup'))
    
    stocks = []
    stock_list = stock_page.css(".screener-link-primary")
    stock_list.each do|stock|
      if stock.text.size == 4
        stocks << stock.text
      elsif stock.text.size == 3
        stocks << stock.text + " "
      end
    end  
    stocks
  end

  def self.scrape_trending_stock
    stock_twits = Nokogiri::HTML(open('http://www.stocktwits.com'))
    trending = stock_twits.css("#scrollingText")

    trending_stocks = trending.text.split("\n")
    trending_stocks.reject!{|stock| stock == "" }
  end
    

  def self.scrape_stock_details(ticker)
    page_url = "http://finance.yahoo.com/q?s=" + ticker.downcase
    details_page = Nokogiri::HTML(open(page_url))

    stock_price = details_page.css(".time_rtq_ticker").text
    if stock_price.size < 8
      stock_price += (" " * (8 - stock_price.size))
    end

    price_change = details_page.css(".yfi_rt_quote_summary_rt_top .time_rtq_content").text
    stock_name = details_page.css(".yfi_rt_quote_summary .hd h2").text[/\A(\w*\s*)*/]
    td_data = parse(details_page.css("#yfi_quote_summary_data").text)
    stock_summary = details_page.css("#yfi_business_summary .bd").text
    
    {name: stock_name, price: stock_price, change: price_change, td_data: td_data, summary: stock_summary}
  end

  def self.parse(data)
    open = data[/Prev Close:\d\d.\d\d/]
    range = data[/52wk Range:\d\d.\d\d - \d\d.\d\d/]
    market_cap = data[/Market Cap:\d*.\d*\w/]
    eps = data[/EPS\s\W\w*\W:-?\d*.\d*/]

    {open: open, range: range, market_cap: market_cap, eps: eps}
  end
end

scraper = Scraper.scrape_trending_stock