require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:old_cart_1) do
      FactoryBot.create(:cart,
        last_interaction_at: 4.hours.ago, 
        abandoned: false
      )
    end
    
    let!(:old_cart_2) do
      FactoryBot.create(:cart,
        last_interaction_at: 5.hours.ago, 
        abandoned: false
      )
    end
    
    let!(:recent_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 2.hours.ago, 
        abandoned: false
      )
    end
    
    let!(:already_abandoned_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 6.hours.ago, 
        abandoned: true
      )
    end
    
    let!(:boundary_cart) do
      FactoryBot.create(:cart,
        last_interaction_at: 3.hours.ago, 
        abandoned: false
      )
    end

    context 'when there are carts to be marked as abandoned' do
      it 'marks carts with last_interaction_at older than 3 hours as abandoned' do
        expect { described_class.new.perform }
          .to change { old_cart_1.reload.abandoned }.from(false).to(true)
          .and change { old_cart_2.reload.abandoned }.from(false).to(true)
          .and change { boundary_cart.reload.abandoned }.from(false).to(true)
      end

      it 'does not mark recent carts as abandoned' do
        described_class.new.perform
        
        expect(recent_cart.reload.abandoned).to be false
      end

      it 'does not change already abandoned carts' do
        expect { described_class.new.perform }
          .not_to change { already_abandoned_cart.reload.abandoned }
      end
    end

    context 'when there are no carts to be marked as abandoned' do
      before do
        Cart.destroy_all
        FactoryBot.create(:cart, last_interaction_at: 1.hour.ago, abandoned: false)
      end

      it 'does not mark any cart as abandoned' do
        expect { described_class.new.perform }
          .not_to change { Cart.where(abandoned: true).count }
      end
    end

    context 'when there are no carts at all' do
      before { Cart.destroy_all }

      it 'does not raise any errors' do
        expect { described_class.new.perform }.not_to raise_error
      end
    end
  end
end
