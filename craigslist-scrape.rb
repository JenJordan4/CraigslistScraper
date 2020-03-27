require 'mechanize'
require 'pry-byebug'
require 'csv'

city_name = nil
while city_name.nil?

  puts "Please enter your city"
  city_name = gets.chomp.delete(" ").downcase
  root_url = "https://#{city_name}.craigslist.org"
  puts "Getting details from #{root_url}"

  begin

    scraper = Mechanize.new #Use Mechanize gem to create a scraper
    scraper.history_added = Proc.new { sleep 0.5 } #Prevent hitting craigslist server too frequently

    address = root_url + "/d/apts-housing-for-rent/search/jsy/apa"
    listings = [] #Start with an empty array to store the listings
    listings << ['Title', 'address', 'Monthly Rent', 'URL'] #Tites for the first row of the array

    scraper.get(address) do |search_page|

      #Search by select name
      search_form = search_page.form_with(:id => 'searchform') do |search|
        search['min_bedrooms'] = 3
        search['max_bedrooms'] = 3
        search['min_bathrooms'] = 2
        search['max_bathrooms'] = 2
      end
      
      listings_page = search_form.submit #get the listings and store it in a variable

      raw_listings = listings_page.search('li.result-row') #Within the search, target the li tags with the class "result-row"

      #for each result, collect the needed information and store it to a variable
      raw_listings.each do |result|
        link = result.search('a')[1]
        name = link.text.strip
        url = link.attributes["href"].value
        price = result.search('span.result-price').first.text #Price shows in duplicate, so only show first.
        location = result.search('span.result-hood').text[2...-1]
        listings << [name, location, price, url] #Push each filtered result row into the empty array on line 10
      end

      CSV.open("listings.csv", "w+") do |csv_file|
        listings.each do |row|
          csv_file << row
        end
      end
      
      puts "Scraping complete. CSV file can be found in same folder as this application."

    end

  rescue SocketError #Recovers from errors when an invalid city is entered
    puts "That is not a valid Craigslist city name. Please try again."
    city_name = nil
  rescue ArgumentError #Recovers if user accidentally hits enter without typing
    puts "City name is blank. Please try again."
    city_name = nil
  end

end