# frozen_string_literal: true

class RemoveAbandonedCartJob < ApplicationJob
  queue_as :remove_abandoned_cart

  def perform
    Cart.ready_for_removal.find_each(&:remove_if_abandoned)
  end
end
