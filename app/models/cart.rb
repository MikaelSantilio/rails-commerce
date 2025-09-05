class Cart < ApplicationRecord
  ABANDONMENT_THRESHOLD = 3.hours
  REMOVAL_THRESHOLD = 7.days

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy

  scope :inactive_for, ->(duration) { where(last_interaction_at: ..duration.ago) }
  scope :abandoned, -> { where(abandoned: true) }
  scope :ready_for_abandonment, -> { inactive_for(ABANDONMENT_THRESHOLD) }
  scope :ready_for_removal, -> { abandoned.inactive_for(REMOVAL_THRESHOLD) }

  def mark_as_abandoned
    update!(abandoned: true)
  end

  def remove_if_abandoned
    destroy! if abandoned?
  end

  def abandoned?
    abandoned
  end

  def recalculate_total_price
    update!(total_price: cart_items.sum(&:total_price))
  end

  def update_last_interaction_at
    update!(last_interaction_at: Time.current)
  end
end
