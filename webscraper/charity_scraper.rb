require 'mechanize'
require 'csv'
require 'nokogiri'
require 'json'

#create an array of all the charities needed 

table = []

CSV.foreach("datadotgov_main.csv", headers: true, header_converters: :symbol) do |row|
    table << row
end

table.each do |row|
    #go to website
    agent = Mechanize.new
    search_page = agent.get('https://www.acnc.gov.au/charity')

    #search for the specific charity table[row #][:abn]
    #populate the search form with the first ABN, click on search
    search_form = search_page.forms[1]
    search_form.name_abn = row[:abn] #need to adjust for iteration through table!
    results_page = agent.submit(search_form, search_form.buttons.first)

    #click on the charity to open the main page of the charity
    charity_main_page = results_page.link_with(text: row[:charity_legal_name]).click #need to adjust for iteration through table!

    #grab total income from main page -- assign to table[row #][:income]
    income = charity_main_page.css('.field-name-acnc-node-charity-graphs > div:nth-child(1) > div:nth-child(1) > p:nth-child(3)').text
    income = income[13..-1]
    row[:income] = income #need to fix for table iteration!

    #navigate to People tab
    #scrape all people listed -- assign to table[row #][:person_#{number}]
    people = charity_main_page.css('#views-bootstrap-grid-1 > div:nth-child(1)')
    people = people.css('h4')
    people.each_with_index do |person, i| #need to adjust for iteration through table!
        row["person_#{i + 1}".to_sym] = person.text
    end
end


#write scraped information to the csv file (can this be done via iteration through each row of CSV?)

headers = table.first.headers

CSV.open("charities_with_added_data.csv", "w") do |csv|
    csv << headers
    table.each do |row|
        csv << row
    end
end
