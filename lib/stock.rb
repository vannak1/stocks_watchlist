class Stock

  attr_accessor :name, :ticker, :price, :change, :td_data, :low, :high, :prev_open, :prev_close, :day_range, :wRange, :industry, :summary
  @@all = []

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="),value)}
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_from_collection(stocks)
    stocks.each{|stock| Stock.new({ticker: stock})}
  end

  def add_stock_attributes(attributes)
    attributes.each{|k,v| self.send(("#{k}="), v)}
    self
  end
end


