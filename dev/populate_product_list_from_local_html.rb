"""
Pull in captured html, parse with nokogiri (libxml2).
Strategy:
	-for each category, grab basic product info
	-no variation/availability available
	-collect links to visit for product crawling (to get variation/availability)
	-output a list of product hashes (with mongoDB in mind)

"""

require 'nokogiri'


page = Nokogiri::HTML(open("fullhtml.html")) 

# VERSION 1: get info from each product
def get_info_from_products(bodypart)
	allproducts = page.css('.panelnav_detail_hd')
	allproducts.each do |p|
		productObj = {
			"class" => p.xpath("../../../../../../../img").attribute("alt").value,
			"name" => p.attribute("alt").value,
			"URL" => p.xpath("../../../..").attribute('href').value
		}
	end
end


# panel that comes up when you select makeup->* (eyes, lips, etc)
categorypanel = page.css('.panelnav_catdetail_hd')

eyes_shadow_accordion = page.css('#psubcat_CAT154_accordion')

# get product <li>s
eyes_shadow_accordion.xpath("ul/li").each do | product |
	pname = product.xpath("a/div/div/h3/img").attribute('alt').value
	pURL = product.xpath("a").attribute('href').value # URL without baseurl
	desc = product.xpath("a/div/div/p").text #incomplete description!

end

