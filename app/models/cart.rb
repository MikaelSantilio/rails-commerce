class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  has_many :cart_items, dependent: :destroy

  def mark_as_abandoned
    self.abandoned = true
    save!
  end

  def remove_if_abandoned
    self.destroy if abandoned?
  end

  def abandoned?
    abandoned
  end

  def increase_product_quantity(product, quantity)
    transaction do
      cart_item = cart_items.find_by(product_id: product.id)
      if cart_item.blank?
        errors.add(:base, "Produto não está no carrinho")
        raise ActiveRecord::RecordInvalid.new(self)
      end

      cart_item.increment(:quantity, quantity)
      cart_item.save!

      recalculate_total_price
      update_last_interaction_at
    end
  end

  def add_new_product(product, quantity)
    transaction do
      cart_item = cart_items.find_by(product_id: product.id)
      if cart_item.present?
        errors.add(:base, "Produto já está no carrinho")
        raise ActiveRecord::RecordInvalid.new(self)
      end

      cart_items.create!(product: product, quantity: quantity)

      recalculate_total_price
      update_last_interaction_at
    end
  end

  def remove_product(product)
    transaction do
      cart_item = cart_items.find_by(product_id: product.id)
      if cart_item.blank?
        errors.add(:base, "Produto não está no carrinho")
        raise ActiveRecord::RecordInvalid.new(self)
      end
      
      cart_item.destroy!

      recalculate_total_price
      update_last_interaction_at
    end
  end

  def recalculate_total_price
    self.total_price = cart_items.includes(:product).sum(&:total_price)
    save!
  end

  def update_last_interaction_at
    self.last_interaction_at = Time.current
    save!
  end
end
