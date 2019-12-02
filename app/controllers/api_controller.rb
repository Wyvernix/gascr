require 'open-uri'

class ApiController < ApplicationController
  def wakeup
    render json: '{"alive":1}'
  end

  def trends
    result = {
      trend: find_trend,
      cycle: day_trend
    }
    render json: result
  end

  private

  def open_json(series_id)
    JSON.parse(
      open("http://api.eia.gov/series/?api_key=#{ENV['EIA_KEY']}&series_id=#{series_id}").read
    )
  end

  def push_json(json, series)
    data = json.dig('series', 0, 'data')
    return if data.nil?

    data.each do |datum|
      Statistic.create_with(value: datum[1].to_f).find_or_create_by(
        period: datum[0].to_i,
        series: series
      )
    end
    puts "Loaded #{series} data"
  end

  def populate_data
    puts 'Reloading EIA dataset...'
    petrol = open_json('PET.EER_EPMRU_PF4_Y35NY_DPG.W')
    oil = open_json('PET.RWTC.W')
    la = open_json('PET.EMM_EPM0_PTE_Y05LA_DPG.W')

    push_json(petrol, 'petrol')
    push_json(oil, 'oil')
    push_json(la, 'la')

    Statistic.find_or_create_by(series: 'log')
             .update_attribute(:value, Time.current.to_i)
    puts 'Loaded oil data'
  end

  def load_data
    last = Statistic.find_by(series: 'log')
    populate_data unless last && last.value > 1.week.ago.to_i

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

    dpetrol = 0.198 * (a - b) + -0.086 * (b - c)
    dxy = x - y
    dxy *= dxy.positive? ? 0.739 : 1.325
    dyz = y - z
    dyz *= dyz.positive? ? -0.256 : -0.095

    dpetrol + dxy + dyz
  end

  def day_trend
    case Date.current.day
    when 4..6
      0.01
    else
      -0.006
    end
  end
end
