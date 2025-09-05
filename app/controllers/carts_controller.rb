class CartsController < ApplicationController
  before_action :ensure_cart, only: [:show, :add_new_product, :add_item, :destroy_product]
  before_action :find_product, only: [:destroy_product, :add_new_product, :add_item]

  # GET /cart
  def show
    render json: CartSerializer.call(@cart)
  end

  # POST /cart
  def add_new_product
    quantity = params[:quantity].to_i
    result = CartService.add_new_product(@cart, @product, quantity)
    
    if result.success?
      render json: CartSerializer.call(result.cart)
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  # POST /cart/add_item
  def add_item
    quantity = params[:quantity].to_i
    result = CartService.increase_product_quantity(@cart, @product, quantity)
    
    if result.success?
      render json: CartSerializer.call(result.cart)
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  # DELETE /cart/:product_id
  def destroy_product
    result = CartService.remove_product(@cart, @product)
    
    if result.success?
      render json: CartSerializer.call(result.cart)
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
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
end