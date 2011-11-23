require 'rubygems'
require 'bundler'
Bundler.require



=begin

eBay Spells & Potions, 200 results per page, first 3 pages

http://www.ebay.com/sch/Spells-Potions-/102517/i.html?_sop=15&_ipg=200
http://www.ebay.com/sch/Spells-Potions-/102517/i.html?_sop=15&_pgn=2&_ipg=200
http://www.ebay.com/sch/Spells-Potions-/102517/i.html?_sop=15&_pgn=3&_ipg=200

=end

agent = Mechanize.new
agent.user_agent = "Spells & Potions <http://github.com/jamiew/ebay-spells>"

# page = agent.get("http://www.ebay.com/sch/Spells-Potions-/102517/i.html?_ipg=200")
page = agent.get("http://localhost/ebay-spells/cache/page1.html")


spells = (page/'table.li').map do |tr|

  bid_text = (tr/'.bids')[0].children[0].content
  is_auction = (bid_text.downcase != 'buy it now')

  price_text = (tr/'.prc')[0].children[0].content
  price = price_text.gsub(/\$/,'').gsub('.','').to_i

  date_field = (tr/'.tme span')[0].children[0].content.gsub(/\302\240/,' ')
  # puts date_field.inspect
  dates ||= /(\d+)d (\d+)h (\d+)m/.match(date_field)
  dates ||= /(\d+)h (\d+)m/.match(date_field)
  dates ||= /(\d+)h (\d+)m/.match(date_field)
  dates ||= /(\d+)m/.match(date_field)
  if dates
    dates = dates[1..-1].map{|i| i.to_i }
    seconds_from_now = case dates.length
    when 3; then (dates[0]*24*60)+(dates[1]*60)+(dates[2])*60
    when 2; then (dates[0]*60)+(dates[1])*60
    when 1; then (dates[0])*60
    end
    parsed_date = Time.at(Time.now.to_i + seconds_from_now)
  else
    STDERR.puts "Warning: could not parse date #{date_field.inspect}"
    parsed_date = nil
  end


  data = {
    :title => (tr/'.dtl')[0].children[0].content.strip.chomp,
    :img => (tr/'img')[0]['src'].strip,
    :auction => is_auction,
    :bids => is_auction ? bid_text.to_i : nil,
    :price_text => price_text,
    :price => price,
    :top_rated => !(tr/'.trsicon').empty?,
    :ends_at => parsed_date,
  }
  # puts data.inspect
  # puts data[:ends_at]
  data
end

