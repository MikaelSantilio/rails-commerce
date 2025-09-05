# frozen_string_literal: true

class MarkCartAsAbandonedJob < ApplicationJob
  queue_as :mark_cart_as_abandoned

  def perform
    # puts '=============================='
    # puts 'Starting MarkCartAsAbandonedJob'
    abandoned_carts = Cart.where(last_interaction_at: ..3.hours.ago)
    abandoned_carts.each do |cart|
      cart.mark_as_abandoned
      # puts "Marked cart with ID: #{cart.id} as abandoned"
    end
  end
end
