# frozen_string_literal: true

class RemoveAbandonedCartJob < ApplicationJob
  queue_as :remove_abandoned_cart

  def perform
    # puts '=============================='
    # puts 'Starting RemoveAbandonedCartJob'
    abandoned_carts = Cart.where(abandoned: true).where(last_interaction_at: ..7.days.ago)
    abandoned_carts.each do |cart|
      cart.remove_if_abandoned
      # puts "Removed abandoned cart with ID: #{cart.id}"
    end
  end
end
