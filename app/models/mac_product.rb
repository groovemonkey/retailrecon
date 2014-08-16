class MacProduct
  include MongoMapper::Document

  key :name, String
  key :category, String
  key :url, String
  key :has_variations, Boolean

  many :mac_variations

end

class MacVariation
  include MongoMapper::Document

  key :name, String
  key :availabile, Boolean

end