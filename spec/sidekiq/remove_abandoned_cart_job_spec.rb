# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveAbandonedCartJob, type: :job do
  describe '#perform' do
    let!(:old_abandoned_cart_1) do
      FactoryBot.create(:cart,
        last_interaction_at: 8.days.ago,
        abandoned: true
      )
    end

    let!(:old_abandoned_cart_2) do
      FactoryBot.create(:cart,
        last_interaction_at: 10.days.ago,
        abandoned: true
      )
    end

    let!(:recent_abandoned_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 5.days.ago,
        abandoned: true
      )
    end

    let!(:old_non_abandoned_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 8.days.ago,
        abandoned: false
      )
    end

    let!(:boundary_abandoned_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 7.days.ago,
        abandoned: true
      )
    end

    let!(:recent_non_abandoned_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 2.days.ago,
        abandoned: false
      )
    end

    context 'when there are abandoned carts to be removed' do
      it 'removes abandoned carts with last_interaction_at older than 7 days' do
        expect { described_class.new.perform }
          .to change { Cart.exists?(old_abandoned_cart_1.id) }.from(true).to(false)
          .and change { Cart.exists?(old_abandoned_cart_2.id) }.from(true).to(false)
          .and change { Cart.exists?(boundary_abandoned_cart.id) }.from(true).to(false)
      end

      it 'does not remove recent abandoned carts' do
        described_class.new.perform

        expect(Cart.exists?(recent_abandoned_cart.id)).to be true
      end

      it 'does not remove non-abandoned carts regardless of age' do
        described_class.new.perform

        expect(Cart.exists?(old_non_abandoned_cart.id)).to be true
        expect(Cart.exists?(recent_non_abandoned_cart.id)).to be true
      end

      it 'reduces the total cart count' do
        initial_count = Cart.count
        described_class.new.perform
        
        expect(Cart.count).to eq(initial_count - 3) # 3 carts should be removed
      end
    end

    context 'when there are no abandoned carts to be removed' do
      before do
        Cart.destroy_all
        FactoryBot.create(:cart, last_interaction_at: 5.days.ago, abandoned: true)
        FactoryBot.create(:cart, last_interaction_at: 10.days.ago, abandoned: false)
      end

      it 'does not remove any cart' do
        expect { described_class.new.perform }
          .not_to change { Cart.count }
      end
    end

    context 'when there are no carts at all' do
      before { Cart.destroy_all }

      it 'does not raise any errors' do
        expect { described_class.new.perform }.not_to raise_error
      end
    end

    context 'when cart has associated cart_items' do
      let!(:product) { FactoryBot.create(:product) }
      let!(:cart_with_items) do
        cart = FactoryBot.create(:cart,
          last_interaction_at: 8.days.ago,
          abandoned: true
        )
        FactoryBot.create(:cart_item, cart: cart, product: product, quantity: 2)
        cart
      end

      it 'removes the cart and its associated cart_items due to dependent: :destroy' do
        cart_item_id = cart_with_items.cart_items.first.id
        
        expect { described_class.new.perform }
          .to change { Cart.exists?(cart_with_items.id) }.from(true).to(false)
          .and change { CartItem.exists?(cart_item_id) }.from(true).to(false)
      end
    end
  end
end


