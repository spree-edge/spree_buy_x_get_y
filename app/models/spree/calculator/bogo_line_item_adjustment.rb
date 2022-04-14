require_dependency 'spree/calculator'

module Spree
  class Calculator::BogoLineItemAdjustment < Calculator
    preference :buy_x, :integer, default: 0
    preference :get_y, :integer, default: 0

    def self.description
      Spree.t(:bogo_promotion)
    end
  end
end
