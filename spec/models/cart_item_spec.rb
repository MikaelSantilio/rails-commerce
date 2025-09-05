require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { FactoryBot.create(:cart) }
  let(:product) { FactoryBot.create(:product, price: 10.0) }

  describe 'validations' do
    it 'validates quantity is greater than 0' do
      cart_item = described_class.new(cart: cart, product: product, quantity: 0)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is valid with positive quantity' do
      cart_item = described_class.new(cart: cart, product: product, quantity: 2)
      expect(cart_item.valid?).to be_truthy
    end
  end

  describe '#total_price' do
    it 'calculates total price correctly' do
      cart_item = described_class.new(cart: cart, product: product, quantity: 3)
      expect(cart_item.total_price).to eq 30.0
    end
  end
end
