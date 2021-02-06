require 'csv'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'byebug'

finally = []
@browser = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1'

agent = Mechanize.new
agent.user_agent_alias = "Linux Mozilla"
mech = agent.get "https://farm.ewg.org/top_recips.php?fips=19000&progcode=totalfarm&regionname=Iowa"
doc = Nokogiri::HTML(URI.open("https://farm.ewg.org/top_recips.php?fips=19000&progcode=totalfarm&regionname=Iowa", 'User-Agent' => '#{@browser}'))
page = 0
done = false
while !done

    rows = doc.css('table').css('tbody').css('tr')

    rows.each_with_index do |row, i|
        array = []
        array << row.css('td:nth-child(1)').text
        array << row.css('td:nth-child(2)').text
        array << row.css('td:nth-child(3)').text
        array << row.css('td:nth-child(4)').text
        finally << array
        i += 1
        puts "Adding Row ##{i}"
    end

    next_link = mech.css('#main_content_area > p:nth-child(7) > strong:nth-child(1) > a:nth-child(1)').text
    or_next_link = mech.css('#main_content_area > p:nth-child(7) > strong:nth-child(2) > strong:nth-child(1) > a:nth-child(1)').text

    if next_link == "Next" || or_next_link == "Next"
        done = false
        page += 1
        sleep(1)
        mech = agent.get "https://farm.ewg.org/top_recips.php?fips=19000&progcode=totalfarm&page=#{page}"
        new_uri = mech.uri
        doc = Nokogiri::HTML(URI.open(new_uri, 'User-Agent' => '#{@browser}'))
        puts "Moving to Page ##{page}"
    else
        done = true
    end

end

CSV.open("iowa.csv", "wb") do |csv|
    finally.each do |subArray|
        csv << [subArray[0], subArray[1], subArray[2], subArray[3]]
    end
end
