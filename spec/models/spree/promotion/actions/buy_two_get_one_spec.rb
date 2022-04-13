require 'spec_helper'

describe Spree::Promotion::Actions::BuyTwoGetOne, type: :model do
  let(:order) {  create(:order_with_line_item_quantity, line_items_quantity: 3) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::BuyTwoGetOne.create }
  let(:payload) { { order: order, promotion: promotion } }

  it_behaves_like 'an adjustment source'

  # From promotion spec:
  context '#perform' do
    before do
      promotion.promotion_actions << action
    end

    it 'it adjusts the price of line item to the cost price' do
       expect(action.perform(payload)).to be true
       expect(order.line_items.first.quantity).to eq(3)
       expect(order.line_items.first.reload.adjustments.first.amount.to_f).to eq(-order.line_items.first.price.to_f)
    end
  end
end
