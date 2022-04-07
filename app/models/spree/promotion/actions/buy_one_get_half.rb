module Spree
  class Promotion
    module Actions
      class BuyOneGetHalf < ::Spree::PromotionAction
        include Spree::AdjustmentSource
        include BogoLineItemAdjustmentCalculator

        BUY_N = 1
        GET_N = 0.5
      end
    end
  end
end
