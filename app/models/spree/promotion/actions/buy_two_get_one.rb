module Spree
  class Promotion
    module Actions
      class BuyTwoGetOne < ::Spree::PromotionAction
        include Spree::AdjustmentSource
        include BogoLineItemAdjustmentCalculator

        BUY_N = 2
        GET_N = 1
      end
    end
  end
end
