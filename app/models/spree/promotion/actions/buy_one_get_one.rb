module Spree
  class Promotion
    module Actions
      class BuyOneGetOne < ::Spree::PromotionAction
        include Spree::AdjustmentSource
        include BogoLineItemAdjustmentCalculator

        BUY_N = 1
        GET_N = 1
      end
    end
  end
end
