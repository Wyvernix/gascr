require 'open-uri'

class ApiController < ApplicationController
  def home
    render inline: 'hello'
  end

  def brent
    @brent_price = get_brent
  end

  def scrape_all
    #coal = Nokogiri(open('https://www.eia.gov/coal/markets/'))
    @coal = get_coal

  end

  private
  def get_brent
    doc = Nokogiri(open('https://markets.businessinsider.com/commodities/oil-price'))
    brent_price = doc.css('div#daily-arrow-price').inner_html.to_f
  end

  def get_coal
    coal_json = JSON.parse(open('https://www.eia.gov/coal/markets/coal_markets_json.php'))
    data = coal_json.dig('data', 0, 'snl_dpst', 1)
  end
end
