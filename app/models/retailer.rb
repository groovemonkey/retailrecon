class Retailer
  include MongoMapper::Document

  key :name, String
  key :number_of_products

  many :products
end
