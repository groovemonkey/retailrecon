#require 'rubygems'
#require 'mechanize'

#agent = Mechanize.new()
#page = agent.get("http://www.maccosmetics.com/search/esearch.tmpl?search=yield+to+love&search_submit.x=0&search_submit.y=0")


#####################################3
#
# phantomJS needs to be running on localhost:10001 for this to work
# (http://stackoverflow.com/questions/8778513/how-can-i-setup-run-phantomjs-on-ubuntu)
# in shell: # phantomjs --webdriver=10001
require "selenium-webdriver"
debug = true

class String
	def replacewith(del, ins)
		return self.split(del).join(ins)
	end
end


begin
# connect to phantomJS (possibly requires libqt4-dev qt4-qmake)
driver = Selenium::WebDriver.for(:remote, :url => "http://localhost:10001")
#driver = Selenium::WebDriver.for :firefox

rescue Errno::ECONNREFUSED
	puts "\nError: Phantomjs isn't running (or isn't accepting connections).\nPlease start it with 'phantomjs --webdriver=10001'\n\n"
end
#################################
#################################


def find_products(productname)
	productname = productname.replacewith(" ", "+")
	items = driver.find_elements(:class, "itemname")
	items.each do |i|
		puts i.text
		productnames << i.text
	end
end

def get_subcat_items(driver, clickID, product_address)
	driver.find_element(:id, clickID).click
	driver.find_elements(:class, "panelnav_detail_hd").each do |i|
		# there are hidden things in the DOM, so only add if the user can see it
		product_address << i.attribute("alt") if i.displayed?
	end
	driver.find_element(:id, clickID).click
end


# driver.save_screenshot("screenshot.png")
# full html is in driver.page_source
#driver.navigate.to "http://www.maccosmetics.com/search/esearch.tmpl?search=yield+to+love&search_submit.x=0&search_submit.y=0"
driver.navigate.to "http://www.maccosmetics.com/index.tmpl"

# click on img#gnav_makeup_hd (Makeup)
driver.find_element(:id, 'gnav_makeup_hd').click

	# click on img#pnav_CAT148_hd (eyes)
	driver.find_element(:id, 'pnav_CAT148_hd').click

	# somehow not finished loading unless we wait a sec (network speed issue?)
	sleep(1)

	# # click on img#psubcat_CAT154_hd (shadow)
	# driver.find_element(:id, 'psubcat_CAT154_hd').click
	# 	# store each .panelnav_detail_hd.attribute("alt") as a product
	# 	driver.find_elements(:class, "panelnav_detail_hd").each do |i|
	# 		(products['eyes']['shadow'] << i.attribute("alt")) if i.displayed?
	# 	end
	# # click on img#psubcat_CAT154_accordion_hd (close shadow)
	# driver.find_element(:id, 'psubcat_CAT154_accordion_hd').click
	
	# ## Eyes
	# get_subcat_items(driver, 'psubcat_CAT151_accordion_hd', products['eyes']['liner'])
	# get_subcat_items(driver, 'psubcat_CAT152_accordion_hd', products['eyes']['mascara'])
	# get_subcat_items(driver, 'psubcat_CAT149_accordion_hd', products['eyes']['brow'])
	# get_subcat_items(driver, 'psubcat_CAT150_accordion_hd', products['eyes']['lash'])
	# get_subcat_items(driver, 'psubcat_CAT153_accordion', products['eyes']['primer'])
	# get_subcat_items(driver, 'psubcat_CAT2222_accordion_hd', products['eyes']['kits_and_palettes'])

	#puts "debug: #{driver.find_elements(:class, "panelnav_detail_hd").count} items loaded after clicking on 'eyes' but BEFORE CLOSING EYES"

	## close eyes
	driver.find_element(:id, 'pnav_CAT148_hd').click
	puts "debug: #{driver.find_elements(:class, "panelnav_detail_hd").count} items loaded after clicking on 'eyes'" if debug

	sleep(1)
	# Lips
 	driver.find_element(:id, 'pnav_CAT163_hd').click
 	sleep(1)
 	driver.find_element(:id, 'pnav_CAT163_hd').click
	puts "debug: #{driver.find_elements(:class, "panelnav_detail_hd").count} items loaded after clicking on 'lips'" if debug


	sleep(1)
 	# Face
 	driver.find_element(:id, 'pnav_CAT155_hd').click
 	sleep(1)
 	driver.find_element(:id, 'pnav_CAT155_hd').click
 	puts "debug: #{driver.find_elements(:class, "panelnav_detail_hd").count} items loaded after clicking on 'face'" if debug


 	#### NOW EVERYTHING IS OPEN....get all products
 	product_list_flat = []

 	driver.find_elements(:class, "panelnav_detail_hd").each do |i|
 		# get category name for this item -- INEFFICIENT...
 		#category = i.find_element(:xpath, '../../../../../../../img').attribute("alt")

 		product_list_flat << i.attribute("alt")
 	end

 	## nails (different because everything comes in many variants (colors))
 	#driver.find_element(:id, 'pnav_CAT170_hd').click
 	#sleep(1)
 	#driver.find_element(:id, 'pnav_CAT170_hd').click

 	##### SKINCARE (another top-level categeory like makeup)



	### FILE STUFF && CHANGE CALCULATION
	arrayfile = 'productarray.dx'

	# load + clear file
	if File.exists?(arrayfile)
		oldArray = Marshal.load(File.read(arrayfile))
		File.delete(arrayfile)
	else
		oldArray = []
	end

	# calculate changes
	changes = product_list_flat - oldArray
	puts "#{changes.count} new products found: #{changes}"

	# write changes into logfile

	# save new array
	serialized_array = Marshal.dump(product_list_flat)
	File.open(arrayfile, 'w') {|f| f.write(serialized_array) }





	## Test Output
	num_products = product_list_flat.count
	#print product_list_flat.sort
	print("\n\nFinal Product count: #{num_products} \n\n")

	logfile = File.open('products.log', "a")
	#time = Time.now.to_s.split()[0] # "2014-09-24"
	time = Time.now.to_s

	logstring = "#{time} -- Products: #{num_products}"
	if changes.count > 0
		logstring += " -- #{changes.count} new products: #{changes}"
	end

	logfile.write(logstring + "\n")
	logfile.close




driver.quit