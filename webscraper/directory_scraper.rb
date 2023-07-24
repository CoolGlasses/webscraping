require 'mechanize'
require 'csv'
require 'nokogiri'
require 'json'
require 'pry'


#get passed login screen
agent = Mechanize.new
login_page = agent.get('https://www.coachesdirectory.com/login')
login_form = login_page.form
login_form.email = 'collinsbasketball@gmail.com'
login_form.password = 'Wisbball24@!'  #updated 7/23/23
first_page = agent.submit(login_form, login_form.buttons.first)
grab_counter = 0
write_counter = 0

#goes to page for usa

sleep(3)
## usa_page = agent.page.links.find { |l| l.text == "USA" }.click  The .find method doesn' work anymore?
usa_page = ""
first_page.links.each do |link|
    if link.text.include?("USA")
        usa_page = link.click
    end
end
puts "Clicking on USA"

#created an array of links to schools on this page

states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN",
   "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA",
   "WV", "WI", "WY"]

states.each do |state|
    schools = []
    usa_form = usa_page.form
    page_number = 1
    levels = "JH"  #value of the option value, not the displayed text  Other options are HS, JC and SC (Senior College)
    this_state = state
    usa_form.p = page_number.to_s
    usa_form.levels = levels
    usa_form.states = this_state
    puts "Filtering Junior High only"
    sleep(3)
    usa_page = agent.submit(usa_form)


    finished_gathering_school_links = false

    sleep(3)
    while !finished_gathering_school_links

        puts "Gathering links on Page: #{page_number}"
        new_links = 0

        usa_page.links.each do |link|
            if link.text.include?('School')
                puts "Adding #{link.text} to schools array"
                schools << link
                new_links += 1
                puts "This makes : #{new_links} new links added this page"
                grab_counter += 1
                puts
                puts "Grab Progress is: #{grab_counter}"
                puts
                puts "In state: #{this_state}"
                puts
            end
        end

        if new_links == 0
            puts "No new links found!"
            finished_gathering_school_links = true
        else
            page_number += 1
            usa_form.p = page_number.to_s
            usa_form.levels = levels
            usa_form.states = this_state
            usa_page = agent.submit(usa_form)
            sleep(1)
        end
    end

    #go to each link in the schools array & write data to csv
    finally = []

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

    CSV.open("Junior_High_coaches_in_#{this_state}.csv", "wb") do |csv|
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
end


