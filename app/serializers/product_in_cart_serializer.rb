class ProductInCartSerializer
  def self.call(cart_item)
    {
      id: cart_item.product.id,
      name: cart_item.product.name,
      quantity: cart_item.quantity,
      unit_price: cart_item.product.price,
      total_price: cart_item.total_price
    }
  end
end
