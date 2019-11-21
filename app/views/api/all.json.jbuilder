json.result do
  json.date Time.now
  json.oil @oil
  json.coal @coal
  json.cng @cng
  json.ind @ind
end
