require 'rails_helper'

RSpec.describe CartSerializer, type: :serializer do
  let(:product) { FactoryBot.create(:product, name: "Test Product", price: 10.0) }
  let(:cart) { FactoryBot.create(:cart) }
  let!(:cart_item) { FactoryBot.create(:cart_item, cart: cart, product: product, quantity: 2) }

  describe '.call' do
    let(:result) { described_class.call(cart) }

    it 'returns cart with correct structure' do
      expect(result).to have_key(:id)
      expect(result).to have_key(:products)
      expect(result).to have_key(:total_price)
    end

    it 'returns correct cart id' do
      expect(result[:id]).to eq cart.id
    end

    it 'returns correct total price' do
      expect(result[:total_price]).to eq 20.0
    end

    it 'returns products array' do
      expect(result[:products]).to be_an Array
      expect(result[:products].length).to eq 1
    end

    it 'returns correctly serialized product' do
      product_data = result[:products].first
      
      expect(product_data[:id]).to eq product.id
      expect(product_data[:name]).to eq "Test Product"
      expect(product_data[:quantity]).to eq 2
      expect(product_data[:unit_price]).to eq 10.0
      expect(product_data[:total_price]).to eq 20.0
    end
  end
end
