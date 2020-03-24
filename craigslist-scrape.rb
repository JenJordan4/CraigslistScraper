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

end