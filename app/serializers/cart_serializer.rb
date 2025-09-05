class CartSerializer
  def self.call(cart)
    {
      id: cart.id,
      products: cart.cart_items.includes(:product).map { |item|
        ProductInCartSerializer.call(item)
      },
      total_price: cart.cart_items.sum(&:total_price)
    }
  end
end
