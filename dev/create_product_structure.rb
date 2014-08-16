# start timer
t_start = Time.new


def display_products(product_hash)
	product_hash.each do |bodypart,category|
		puts "Products for #{bodypart}:"
		category.each do |c,products|
			if c
				puts "  Category: #{c}"
				products.each do |name, variations|
					print "    #{name}"
					variations.each do |v,instock|
						if v == "novariations"
							print ", in stock: #{instock}\n"
						else
							v.each do |vari, instock|
								puts "      Variation: #{vari}, in stock: #{instock}"
							end
						end
					end
				end
			else # c is false
				puts "\n\nCategory #{c} is empty.\n\n"
			end
		end
	end
end

"
TODO: the 'categories' hash below represents the information structure we're looking at on the site.
We need to be able to scrape the site and return this kind of structure, with product names and variations.
Once we can do that, we can write logic for hashing/comparing differences and notifying users.
Then we can write signup, billing, mobile client, and other parts.

"
productHash = {
	"eyes" => {
		# 			{shadowname => {("shade" || "novariations") => "in_stock?"}}
		"shadow" => {},
		"liner" => {},
		"mascara" => {},
		"brow" => {},
		"lash" => {},
		"primer" => {},
		"kits_and_palettes" => {}
	},
	"lips" => {
		"lipstick" => {},
		"lipglass" => {},
		"lip_pencil" => {},
		"care" => {},
		"primer" => {},
		"kits_and_bags" => {}
	},
	"face" => {
		"foundation" => {},
		"powder" => {},
		"cheek" => {},
		"concealer" => {},
		"primer" => {},
		"multi_use" => {}
	},
	"nails" => {},
	"skincare" => {},
	"tools" => {}

}
debug = true
require "selenium-webdriver"
driver = Selenium::WebDriver.for(:remote, :url => "http://localhost:10001")
#driver = Selenium::WebDriver.for :firefox

driver.navigate.to "http://www.maccosmetics.com/index.tmpl"

# click on img#gnav_makeup_hd (Makeup)
driver.find_element(:id, 'gnav_makeup_hd').click

# click on img#pnav_CAT148_hd (eyes)
driver.find_element(:id, 'pnav_CAT148_hd').click

# somehow not finished loading unless we wait a sec (network speed issue?)
sleep(1)

# open eye shadows
driver.find_element(:id, 'psubcat_CAT154_hd').click
sleep(1)

#products.each do |prod| # cache gets stale, need to refresh. I hate MAC. God forgive me for this code.
# for each product in eye shadows...
driver.find_elements(:class, "panelnav_detail_hd").count.times do |i|

	# refresh products, cuz everything is always stale
	products = driver.find_elements(:class, "panelnav_detail_hd")
	prod = products[i]

	prodname = prod.attribute("alt")
	if prod.displayed? && (prodname != "Custom Palette") # TODO: custom palette doesn't work yet
		puts "DEBUG: iterating over a product!"
		# click, then get variations from dropdown
		prod.click
		sleep(1)
		begin
			dropdown = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, "menu-swatches-byname"))
		rescue Selenium::WebDriver::Error::NoSuchElementError
			puts "no dropdown menu for #{prodname}"
			dropdown = false
		end

		# create array for variations
		productHash["eyes"]["shadow"][prodname] = []
		
		if dropdown
			# for each variation...
			dropdown.options.each do |o|
				dropdown.select_by(:text, o.text)
				in_stock = driver.find_element(:id, "add_to_bag").displayed?
				# add to data structure		# name 	# variation = availability
				productHash["eyes"]["shadow"][prodname] << {o.text => in_stock}
			end
		else
			# this is just a simple product (available or unavailable, no variations)
			in_stock = driver.find_element(:id, "add_to_bag").displayed?
			productHash["eyes"]["shadow"][prodname] << {"novariations" => in_stock}
		end
	end
end

t_end = Time.new


display_products(productHash)
puts "\n\nThat run took #{t_end - t_start} seconds.\n\n"



