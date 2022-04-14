module Spree
  class Promotion
    module Actions
      class BuyXGetY < ::Spree::PromotionAction
        include Spree::CalculatedAdjustments
        include Spree::AdjustmentSource

        before_validation -> { self.calculator ||= Calculator::BogoLineItemAdjustment.new }

        # Returns a hash like:
        ## => { 1: 100, 2: 20 } aka: { line_item_id: line_item_price }
        ## => Basically a mapping of line_item_ids and applicable BOGO
        ## => discount.
        # flattenned_product_line_items = {}
        def adjustment_by_line_item(order, promotion, buy_n, get_n, product = nil)
          flattenned_product_line_items = line_items_by_product_id(order, promotion, product)

          line_item_adjustments = {}

          flattenned_product_line_items.each_pair do |_product_id, line_items|
            line_items.each_with_index do |line_item, idx|
              line_item_adjustments[line_item[:id]] ||= 0
              if get_n == 0.5 && buy_n == 1
                line_item_adjustments[line_item[:id]] -= (line_item[:price] * get_n) if idx.odd?
              elsif idx % (buy_n + get_n) == buy_n
                line_item_adjustments[line_item[:id]] -= (line_item[:price] * get_n)
              end
            end
          end

          line_item_adjustments
        end

        def perform(options = {})
          promotion = options[:promotion]
          order = options[:order]
          adjustments_by_line_items = adjustment_by_line_item(order, promotion, self.calculator.preferences[:buy_x],
                                                              self.calculator.preferences[:get_y])
          adjustments_by_line_items.map do |line_item_id, _adj_amount|
            line_item = order.line_items.detect { |li| li.id == line_item_id }
            create_unique_adjustment(order, line_item)
          end.any?
        end

        def compute_amount(line_item)
          adjustments_by_line_items = adjustment_by_line_item(line_item.order, promotion, self.calculator.preferences[:buy_x],
                                                              self.calculator.preferences[:get_y])
          adjustments_by_line_items[line_item.id] || 0.0
        end

        private

        def extract_line_item_fields(line_item)
          { id: line_item.id, price: line_item.price }
        end

        # Returns a hash like:
        ## => { product_1.id: [{id: 1, price: 100}, {id: 1, price: 100}, {id: 2, price: 150}],
        ## =>   product_1.id: [{id: 3, price: 100}, {id: 3, price: 100}, {id: 3, price: 150}] }
        ## => Basically, flattens all the line_items for each instance of ...
        ## => their qty grouped by product id.
        def line_items_by_product_id(order, promotion, product = nil)
          flattenned_product_line_items = Hash.new { |h, k| h[k] = [] }
          applicable_line_items = if product
                                    product.line_items.where(order_id: order.id)
                                  else
                                    order.line_items
                                  end

          applicable_line_items.each do |line_item|
            next unless promotion.line_item_actionable?(order, line_item)

            line_item.quantity.times do |_idx|
              flattenned_product_line_items[line_item.product.id.to_s] <<
                extract_line_item_fields(line_item)
            end
          end

          flattenned_product_line_items
        end
      end
    end
  end
end
