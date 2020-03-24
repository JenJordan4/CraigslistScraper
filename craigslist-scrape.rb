require 'mechanize'
require 'pry-byebug'
require 'csv'


scraper = Mechanize.new #Use Mechanize gem to create a scraper
scraper.history_added = Proc.new { sleep 0.5 } #Prevent hitting craigslist server too frequently

ADDRESS = ROOT_URL + "/d/apts-housing-for-rent/search/jsy/apa"
results = [] #Start with an empty array to store the results
results << ['Title', 'Address', 'Monthly Rent', 'URL'] #Tites for the first row of the array


scraper.get(ADDRESS) do |search_page|
  #Search by select name
  search_form = search_page.form_with(:id => 'searchform') do |search|
    search['min_bedrooms'] = 3
    search['max_bedrooms'] = 3
    search['min_bathrooms'] = 2
    search['max_bathrooms'] = 2
  end

  results_page = search_form.submit #get the results and store it in a variable

  raw_results = results_page.search('li.result-row') #Within the search, target the li tags with the class "result-row"

  #for each result, collect the needed information and store it to a variable
  raw_results.each do |result|
    link = result.search('a')[1]
    name = link.text.strip
    url = link.attributes["href"].value
    price = result.search('span.result-price').first.text #Price shows in duplicate, so only show first.
    location = result.search('span.result-hood').text[2...-1]

    results << [name, location, price, url] #Push each filtered result row into the empty array on line 10
  end

  CSV.open("filename.csv", "w+") do |csv_file|
    results.each do |row|
      csv_file << row
    end
  end
  
end