require "mechanize"

REPS_URL = "http://www.nassnig.org/nass2/Princ_officers.php"
SENATORS_URL = "http://www.nassnig.org/nass/Princ_officers.php?title_sur=Sen."

agent = Mechanize.new
reps_page = agent.get REPS_URL
senators_page = agent.get SENATORS_URL



def nass_members(page, reps, id="housetext_newbody")
  links = page.links.select { |l| l.attributes.attributes["href"].value =~ /portfolio\/profile\.php\?id=/ }
  links.each do |l|
    link = l.click.search("//*[@id='#{id}']").first
    next if link.nil?
    if id == "housetext_newbody"
      infos = link.css(".newsenn")
    else
      infos = link.xpath("span")
    end
    reps << infos.map(&:text).map(&:strip).join(",")
  end
  next_page_link = page.links.find { |l| l.text == 'Next' }
  return reps if next_page_link.nil?
  nass_members(next_page_link.click, reps, id)
end

File.open("new_reps.csv", "w") { |f| f.puts nass_members(reps_page, []) }
File.open("new_senators.csv", "w") { |f| f.puts nass_members(senators_page, [], "senatetext_newsbody_large") }
