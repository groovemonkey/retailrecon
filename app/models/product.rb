class Product
  include MongoMapper::Document

  key :name, String
  key :category, String
  key :url, String
  key :has_variations, Boolean

  many :variations

end

class Variation
  include MongoMapper::Document

  key :name, String
  key :availabile, Boolean

end