require 'csv'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'byebug'

states = Hash.new

states = {
    "Illinois" => "https://farm.ewg.org/top_recips.php?fips=17000&progcode=totalfarm&yr=2020&regionname=Illinois",
    "Nebraska" =>  "https://farm.ewg.org/top_recips.php?fips=31000&progcode=totalfarm&yr=2020&regionname=Nebraska",
    "Kansas" => "https://farm.ewg.org/top_recips.php?fips=20000&progcode=totalfarm&yr=2020&regionname=Kansas",
    "Indiana" => "https://farm.ewg.org/top_recips.php?fips=18000&progcode=totalfarm&yr=2020&regionname=Indiana",
    "Ohio" => "https://farm.ewg.org/top_recips.php?fips=39000&progcode=totalfarm&yr=2020&regionname=Ohio",
    "Missouri" => "https://farm.ewg.org/top_recips.php?fips=29000&progcode=totalfarm&yr=2020&regionname=Missouri",
    "Minnesota" => "https://farm.ewg.org/top_recips.php?fips=27000&progcode=totalfarm&yr=2020&regionname=Minnesota",
    "Wisconsin" => "https://farm.ewg.org/top_recips.php?fips=55000&progcode=totalfarm&yr=2020&regionname=Wisconsin",
    "Michigan" => "https://farm.ewg.org/top_recips.php?fips=26000&progcode=totalfarm&yr=2020&regionname=Michigan",
    "South Dakota" => "https://farm.ewg.org/top_recips.php?fips=46000&progcode=totalfarm&yr=2020&regionname=SouthDakota",
    "North Dakota" => "https://farm.ewg.org/top_recips.php?fips=38000&progcode=totalfarm&yr=2020&regionname=NorthDakota",
    "Oklahoma" => "https://farm.ewg.org/top_recips.php?fips=40000&progcode=totalfarm&yr=2020&regionname=Oklahoma",
    "Texas" => "https://farm.ewg.org/top_recips.php?fips=48000&progcode=totalfarm&yr=2020&regionname=Texas"
}

fips = Hash.new

fips = {
    "Illinois" => "17000",
    "Nebraska" =>  "31000",
    "Kansas" => "20000",
    "Indiana" => "18000",
    "Ohio" => "39000",
    "Missouri" => "29000",
    "Minnesota" => "27000",
    "Wisconsin" => "55000",
    "Michigan" => "26000",
    "South Dakota" => "46000",
    "North Dakota" => "38000",
    "Oklahoma" => "40000",
    "Texas" => "48000"
}

states.each do |key, value|

    finally = []
    @browser = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1'

    agent = Mechanize.new
    agent.user_agent_alias = "Linux Mozilla"
    mech = agent.get value
    doc = Nokogiri::HTML(URI.open(value, 'User-Agent' => '#{@browser}'))
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
            mech = agent.get "https://farm.ewg.org/top_recips.php?fips=#{fips[key]}&progcode=totalfarm&page=#{page}"
            new_uri = mech.uri
            doc = Nokogiri::HTML(URI.open(new_uri, 'User-Agent' => '#{@browser}'))
            puts "Moving to Page ##{page}"
        else
            done = true
        end

    end

    CSV.open("#{key}.csv", "wb") do |csv|
        finally.each do |subArray|
            csv << [subArray[0], subArray[1], subArray[2], subArray[3]]
        end
    end
end
