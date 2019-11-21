require 'open-uri'

class ApiController < ApplicationController
  def wakeup
    render json: '{"alive":1}'
  end

  def brent
    @brent_price = Datum.find(tag: :oil)


    if stale?(last_modified: @brent_price.updated_at)
      render json: @brent_price
    end
    # @ibrent_price = get_brent
  end

  def all
    # coal = Nokogiri(open('https://www.eia.gov/coal/markets/'))
    @coal = coal
    @oil = oil
    @cng = cng
    @ind = ind
  end

  private

  def oil
    doc = Nokogiri(open('https://markets.businessinsider.com/commodities/oil-price'))
    doc.css('div#daily-arrow-price').inner_html.to_f
  end

  def ind
    doc = Nokogiri(open('https://fred.stlouisfed.org/series/INDPRO'))
    doc.css('span.series-meta-observation-value').first.inner_html.to_f
  end

  def coal
    coal_json = JSON.parse(open('https://www.eia.gov/coal/markets/coal_markets_json.php').string)
    coal_json.dig('data', 0, 'snl_dpst', 1)
  end

  def cng
    doc = Nokogiri(open('https://www.eia.gov/opendata/qb.php?sdid=NG.N3010CA3.M'))
    doc.css('div.main_col > table.basic_table > tbody > tr').first.css('td')[3].inner_html.to_f
  end
end
