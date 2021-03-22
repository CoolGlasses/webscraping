require 'mechanize'
require 'csv'
require 'nokogiri'
require 'json'

#create an array of all the charities needed 

table = []

CSV.foreach("datadotgov_main.csv", headers: true, header_converters: :symbol) do |row|
    table << row
end

#search for the specific charity table[row #][:abn]
#populate the search form with the first ABN, click on search
#click on the charity to open the main page of the charity
#grab total income from main page -- assign to table[row #][:income]
#navigate to People tab
#scrape all people listed -- assign to table[row #][:person_#{number}]
#write scraped information to the csv file (can this be done via iteration through each row of CSV?)

headers = table.first.headers

CSV.open("charities_with_added_data.csv", "w") do |csv|
    csv << headers
    table.each do |row|
        csv << row
    end
end