class CartsController < ApplicationController
  before_action :ensure_cart, only: [:show, :add_new_product, :add_item, :destroy_product]
  before_action :find_product, only: [:destroy_product, :add_new_product, :add_item]

  # GET /cart
  def show
    render json: cart_response(@cart)
  end

  # POST /cart
  def add_new_product
    payload = params.permit(:product_id, :quantity)
    quantity = payload[:quantity].to_i
    if quantity <= 0
      render json: { error: "Quantidade inválida" }, status: :unprocessable_entity
      return
    end
    @cart.add_new_product(@product, quantity)
    render json: cart_response(@cart)
  end

  # POST /cart/add_item
  def add_item
    payload = params.permit(:product_id, :quantity)
    quantity = payload[:quantity].to_i
    if quantity <= 0
      render json: { error: "Quantidade inválida" }, status: :unprocessable_entity
      return
    end
    @cart.increase_product_quantity(@product, quantity)
    render json: cart_response(@cart)
  end

  # DELETE /cart/:product_id
  def destroy_product
    @cart.remove_product(@product)
    render json: cart_response(@cart)
  end

  private

  def find_product
    @product = Product.find_by(id: params[:product_id])
    
    unless @product
      render json: { error: "Produto não encontrado" }, status: :not_found and return
    end
  end

  def ensure_cart
    @cart = current_cart || create_cart
  end

  def current_cart
    Cart.find_by(id: session[:cart_id]) if session[:cart_id]
  end

  def create_cart
    cart = Cart.create!(total_price: 0)
    session[:cart_id] = cart.id
    cart
  end

  def cart_response(cart)
    {
      id: cart.id,
      products: cart.cart_items.includes(:product).map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.quantity * item.product.price
        }
      end,
      total_price: cart.cart_items.includes(:product).sum { |item| item.quantity * item.product.price }
    }
  end
end