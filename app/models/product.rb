class Product < ApplicationRecord
    before_destroy :not_referenced_by_any_product_item    
    has_many :product_items
    attr_accessor :remove_product_image

    after_save :purge_product_image, if: :remove_product_image
    private def purge_product_image
        product_image.purge_later
    end

    has_many :order_products
    has_many :orders, through: :order_products
    belongs_to :category
    belongs_to :brand
    belongs_to :seller, :class_name => "AdminUser"
    belongs_to :store

    has_one_attached :product_image
    validates :name, presence: true,
                    length: { minimum: 2 }
    validates :description, :price, :quantity, presence: true
    private

     def not_referenced_by_any_product_item
         unless product_items.empty?
             errors.add(:base, "product items are present")
             throw :abort
         end
     end
  def self.search(query)
    if query
      product = Product.find_by(name: query) || Product.find_by(description: query)
      if product
        @products=Product.where(id: product.id)
      end
    else
      @products=Product.all
    end
  end 

end
