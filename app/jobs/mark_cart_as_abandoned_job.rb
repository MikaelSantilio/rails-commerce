# frozen_string_literal: true

class MarkCartAsAbandonedJob < ApplicationJob
  queue_as :mark_cart_as_abandoned

  def perform
    Cart.ready_for_abandonment.find_each(&:mark_as_abandoned)
  end
end
