require "mechanize"
require "csv"

REPS_URL = "http://www.nassnig.org/nass2/Princ_officers.php"
SENATORS_URL = "http://www.nassnig.org/nass/Princ_officers.php?title_sur=Sen."

agent = Mechanize.new
reps_page = agent.get REPS_URL
senators_page = agent.get SENATORS_URL



def nass_members(page, cursor, id="housetext_newbody")
  links = page.links.select { |l| l.attributes.attributes["href"].value =~ /portfolio\/profile\.php\?id=/ }
  links.each do |l|
    link = l.click.search("//*[@id='#{id}']").first
    next if link.nil?
    if id == "housetext_newbody"
      infos = link.css(".newsenn")
      index = 1
    else
      infos = link.xpath("span")
      index = 2
    end
    row = infos.map(&:text).map(&:strip)
    row[index] = row[index].scan(/(\w+[\w ]+),(.*)/)
    cursor << row.flatten
  end
  next_page_link = page.links.find { |l| l.text == 'Next' }
  return cursor.close if next_page_link.nil?
  nass_members(next_page_link.click, cursor, id)
end

nass_members(reps_page, CSV.open("new_reps.csv", "w"))
nass_members(senators_page, CSV.open("new_senators.csv", "w"), "senatetext_newsbody_large")
