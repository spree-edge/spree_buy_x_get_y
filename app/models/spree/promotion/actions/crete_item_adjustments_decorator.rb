module Spree
  class Promotion
    module Actions
      class CreateItemAdjustments
        def perform(options = {})
          order = options[:order]
          promotion = options[:promotion]
          create_unique_adjustments(order, order.line_items) do |line_item|
            promotion.line_item_actionable?(order, line_item) && discount_allowed_item(line_item)
          end
        end

        def compute_amount(line_item)
          return 0 unless discount_allowed_item(line_item)

          [line_item.amount, compute(line_item)].min * -1
        end

        private

        def discount_allowed_item(line_item)
          !line_item.subscribing && (line_item.order.user.nil? || !line_item.order.user.wholesaler?)
        end
      end
    end
  end
end
