require 'spec_helper'

describe Spree::Promotion::Actions::BuyXGetY, type: :model do
  let(:order) {  create(:order_with_line_item_quantity, line_items_quantity: 2, line_items_price: BigDecimal(10) ) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::BuyXGetY.create }
  let(:calculator) { Spree::Calculator::BuyXGetYLineItemAdjustment.new }
  let(:payload) { { order: order, promotion: promotion, calculator: calculator } }

  it_behaves_like 'an adjustment source'

  def set_promotion(buy_x, buy_y)
    action.calculator = calculator
    action.calculator.preferences[:buy_x] = buy_x
    action.calculator.preferences[:get_y] = buy_y
    promotion.promotion_actions << action
  end

  context '#buy_one_get_two' do
    before do
      set_promotion(1, 2)
    end

    it 'create the discount on line item twice of its quanity' do
       expect(action.perform(payload)).to be true
       expect(order.reload.all_adjustments.pluck(:amount).sum.to_f).to eq(10 * 2 * -1)
    end
  end

  context '#buy_one_get_one' do
    before do
      set_promotion(1, 1)
    end    

    it 'create the disount of line item based on its price' do
       expect(action.perform(payload)).to be true
       expect(order.reload.all_adjustments.pluck(:amount).sum.to_f).to eq(10 * 1 * -1)
    end
  end

  context '#buy_two_get_one' do
    let(:order) {  create(:order_with_line_item_quantity, line_items_quantity: 3) }

    before do
      set_promotion(2, 1)
    end

    it 'provides one item as free on purchase of 2' do
       expect(action.perform(payload)).to be true
       expect(order.line_items.pluck(:quantity).sum).to be >= 2
       expect(order.reload.all_adjustments.pluck(:amount).sum.to_f).to eq(10 * 1 * -1)
    end
  end
end

