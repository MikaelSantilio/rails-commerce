class CartService
  class Result
    attr_reader :success, :error, :cart

    def initialize(success:, error: nil, cart: nil)
      @success = success
      @error = error
      @cart = cart
    end

    def success?
      @success
    end

    def failure?
      !@success
    end
  end

  def self.add_new_product(cart, product, quantity)
    return Result.new(success: false, error: "Quantidade deve ser maior que zero") if quantity <= 0

    cart_item = cart.cart_items.find_by(product_id: product.id)
    if cart_item.present?
      return Result.new(success: false, error: "Produto já está no carrinho")
    end

    cart.transaction do
      cart.cart_items.create!(product: product, quantity: quantity)
      cart.recalculate_total_price
      cart.update_last_interaction_at
    end

    Result.new(success: true, cart: cart)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success: false, error: e.message)
  end

  def self.increase_product_quantity(cart, product, quantity)
    return Result.new(success: false, error: "Quantidade deve ser maior que zero") if quantity <= 0

    cart_item = cart.cart_items.find_by(product_id: product.id)
    if cart_item.blank?
      return Result.new(success: false, error: "Produto não está no carrinho")
    end

    cart.transaction do
      cart_item.increment(:quantity, quantity)
      cart_item.save!
      cart.recalculate_total_price
      cart.update_last_interaction_at
    end

    Result.new(success: true, cart: cart)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success: false, error: e.message)
  end

  def self.remove_product(cart, product)
    cart_item = cart.cart_items.find_by(product_id: product.id)
    if cart_item.blank?
      return Result.new(success: false, error: "Produto não está no carrinho")
    end

    cart.transaction do
      cart_item.destroy!
      cart.recalculate_total_price
      cart.update_last_interaction_at
    end

    Result.new(success: true, cart: cart)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success: false, error: e.message)
  end
end
