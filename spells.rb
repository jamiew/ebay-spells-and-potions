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

page = agent.get("http://www.ebay.com/sch/Spells-Potions-/102517/i.html?_ipg=200")


spells = (page/'table.li').map{|tr|
  data = {:img => (tr/'img')[0]['src'], :bids => (tr/'.bids')[0].content, :price => (tr/'.prc')[0].content, :title => (tr/'.dtl')[0].content}
  puts data.inspect
  data
}
