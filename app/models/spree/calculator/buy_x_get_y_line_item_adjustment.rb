require_dependency 'spree/calculator'

module Spree
  class Calculator::BuyXGetYLineItemAdjustment < Calculator
    preference :buy_x, :integer, default: 0
    preference :get_y, :integer, default: 0

    def self.description
      Spree.t(:buy_x_get_y_promotion)
    end
  end
end
