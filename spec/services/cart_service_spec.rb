require 'rails_helper'

RSpec.describe CartService, type: :service do
  let(:cart) { FactoryBot.create(:cart) }
  let(:product) { FactoryBot.create(:product, name: "Test Product", price: 10.0) }

  describe '.add_new_product' do
    context 'with valid quantity' do
      it 'adds product to cart successfully' do
        result = described_class.add_new_product(cart, product, 2)
        
        expect(result.success?).to be true
        expect(cart.cart_items.count).to eq 1
        expect(cart.cart_items.first.quantity).to eq 2
      end
    end

    context 'with invalid quantity' do
      it 'returns failure with error message' do
        result = described_class.add_new_product(cart, product, 0)
        
        expect(result.failure?).to be true
        expect(result.error).to eq "Quantidade deve ser maior que zero"
      end
    end

    context 'when product already in cart' do
      before { cart.cart_items.create!(product: product, quantity: 1) }

      it 'returns failure with error message' do
        result = described_class.add_new_product(cart, product, 2)
        
        expect(result.failure?).to be true
        expect(result.error).to eq "Produto já está no carrinho"
      end
    end
  end

  describe '.increase_product_quantity' do
    context 'when product exists in cart' do
      before { cart.cart_items.create!(product: product, quantity: 1) }

      it 'increases quantity successfully' do
        result = described_class.increase_product_quantity(cart, product, 2)
        
        expect(result.success?).to be true
        expect(cart.cart_items.first.quantity).to eq 3
      end
    end

    context 'when product does not exist in cart' do
      it 'returns failure with error message' do
        result = described_class.increase_product_quantity(cart, product, 2)
        
        expect(result.failure?).to be true
        expect(result.error).to eq "Produto não está no carrinho"
      end
    end

    context 'with invalid quantity' do
      before { cart.cart_items.create!(product: product, quantity: 1) }

      it 'returns failure with error message' do
        result = described_class.increase_product_quantity(cart, product, 0)
        
        expect(result.failure?).to be true
        expect(result.error).to eq "Quantidade deve ser maior que zero"
      end
    end
  end

  describe '.remove_product' do
    context 'when product exists in cart' do
      before { cart.cart_items.create!(product: product, quantity: 1) }

      it 'removes product successfully' do
        result = described_class.remove_product(cart, product)
        
        expect(result.success?).to be true
        expect(cart.cart_items.count).to eq 0
      end
    end

    context 'when product does not exist in cart' do
      it 'returns failure with error message' do
        result = described_class.remove_product(cart, product)
        
        expect(result.failure?).to be true
        expect(result.error).to eq "Produto não está no carrinho"
      end
    end
  end
end
