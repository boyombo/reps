require "mechanize"

REPS_URL = "http://www.nassnig.org/nass2/Princ_officers.php"
SENATORS_URL = "http://www.nassnig.org/nass/Princ_officers.php?title_sur=Sen."

agent = Mechanize.new
reps_page = agent.get REPS_URL
senators_page = agent.get SENATORS_URL

def nass_members(page, reps, id="housetext_newbody")
  page.search("//td[@id='#{id}']").each { |x| reps << x.text.gsub(/(.*)\n.*\n.*Political Party:(.*)\n.*State: (.*)/, '\1, \2, \3').gsub(/\s{2,}/, " ").strip }
  next_page_link = page.links.find { |l| l.text == 'Next' }
  return reps if next_page_link.nil?
  nass_members(next_page_link.click, reps, id)
end

File.open("reps.csv", "w") { |f| f.puts nass_members(reps_page, []) }
File.open("senators.csv", "w") { |f| f.puts nass_members(senators_page, [], "senatetext_newsbody") }
