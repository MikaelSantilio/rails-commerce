require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'scopes' do
    let!(:recent_cart) { FactoryBot.create(:cart, last_interaction_at: 1.hour.ago) }
    let!(:abandoned_cart) { FactoryBot.create(:cart, last_interaction_at: 4.hours.ago) }
    let!(:old_abandoned_cart) { FactoryBot.create(:cart, last_interaction_at: 8.days.ago, abandoned: true) }

    describe '.ready_for_abandonment' do
      it 'returns carts inactive for more than ABANDONMENT_THRESHOLD' do
        carts = described_class.ready_for_abandonment
        expect(carts).to include(abandoned_cart)
        expect(carts).not_to include(recent_cart)
      end
    end

    describe '.ready_for_removal' do
      it 'returns abandoned carts inactive for more than REMOVAL_THRESHOLD' do
        carts = described_class.ready_for_removal
        expect(carts).to include(old_abandoned_cart)
        expect(carts).not_to include(abandoned_cart)
      end
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { FactoryBot.create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { FactoryBot.create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
