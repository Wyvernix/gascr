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

  def populate_data
    puts "Reloading EIA dataset..."
    petrol = JSON.load(open("http://api.eia.gov/series/?api_key=#{ENV['EIA_KEY']}&series_id=PET.EER_EPMRU_PF4_Y35NY_DPG.W"))
    oil = JSON.load(open("http://api.eia.gov/series/?api_key=#{ENV['EIA_KEY']}&series_id=PET.RWTC.W"))
    la = JSON.load(open("http://api.eia.gov/series/?api_key=#{ENV['EIA_KEY']}&series_id=PET.EMM_EPM0_PTE_Y05LA_DPG.W"))

    petrol.dig('series', 0, 'data').each do |datum|
      # 0: date, 1: value
      Statistic.create_with(value: datum[1].to_f).find_or_create_by(
        period: datum[0].to_i,
        series: 'petrol'
      )
#      stat = Statistic.find_or_create_by(
#        period: datum[0].to_i,
#        series: 'petrol')
#      stat.value = datum[1].to_f
#      stat.save
    end
    puts "Loaded petrol data."

    oil.dig('series', 0, 'data').each do |datum|
      Statistic.create_with(value: datum[1].to_f).find_or_create_by(
        period: datum[0].to_i,
        series: 'oil'
      )
    end

    la.dig('series', 0, 'data').each do |datum|
      Statistic.create_with(value: datum[1].to_f).find_or_create_by(
        period: datum[0].to_i,
        series: 'la'
      )
    end

    puts "Loaded oil data"
  end

  def load_data
    last = Statistic.order(period: :desc).first
    populate_data unless (last && Date.parse(last.period.to_s) > 2.weeks.ago)

    @oil = Statistic.order(period: :desc).where(series: 'oil').limit(3)
    @petrol = Statistic.order(period: :desc).where(series: 'la').limit(3)
  end

  def find_trend
    load_data
    x = Math.log(@oil[0].value)
    y = Math.log(@oil[1].value)
    z = Math.log(@oil[2].value)
    a = Math.log(@petrol[0].value)
    b = Math.log(@petrol[1].value)
    c = Math.log(@petrol[2].value)

    dpetrol = 0.198 * (a-b) + -0.086 * (b-c)
    dxy = x-y
    dyz = y-z
    dxy *= (dxy.positive?) ? 0.739 : 1.325
    dyz *= (dyz.positive?) ? -0.256 : -0.095

    dpetrol + dxy + dyz
  end

  def day_trend
    case Date.current.day
    when 1
      -1
    when 2
      -1
    when 3
      0
    when 4
      1
    when 5
      1
    when 6
      0
    when 7
      -1
    end
  end

  def trends
    result = {
      trend: find_trend,
    }
    render json: result
  end

  def all
    # coal = Nokogiri(open('https://www.eia.gov/coal/markets/'))
#    @coal = coal
#    @oil = oil
#    @cng = cng
#    @ind = ind
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
    coal_json.dig('data', 0, 'snl_dpst', 1, 'CENTRAL_APP')
  end

  def cng
    doc = Nokogiri(open('https://www.eia.gov/opendata/qb.php?sdid=NG.N3010CA3.M'))
    doc.css('div.main_col > table.basic_table > tbody > tr').first.css('td')[3].inner_html.to_f
  end
end
