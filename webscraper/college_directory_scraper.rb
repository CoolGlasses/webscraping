require 'mechanize'
require 'csv'
require 'nokogiri'
require 'json'


#get passed login screen
agent = Mechanize.new
login_page = agent.get('https://www.coachesdirectory.com/login')
login_form = login_page.form
login_form.email = 'collinsbasketball@gmail.com'
login_form.password = 'wisc537bb'
first_page = agent.submit(login_form, login_form.buttons.first)
grab_counter = 0
write_counter = 0

#goes to page for usa

sleep(1)
usa_page = agent.page.links.find { |l| l.text == "USA" }.click
puts "Clicking on USA"

#created an array of links to schools on this page



pages = 42
page_number = 1
finally = []

pages.each do 
    schools = []

    finished_gathering_school_links = false
    while !finished_gathering_school_links
        this_page = agent.get "https://www.coachesdirectory.com/search?sort=name&p=#{page_number}&q=&states=&levels=JC%2CSC&types=&positions=&location=&radius=5&enrollment_min=0&enrollment_max=0"
        puts "On page #{page_number}"

        ###Need to capture the state?!!
        new_links = 0
        this_page.links.each do |link|
            if link.text.include?('College') || link.text.include?("University")
                puts "Adding #{link.text} to schools array"
                schools << link
            end
        end

        if new_links == 0
            puts "No new links found!"
            finished_gathering_school_links = true
        else
            page_number += 1
            sleep(1)
        end
    end

    #go to each link in the schools array & write data to csv


        schools.each do |school|
            school_name = school.text
            this_page = school.click
            puts "Clicked on #{school_name}"
            puts
            puts "In state: #{this_state}"
            sleep(1)
            information = this_page.xpath('/html/body/div/section/div[2]/section[3]/div[2]/table/tbody/tr')
            if information.nil? || information.empty?
                puts "Was not able to find Coaches information!"
            else
                puts "Found Coaches information!"
            end
            sport = nil
            name = nil
            email = "none"
            information.each do |row|
                row.xpath('td').each_with_index do |data, i|
                    case i
                    when 0
                        sport = data.text
                    when 2
                        name = data.text
                    when 3
                        if data.last_element_child.nil?
                            email = "none"
                        else
                            email = data.last_element_child.last_element_child.text
                        end
                    end
                end
                finally << [this_state, school_name, sport, name, email] 
            end
        end

    
end

CSV.open("college_coaches.csv", "wb") do |csv|
        puts "Writing to CSV"
        finally.each do |subArray|
            csv << [subArray[0], subArray[1], subArray[2], subArray[3], subArray[4]]
            puts "Wrote: #{subArray[0]} to CSV"
            write_counter += 1
            puts "Write Progress is: #{write_counter}"
            puts
            puts "For state: #{this_state}"
        end
end
