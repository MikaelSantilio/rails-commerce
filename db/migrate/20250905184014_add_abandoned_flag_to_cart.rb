class AddAbandonedFlagToCart < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, default: false, null: false
    add_column :carts, :last_interaction_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
