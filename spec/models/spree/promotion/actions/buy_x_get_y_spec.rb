require 'spec_helper'

describe Spree::Promotion::Actions::BuyXGetY, type: :model do
  let(:order) {  create(:order_with_line_item_quantity, line_items_quantity: 2) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::BuyXGetY.create }
  let(:calculator) { Spree::Calculator::BogoLineItemAdjustment.new }
  let(:payload) { { order: order, promotion: promotion, calculator: calculator } }

  it_behaves_like 'an adjustment source'

  # From promotion spec:
  context '#buy_one_get_half' do
    before do
      action.calculator = calculator
      action.calculator.preferences[:buy_x] = 1
      action.calculator.preferences[:get_y] = 0.5
      promotion.promotion_actions << action
    end

    it 'it reduces the price of other line_item by half' do
       expect(action.perform(payload)).to be true
       expect(order.line_items.first.quantity).to eq(2)
       expect(order.line_items.first.reload.adjustments.first.amount.to_f).to eq(-order.line_items.first.price.to_f/2)
    end
  end
    # From promotion spec:
  context '#buy_one_get_one' do
    before do
      action.calculator = calculator
      action.calculator.preferences[:buy_x] = 1
      action.calculator.preferences[:get_y] = 1
      promotion.promotion_actions << action
    end

    it 'it adjusts the price of line item to the cost price' do
       expect(action.perform(payload)).to be true
       expect(order.line_items.first.quantity).to eq(2)
       expect(order.line_items.first.reload.adjustments.first.amount.to_f).to eq(-order.line_items.first.price.to_f)
    end
  end

  context '#buy_two_get_one' do
    let(:order) {  create(:order_with_line_item_quantity, line_items_quantity: 3) }
    
    before do
      action.calculator = calculator
      action.calculator.preferences[:buy_x] = 2
      action.calculator.preferences[:get_y] = 1
      promotion.promotion_actions << action
    end

    it 'it adjusts the price of line item to the cost price' do
       expect(action.perform(payload)).to be true
       expect(order.line_items.first.quantity).to eq(3)
       expect(order.line_items.first.reload.adjustments.first.amount.to_f).to eq(-order.line_items.first.price.to_f)
    end
  end
end
